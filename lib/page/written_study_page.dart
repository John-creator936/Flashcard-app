import 'package:flashcard_app/model/card.dart';
import 'package:flutter/material.dart';

class WrittenStudyPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  const WrittenStudyPage({super.key, required this.flashcards});

  @override
  State<WrittenStudyPage> createState() => _WrittenStudyPageState();
}

class _WrittenStudyPageState extends State<WrittenStudyPage> {
  int currentCardIndex = 0;
  TextEditingController answerController = TextEditingController();
  bool? isCorrect;

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    setState(() {
      if (answerController.text ==
          widget.flashcards[currentCardIndex].definition) {
        isCorrect = true;
      } else {
        isCorrect = false;
      }
    });
  }

  void _nextCard() {
    if (currentCardIndex < widget.flashcards.length - 1) {
      setState(() {
        currentCardIndex++;
        isCorrect = null;
        answerController.text = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mode écrit")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.flashcards[currentCardIndex].term),
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
                ? Text(
                    "La bonne réponse était : ${widget.flashcards[currentCardIndex].definition}",
                  )
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
