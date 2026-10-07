import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/widget/study_end_view.dart';
import 'package:flashcard_app/widget/study_options.dart';
import 'package:flashcard_app/widget/study_options_sheet.dart';
import 'package:flutter/material.dart';

class MultipleChoiceStudyPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  final int deckId;
  const MultipleChoiceStudyPage({
    super.key,
    required this.flashcards,
    required this.deckId,
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

  @override
  void initState() {
    super.initState();
    studyCards = widget.flashcards.toList();
    _loadOptions();
    choices = _buildChoices();
  }

  void _nextCard() {
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
  }

  void _startRound(List<Flashcard> cards) {
    setState(() {
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
  }

  void _retryFailedCards() => _startRound(failedCards);
  void _resetSession() => _startRound(widget.flashcards);

  List<String> _buildChoices() {
    List<String> allAnswers = widget.flashcards
        .map((flashcard) => _answerOf(flashcard))
        .toList();
    List<String> differentAnswers = allAnswers
        .where((answer) => answer != expectedAnswer)
        .toList();
    List<String> uniqueAnswers = differentAnswers.toSet().toList();
    uniqueAnswers.shuffle();
    List<String> wrongAnswers = uniqueAnswers.take(3).toList();
    List<String> allChoices = [...wrongAnswers, expectedAnswer];
    allChoices.shuffle();
    return allChoices;
  }

  String _answerOf(Flashcard flashcard) =>
      (options.reversed) ? flashcard.term : flashcard.definition;

  String get questionText => options.reversed
      ? studyCards[currentCardIndex].definition
      : studyCards[currentCardIndex].term;
  String get expectedAnswer => _answerOf(studyCards[currentCardIndex]);

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
      options = newOptions;
      options.save(widget.deckId);
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
      if (reversedChanged || shuffleChanged) {
        selectedChoice = null;
        choices = _buildChoices();
      }
    });
  }

  Future<void> _loadOptions() async {
    final loadedOptions = await StudyOptions.load(widget.deckId);
    if (!mounted) return;
    setState(() {
      options = loadedOptions;
      if (options.shuffled) {
        studyCards.shuffle();
      }
      choices = _buildChoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mode QCM"),
        actions: [
          IconButton(
            onPressed: (!isFinished && selectedChoice == null)
                ? () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => StudyOptionsSheet(
                        initialOptions: options,
                        onChanged: _onOptionsChanged,
                        onReset: _resetSession,
                      ),
                    );
                  }
                : null,
            icon: Icon(Icons.tune),
          ),
        ],
      ),
      body: (isFinished)
          ? StudyEndView(
              correctCount: studyCards.length - failedCards.length,
              totalCount: studyCards.length,
              onRetryFailed: failedCards.isEmpty ? null : _retryFailedCards,
              onReset: _resetSession,
            )
          : Center(
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
                        margin: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
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
            ),
    );
  }
}
