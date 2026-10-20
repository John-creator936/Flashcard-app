import 'package:flashcard_app/model/deck_review_info.dart';
import 'package:flashcard_app/page/flashcard_study_page.dart';
import 'package:flashcard_app/page/multiple_choice_study_page.dart';
import 'package:flashcard_app/page/written_study_page.dart';
import 'package:flutter/material.dart';

Future<void> showReviewModeSheet(
  BuildContext context, {
  required int deckId,
  required DeckReviewInfo info,
  required VoidCallback onFinished,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("Mode flashcard"),
            onTap: () async {
              Navigator.pop(sheetContext);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlashcardStudyPage(
                    flashcards: info.reviewCards,
                    deckId: deckId,
                    isReview: true,
                  ),
                ),
              );
              onFinished();
            },
          ),
          ListTile(
            title: Text("Mode écrit"),
            onTap: () async {
              Navigator.pop(sheetContext);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WrittenStudyPage(
                    flashcards: info.reviewCards,
                    deckId: deckId,
                    isReview: true,
                  ),
                ),
              );
              onFinished();
            },
          ),
          ListTile(
            enabled: info.cards.length > 1,
            title: Text("Mode QCM"),
            subtitle: info.cards.length > 1
                ? null
                : Text("Il faut au moins 2 cartes"),
            onTap: () async {
              Navigator.pop(sheetContext);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultipleChoiceStudyPage(
                    flashcards: info.reviewCards,
                    allCards: info.cards,
                    deckId: deckId,
                    isReview: true,
                  ),
                ),
              );
              onFinished();
            },
          ),
        ],
      ),
    ),
  );
}
