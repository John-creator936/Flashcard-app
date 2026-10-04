import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/widget/study_options.dart';
import 'package:flashcard_app/widget/study_options_sheet.dart';
import 'package:flutter/material.dart';

class WrittenStudyPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  const WrittenStudyPage({super.key, required this.flashcards});

  @override
  State<WrittenStudyPage> createState() => _WrittenStudyPageState();
}

class _WrittenStudyPageState extends State<WrittenStudyPage> {
  late List<Flashcard> studyCards;
  StudyOptions options = const StudyOptions();
  int currentCardIndex = 0;
  TextEditingController answerController = TextEditingController();
  bool? isCorrect;

  @override
  void initState() {
    super.initState();
    studyCards = widget.flashcards.toList();
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
    if (currentCardIndex < studyCards.length - 1) {
      setState(() {
        currentCardIndex++;
        isCorrect = null;
        answerController.text = "";
      });
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
  }

  String get questionText => options.reversed
      ? studyCards[currentCardIndex].definition
      : studyCards[currentCardIndex].term;
  String get expectedAnswer => options.reversed
      ? studyCards[currentCardIndex].term
      : studyCards[currentCardIndex].definition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mode écrit"),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => StudyOptionsSheet(
                  initialOptions: options,
                  onChanged: _onOptionsChanged,
                ),
              );
            },
            icon: Icon(Icons.tune),
          ),
        ],
      ),
      body: Center(
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
                  IconButton(onPressed: _checkAnswer, icon: Icon(Icons.check)),
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
      ),
    );
  }
}
