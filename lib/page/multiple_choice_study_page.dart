import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/model/sm2.dart';
import 'package:flashcard_app/model/spelling_errors.dart';
import 'package:flashcard_app/model/study_session.dart';
import 'package:flashcard_app/widget/study_end_view.dart';
import 'package:flashcard_app/model/study_options.dart';
import 'package:flashcard_app/widget/study_options_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Mode QCM : l'utilisateur choisit la bonne réponse parmi 2 à 4 choix.
///
/// Sert à l'entraînement libre et, avec [isReview], à la Révision.
class MultipleChoiceStudyPage extends StatefulWidget {
  /// Cartes à étudier.
  final List<Flashcard> flashcards;

  /// Tout le deck, en Révision : les fausses réponses y sont piochées,
  /// car les seules cartes à revoir peuvent être trop peu nombreuses.
  final List<Flashcard>? allCards;
  final Deck deck;
  final bool isReview;
  const MultipleChoiceStudyPage({
    super.key,
    required this.flashcards,
    this.allCards,
    required this.deck,
    this.isReview = false,
  });

  @override
  State<MultipleChoiceStudyPage> createState() =>
      _MultipleChoiceStudyPageState();
}

class _MultipleChoiceStudyPageState extends State<MultipleChoiceStudyPage> {
  /// Nom du mode dans les clés de session.
  static const _mode = 'mcq';

  /// Poids SM-2 du QCM : la réponse est seulement reconnue, pas tapée.
  static const _weight = 0.5;

  late List<Flashcard> studyCards;

  /// Choix affichés pour la carte actuelle, fabriqués une seule
  /// fois par carte : sinon chaque `setState` les remélangerait.
  late List<String> choices;
  List<Flashcard> failedCards = [];
  StudyOptions options = const StudyOptions();
  int currentCardIndex = 0;

  /// Choix touché par l’utilisateur, ou `null` s’il n’a pas encore
  /// répondu. Un seul essai par carte.
  String? selectedChoice;
  bool isFinished = false;
  bool isLoading = true;

  /// Vrai pendant le tour des cartes ratées, qui ne compte pas pour le progrès SM-2.
  bool isRetryRound = false;

  /// Cartes où piocher les fausses réponses.
  List<Flashcard> get _choicePool => widget.allCards ?? widget.flashcards;

  /// Question et réponse attendue de la carte actuelle, inversées si l’option est active.
  String get questionText => options.reversed
      ? studyCards[currentCardIndex].definition
      : studyCards[currentCardIndex].term;
  String get expectedAnswer => _answerOf(studyCards[currentCardIndex]);

  /// Langue de la réponse attendue, pour choisir les pièges propres à cette langue.
  /// `null` hors vocabulaire.
  String? get answerLanguage => (widget.deck.deckType != 'translation')
      ? null
      : (options.reversed)
      ? widget.deck.termLanguage
      : widget.deck.definitionLanguage;

  /// Les pièges d’orthographe sont interdits pour un deck de définitions,
  /// où c’est le sens qu’on veut tester.
  bool get _trapsAllowed => widget.deck.deckType != 'definition';

  @override
  void initState() {
    super.initState();
    studyCards = widget.flashcards.toList();
    _loadOptions();
  }

  /// Passe à la carte suivante.
  ///
  /// En Révision, enregistre d’abord le progrès SM-2 ;
  /// en entraînement libre, enregistre la session.
  void _nextCard() {
    if (widget.isReview && !isRetryRound) {
      Flashcard updatedCard = SM2.review(
        studyCards[currentCardIndex],
        isSuccess: selectedChoice == expectedAnswer,
        weight: _weight,
      );
      CardRepository().update(updatedCard);
    }
    setState(() {
      if (selectedChoice != expectedAnswer) {
        failedCards.add(studyCards[currentCardIndex]);
      }
      if (currentCardIndex < studyCards.length - 1) {
        currentCardIndex++;
        selectedChoice = null;
        choices = _buildChoices();
      } else {
        isFinished = true;
      }
    });
    if (!widget.isReview) {
      if (!isFinished) {
        _saveSession();
      } else if (failedCards.isEmpty) {
        StudySession.clear(widget.deck.id!, _mode);
      } else {
        // Session terminée avec des échecs : la prochaine fois, on reprend
        // seulement les cartes ratées.
        StudySession(
          studyCardIds: failedCards.map((flashcard) => flashcard.id!).toList(),
          currentCardIndex: 0,
          failedCardIds: [],
          deckCardIds: widget.flashcards
              .map((flashcard) => flashcard.id!)
              .toList(),
        ).save(widget.deck.id!, _mode);
      }
    }
  }

