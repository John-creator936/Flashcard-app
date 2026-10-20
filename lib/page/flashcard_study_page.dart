import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/sm2.dart';
import 'package:flashcard_app/model/study_session.dart';
import 'package:flashcard_app/widget/study_end_view.dart';
import 'package:flashcard_app/model/study_options.dart';
import 'package:flashcard_app/widget/study_options_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FlashcardStudyPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  final int deckId;
  final bool isReview;
  const FlashcardStudyPage({
    super.key,
    required this.flashcards,
    required this.deckId,
    this.isReview = false,
  });

  @override
  State<FlashcardStudyPage> createState() => _FlashcardStudyPageState();
}

class _FlashcardStudyPageState extends State<FlashcardStudyPage> {
  late List<Flashcard> studyCards;
  List<Flashcard> failedCards = [];
  StudyOptions options = const StudyOptions();
  int currentCardIndex = 0;
  bool isFlipped = false;
  bool isFinished = false;
  static const _mode = 'flashcard';
  static const _weight = 0.5;
  bool isLoading = true;
  bool isRetryRound = false;

  @override
  void initState() {
    super.initState();
    studyCards = widget.flashcards.toList();
    _loadOptions();
  }

  void _classifyCard(bool isKnown) {
    if (widget.isReview && !isRetryRound) {
      Flashcard updatedCard = SM2.review(
        studyCards[currentCardIndex],
        isSuccess: isKnown,
        weight: _weight,
      );
      CardRepository().update(updatedCard);
    }
    setState(() {
      if (isKnown == false) {
        failedCards.add(studyCards[currentCardIndex]);
      }
      if (currentCardIndex < studyCards.length - 1) {
        currentCardIndex++;
        isFlipped = false;
      } else {
        isFinished = true;
      }
    });
    if (!widget.isReview) {
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

  // TODO: factoriser cette logique de mélange et de retour à l'ordre d'origine,
  // répétée dans les trois pages de mode (flashcard, écrit, QCM).
  void _onOptionsChanged(StudyOptions newOptions) {
    setState(() {
      if (options.shuffled == false && newOptions.shuffled == true) {
        List<Flashcard> studiedCards = studyCards.sublist(0, currentCardIndex);
        List<Flashcard> remainingCards = studyCards.sublist(currentCardIndex);
        remainingCards.shuffle();
        studyCards = [...studiedCards, ...remainingCards];
        isFlipped = false;
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
        isFlipped = false;
      }
      if (options.reversed != newOptions.reversed) {
        isFlipped = false;
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
      isFlipped = false;
      isFinished = false;
      if (options.shuffled) {
        studyCards.shuffle();
      }
    });
    _saveSession();
  }

  void _retryFailedCards() => _startRound(failedCards, isRetry: true);
  void _resetSession() => _startRound(widget.flashcards, isRetry: false);

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
        children: [
          SizedBox(
            width: 360,
            child: Dismissible(
              key: ValueKey(studyCards[currentCardIndex].id),
              background: Container(
                color: Colors.green,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.check, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.close, color: Colors.white),
              ),
              onDismissed: (direction) {
                _classifyCard(direction == DismissDirection.startToEnd);
              },
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isFlipped = !isFlipped;
                  });
                },
                child: Container(
                  width: 360,
                  height: 600,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: (isFlipped != options.reversed)
                      ? Text(
                          studyCards[currentCardIndex].definition,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight(400),
                          ),
                        )
                      : Text(
                          studyCards[currentCardIndex].term,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight(400),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mode Flashcard"),
        actions: [
          IconButton(
            onPressed: (!isFinished && !isLoading)
                ? () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => StudyOptionsSheet(
                        initialOptions: options,
                        onChanged: _onOptionsChanged,
                        onReset: (widget.isReview) ? null : _resetSession,
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
