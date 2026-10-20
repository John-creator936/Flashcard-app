import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/sm2.dart';
import 'package:flashcard_app/model/study_session.dart';
import 'package:flashcard_app/widget/study_end_view.dart';
import 'package:flashcard_app/model/study_options.dart';
import 'package:flashcard_app/widget/study_options_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  late List<Flashcard> studyCards;
  List<Flashcard> failedCards = [];
  StudyOptions options = const StudyOptions();
  int currentCardIndex = 0;
  TextEditingController answerController = TextEditingController();
  bool? isCorrect;
  bool isFinished = false;
  static const _mode = 'written';
  static const _weight = 1.0;
  bool isLoading = true;
  bool isRetryRound = false;

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

  void _checkAnswer() {
    setState(() {
      if (answerController.text == expectedAnswer) {
        isCorrect = true;
      } else {
        isCorrect = false;
      }
    });
  }

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

  void _saveSession() {
    if (widget.isReview) return;
    StudySession(
      studyCardIds: studyCards.map((flashcard) => flashcard.id!).toList(),
      currentCardIndex: currentCardIndex,
      failedCardIds: failedCards.map((flashcard) => flashcard.id!).toList(),
      deckCardIds: widget.flashcards.map((flashcard) => flashcard.id!).toList(),
    ).save(widget.deckId, _mode);
  }

  void _retryFailedCards() => _startRound(failedCards, isRetry: true);
  void _resetSession() => _startRound(widget.flashcards, isRetry: false);

  String get questionText => options.reversed
      ? studyCards[currentCardIndex].definition
      : studyCards[currentCardIndex].term;
  String get expectedAnswer => options.reversed
      ? studyCards[currentCardIndex].term
      : studyCards[currentCardIndex].definition;

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