  /// Applique les nouvelles options.
  ///
  /// Le mélange ne touche que les cartes restantes :
  /// la partie déjà étudiée reste intacte.
  ///
  /// Les choix sont refabriqués si une option qui les modifie a changé.
  void _onOptionsChanged(StudyOptions newOptions) {
    setState(() {
      bool shuffleChanged = options.shuffled != newOptions.shuffled;
      bool reversedChanged = options.reversed != newOptions.reversed;
      bool spellingTrapsChanged =
          options.spellingTraps != newOptions.spellingTraps;
      options = newOptions;
      options.save(widget.deck.id!);
      if (options.shuffled == true && shuffleChanged) {
        List<Flashcard> studiedCards = studyCards.sublist(0, currentCardIndex);
        List<Flashcard> remainingCards = studyCards.sublist(currentCardIndex);
        remainingCards.shuffle();
        studyCards = [...studiedCards, ...remainingCards];
      } else if (options.shuffled == false && shuffleChanged) {
        List<Flashcard> studiedCards = studyCards.sublist(0, currentCardIndex);
        List<Flashcard> remainingCards = studyCards.sublist(currentCardIndex);
        Set<int> remainingIds = remainingCards
            .map((remainingCard) => remainingCard.id!)
            .toSet();
        List<Flashcard> orderedRemainingCards = widget.flashcards
            .where((flashcard) => remainingIds.contains(flashcard.id!))
            .toList();
        studyCards = [...studiedCards, ...orderedRemainingCards];
      }
      if (reversedChanged || shuffleChanged || spellingTrapsChanged) {
        selectedChoice = null;
        choices = _buildChoices();
      }
    });
    _saveSession();
  }

  /// Commence un nouveau tour avec [cards], mélangées si l’option est active.
  void _startRound(List<Flashcard> cards, {required bool isRetry}) {
    setState(() {
      isRetryRound = isRetry;
      studyCards = cards.toList();
      failedCards = [];
      currentCardIndex = 0;
      selectedChoice = null;
      isFinished = false;
      if (options.shuffled) {
        studyCards.shuffle();
      }
      choices = _buildChoices();
    });
    _saveSession();
  }

  /// Charge les options du deck et reprend la session précédente,
  /// si le deck n’a pas changé depuis.
  Future<void> _loadOptions() async {
    final loadedOptions = await StudyOptions.load(widget.deck.id!);
    final session = widget.isReview
        ? null
        : await StudySession.load(widget.deck.id!, _mode);
    final isValid =
        session != null &&
        setEquals(
          session.deckCardIds.toSet(),
          widget.flashcards.map((flashcard) => flashcard.id!).toSet(),
        ) &&
        session.studyCardIds.isNotEmpty;
    if (!mounted) return;
    setState(() {
      options = loadedOptions;
      if (isValid) {
        final cardsById = {
          for (final card in widget.flashcards) card.id!: card,
        };
        studyCards = session.studyCardIds.map((id) => cardsById[id]!).toList();
        failedCards = session.failedCardIds
            .map((id) => cardsById[id]!)
            .toList();
        currentCardIndex = session.currentCardIndex;
      } else {
        if (session != null) {
          StudySession.clear(widget.deck.id!, _mode);
        }
        if (options.shuffled) {
          studyCards.shuffle();
        }
      }
      choices = _buildChoices();
      isLoading = false;
    });
  }

