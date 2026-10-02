import 'package:flashcard_app/model/card.dart';
import 'package:flutter/material.dart';

class FlashcardStudyPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  const FlashcardStudyPage({super.key, required this.flashcards});

  @override
  State<FlashcardStudyPage> createState() => _FlashcardStudyPageState();
}

class _FlashcardStudyPageState extends State<FlashcardStudyPage> {
  int currentCardIndex = 0;
  bool isFlipped = false;

  void _nextCard() {
    if (currentCardIndex < widget.flashcards.length - 1) {
      setState(() {
        currentCardIndex++;
        isFlipped = false;
      });
    }
  }

  void _previousCard() {
    if (currentCardIndex > 0) {
      setState(() {
        currentCardIndex--;
        isFlipped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Révision")),
      body: Column(
        children: [
          GestureDetector(
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
              child: (isFlipped)
                  ? Text(
                      widget.flashcards[currentCardIndex].definition,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight(400),
                      ),
                    )
                  : Text(
                      widget.flashcards[currentCardIndex].term,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight(400),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _previousCard,
                icon: Icon(Icons.arrow_left),
              ),
              IconButton(onPressed: _nextCard, icon: Icon(Icons.arrow_right)),
            ],
          ),
        ],
      ),
    );
  }
}
