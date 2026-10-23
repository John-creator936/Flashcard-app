import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/model/answer_checker.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/sm2.dart';
import 'package:flashcard_app/model/study_session.dart';
import 'package:flashcard_app/widget/study_end_view.dart';
import 'package:flashcard_app/model/study_options.dart';
import 'package:flashcard_app/widget/study_options_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Mode écrit : l'utilisateur tape la réponse au lieu de la choisir.
///
/// Sert à l'entraînement libre et, avec [isReview], à la Révision.
class WrittenStudyPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  final int deckId;
  final bool isReview;
  const WrittenStudyPage({
    super.key,
    required this.flashcards,
    required this.deckId,
    this.isReview = false,
  });

  @override
  State<WrittenStudyPage> createState() => _WrittenStudyPageState();
}

class _WrittenStudyPageState extends State<WrittenStudyPage> {
  /// Nom du mode dans les clés de session.
  static const _mode = 'written';

  /// Poids SM-2 du mode écrit : le plus élevé, car taper la réponse
  /// est plus difficile que la reconnaître.
  static const _weight = 1.0;

  late List<Flashcard> studyCards;
  List<Flashcard> failedCards = [];
  StudyOptions options = const StudyOptions();
  int currentCardIndex = 0;
  TextEditingController answerController = TextEditingController();
  bool? isCorrect;
  bool isFinished = false;
  bool isLoading = true;

  /// Vrai pendant le tour des cartes ratées, qui ne compte pas pour le progrès SM-2.
  bool isRetryRound = false;

  /// Question et réponse attendue de la carte actuelle, inversées
  /// si l’option est active.
  String get questionText => options.reversed
      ? studyCards[currentCardIndex].definition
      : studyCards[currentCardIndex].term;
  String get expectedAnswer => options.reversed
      ? studyCards[currentCardIndex].term
      : studyCards[currentCardIndex].definition;

  @override
  void initState() {
    super.initState();
    studyCards = widget.flashcards.toList();
    _loadOptions();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  /// Compare la réponse tapée avec la réponse attendue.
  void _checkAnswer() {
    setState(() {
      isCorrect = AnswerChecker.isCorrect(
        answerController.text,
        expectedAnswer,
      );
    });
  }

  /// Passe à la carte suivante.
  ///
  /// En Révision, enregistre d’abord le progrès SM-2 ;
  /// en entraînement libre, enregistre la session.
  void _nextCard() {
    if (widget.isReview && !isRetryRound) {
      Flashcard updatedCard = SM2.review(
        studyCards[currentCardIndex],
        isSuccess: isCorrect!,
        weight: _weight,
      );
      CardRepository().update(updatedCard);
    }
    setState(() {
      if (isCorrect == false) {
        failedCards.add(studyCards[currentCardIndex]);
      }
      if (currentCardIndex < studyCards.length - 1) {
        currentCardIndex++;
        isCorrect = null;
        answerController.text = "";
      } else {
        isFinished = true;
      }
    });
    if ((!widget.isReview)) {
      if (!isFinished) {
        _saveSession();
      } else if (failedCards.isEmpty) {
        StudySession.clear(widget.deckId, _mode);
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
        ).save(widget.deckId, _mode);
      }
    }
  }

  /// Applique les nouvelles options.
  ///
  /// Le mélange ne touche que les cartes restantes :
  /// la partie déjà étudiée reste intacte.
  void _onOptionsChanged(StudyOptions newOptions) {
    setState(() {
      if (options.shuffled == false && newOptions.shuffled == true) {
        List<Flashcard> studiedCards = studyCards.sublist(0, currentCardIndex);
        List<Flashcard> remainingCards = studyCards.sublist(currentCardIndex);
        remainingCards.shuffle();
        studyCards = [...studiedCards, ...remainingCards];
        isCorrect = null;
        answerController.text = "";
      } else if (options.shuffled == true && newOptions.shuffled == false) {
        List<Flashcard> studiedCards = studyCards.sublist(0, currentCardIndex);
        List<Flashcard> remainingCards = studyCards.sublist(currentCardIndex);
        Set<int> remainingIds = remainingCards
            .map((remainingCard) => remainingCard.id!)
            .toSet();
        List<Flashcard> orderedRemainingCards = widget.flashcards
            .where((flashcard) => remainingIds.contains(flashcard.id!))
            .toList();
        studyCards = [...studiedCards, ...orderedRemainingCards];
        isCorrect = null;
        answerController.text = "";
      }
      if (options.reversed != newOptions.reversed) {
        isCorrect = null;
        answerController.text = "";
      }
      options = newOptions;
    });
    options.save(widget.deckId);
    _saveSession();
  }

  /// Commence un nouveau tour avec [cards], mélangées si l’option est active.
  void _startRound(List<Flashcard> cards, {required bool isRetry}) {
    setState(() {
      isRetryRound = isRetry;
      studyCards = cards.toList();
      failedCards = [];
      currentCardIndex = 0;
      isCorrect = null;
      isFinished = false;
      answerController.text = "";
      if (options.shuffled) {
        studyCards.shuffle();
      }
    });
    _saveSession();
  }

  /// Charge les options du deck et reprend la session précédente,
  /// si le deck n’a pas changé depuis.
  Future<void> _loadOptions() async {
    final loadedOptions = await StudyOptions.load(widget.deckId);
    final session = widget.isReview
        ? null
        : await StudySession.load(widget.deckId, _mode);
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
          StudySession.clear(widget.deckId, _mode);
        }
        if (options.shuffled) {
          studyCards.shuffle();
        }
      }
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
    ).save(widget.deckId, _mode);
  }

  /// Relance un tour avec les cartes ratées, ou avec tout le deck.
  void _retryFailedCards() => _startRound(failedCards, isRetry: true);
  void _resetSession() => _startRound(widget.flashcards, isRetry: false);

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
        onReset: widget.isReview ? null : _resetSession,
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(questionText),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: (isCorrect == null)
                  ? null
                  : Border.all(color: isCorrect! ? Colors.green : Colors.red),
              color: (isCorrect == null)
                  ? null
                  : (isCorrect!
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Expanded(child: TextField(controller: answerController)),
                IconButton(
                  onPressed: (isCorrect == null) ? _checkAnswer : null,
                  icon: Icon(Icons.check),
                ),
              ],
            ),
          ),
          (isCorrect == false)
              ? Text("La bonne réponse était : $expectedAnswer")
              : const SizedBox.shrink(),
          (isCorrect != null)
              ? IconButton(
                  onPressed: _nextCard,
                  icon: Icon(Icons.navigate_next),
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
        title: Text("Mode écrit"),
        actions: [
          IconButton(
            onPressed: (!isFinished && isCorrect == null && !isLoading)
                ? () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => StudyOptionsSheet(
                        initialOptions: options,
                        onChanged: _onOptionsChanged,
                        onReset: widget.isReview ? null : _resetSession,
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