  /// Enregistre l’avancement, sauf en Révision (qui ne se reprend pas).
  void _saveSession() {
    if (widget.isReview) return;
    StudySession(
      studyCardIds: studyCards.map((flashcard) => flashcard.id!).toList(),
      currentCardIndex: currentCardIndex,
      failedCardIds: failedCards.map((flashcard) => flashcard.id!).toList(),
      deckCardIds: widget.flashcards.map((flashcard) => flashcard.id!).toList(),
    ).save(widget.deck.id!, _mode);
  }

  /// Relance un tour avec les cartes ratées, ou avec tout le deck.
  void _retryFailedCards() => _startRound(failedCards, isRetry: true);
  void _resetSession() => _startRound(widget.flashcards, isRetry: false);

  /// Réponse d’une carte, selon le sens des questions.
  String _answerOf(Flashcard flashcard) =>
      (options.reversed) ? flashcard.term : flashcard.definition;

  /// Fabrique les choix de la carte actuelle : la bonne réponse et
  /// jusqu’à 3 fausses, mélangées.
  ///
  /// Les fausses sont des pièges d’orthographe si l’option est active,
  /// sinon (ou si aucun piège n’a été trouvé) des réponses d’autres cartes.
  List<String> _buildChoices() {
    List<String> wrongAnswers = [];
    if (options.spellingTraps && _trapsAllowed) {
      wrongAnswers = SpellingErrors.generate(
        expectedAnswer,
        language: answerLanguage,
      );
    }
    if (wrongAnswers.isEmpty) {
      wrongAnswers = _otherCardAnswers();
    }
    List<String> allChoices = [...wrongAnswers, expectedAnswer];
    allChoices.shuffle();
    return allChoices;
  }

  /// Pioche jusqu’à 3 réponses différentes de la bonne dans les autres cartes,
  /// sans doublon.
  List<String> _otherCardAnswers() {
    List<String> allAnswers = _choicePool
        .map((flashcard) => _answerOf(flashcard))
        .toList();
    List<String> differentAnswers = allAnswers
        .where((answer) => answer != expectedAnswer)
        .toList();
    List<String> uniqueAnswers = differentAnswers.toSet().toList();
    uniqueAnswers.shuffle();
    List<String> wrongAnswers = uniqueAnswers.take(3).toList();
    return wrongAnswers;
  }

  /// Après la réponse, la bonne réponse passe en vert et les autres en rouge.
  Color _colorFor(String choice) {
    if (selectedChoice == null) {
      return Colors.white;
    }
    if (choice == expectedAnswer) {
      return Colors.green.withValues(alpha: 0.2);
    } else {
      return Colors.red.withValues(alpha: 0.2);
    }
  }

  /// Affiche le chargement, l’écran de fin ou la carte actuelle.
  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (isFinished) {
      return StudyEndView(
        correctCount: studyCards.length - failedCards.length,
        totalCount: studyCards.length,
        onRetryFailed: failedCards.isEmpty ? null : _retryFailedCards,
        onReset: (widget.isReview) ? null : _resetSession,
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(questionText),
          SizedBox(height: 50),
          ...List.generate(
            choices.length,
            (index) => GestureDetector(
              onTap: () {
                if (selectedChoice == null) {
                  setState(() {
                    selectedChoice = choices[index];
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _colorFor(choices[index]),
                  border: Border.all(
                    color: const Color.fromARGB(115, 237, 231, 231),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(choices[index]),
              ),
            ),
          ),
          (selectedChoice != null)
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextCard,
                      child: Text("Continuer"),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mode QCM"),
        actions: [
          IconButton(
            onPressed: (!isFinished && selectedChoice == null && !isLoading)
                ? () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => StudyOptionsSheet(
                        initialOptions: options,
                        onChanged: _onOptionsChanged,
                        onReset: (widget.isReview) ? null : _resetSession,
                        showSpellingTraps: _trapsAllowed,
                      ),
                    );
                  }
                : null,
            icon: Icon(Icons.tune),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
