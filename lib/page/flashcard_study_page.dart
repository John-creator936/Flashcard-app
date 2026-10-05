import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/widget/study_options.dart';
import 'package:flashcard_app/widget/study_options_sheet.dart';
import 'package:flutter/material.dart';

class FlashcardStudyPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  const FlashcardStudyPage({super.key, required this.flashcards});

  @override
  State<FlashcardStudyPage> createState() => _FlashcardStudyPageState();
}

class _FlashcardStudyPageState extends State<FlashcardStudyPage> {
  late List<Flashcard> studyCards;
  StudyOptions options = const StudyOptions();
  int currentCardIndex = 0;
  bool isFlipped = false;

  @override
  void initState() {
    super.initState();
    studyCards = widget.flashcards.toList();
  }

  void _nextCard() {
    if (currentCardIndex < studyCards.length - 1) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Révision"),
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
