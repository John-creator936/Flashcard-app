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

class MultipleChoiceStudyPage extends StatefulWidget {
  final List<Flashcard> flashcards;
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
  late List<Flashcard> studyCards;
  late List<String> choices;
  List<Flashcard> failedCards = [];
  StudyOptions options = const StudyOptions();
  int currentCardIndex = 0;
  String? selectedChoice;
  bool isFinished = false;
  static const _weight = 0.5;
  static const _mode = 'mcq';
  bool isLoading = true;
  bool isRetryRound = false;

  List<Flashcard> get _choicePool => widget.allCards ?? widget.flashcards;

  @override
  void initState() {
    super.initState();
    studyCards = widget.flashcards.toList();
    _loadOptions();
  }

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

  void _retryFailedCards() => _startRound(failedCards, isRetry: true);
  void _resetSession() => _startRound(widget.flashcards, isRetry: false);

  List<String> _buildChoices() {
    List<String> wrongAnswers = [];
    if (options.spellingTraps && _trapsAllowed) {
      wrongAnswers = SpellingErrors.generate(expectedAnswer);
    }
    if (wrongAnswers.isEmpty) {
      wrongAnswers = _otherCardAnswers();
    }
    List<String> allChoices = [...wrongAnswers, expectedAnswer];
    allChoices.shuffle();
    return allChoices;
  }

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

  String _answerOf(Flashcard flashcard) =>
      (options.reversed) ? flashcard.term : flashcard.definition;

  String get questionText => options.reversed
      ? studyCards[currentCardIndex].definition
      : studyCards[currentCardIndex].term;
  String get expectedAnswer => _answerOf(studyCards[currentCardIndex]);

  String? get answerLanguage => (widget.deck.deckType != 'translation')
      ? null
      : (options.reversed)
      ? widget.deck.termLanguage
      : widget.deck.definitionLanguage;

  bool get _trapsAllowed => widget.deck.deckType != 'definition';

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

  void _saveSession() {
    if (widget.isReview) return;
    StudySession(
      studyCardIds: studyCards.map((flashcard) => flashcard.id!).toList(),
      currentCardIndex: currentCardIndex,
      failedCardIds: failedCards.map((flashcard) => flashcard.id!).toList(),
      deckCardIds: widget.flashcards.map((flashcard) => flashcard.id!).toList(),
    ).save(widget.deck.id!, _mode);
  }

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
