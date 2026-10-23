import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/page/flashcard_study_page.dart';
import 'package:flashcard_app/page/multiple_choice_study_page.dart';
import 'package:flashcard_app/page/written_study_page.dart';
import 'package:flutter/material.dart';

/// Ouvre le menu de choix du mode, en entraînement libre ou en révision.
Future<void> showStudyModeSheet(
  BuildContext context, {
  required Deck deck,
  required List<Flashcard> flashcards,
  List<Flashcard>? allCards,
  bool isReview = false,
  VoidCallback? onFinished,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (sheetContext) {
      Future<void> openMode(Widget page) async {
        Navigator.pop(sheetContext);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
        onFinished?.call();
      }

      final bool canStudy = flashcards.isNotEmpty;
      final bool canQuiz = (allCards ?? flashcards).length > 1;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              enabled: canStudy,
              title: Text("Mode flashcard"),
              subtitle: canStudy ? null : Text("Ajoute au moins une carte"),
              onTap: () => openMode(
                FlashcardStudyPage(
                  flashcards: flashcards,
                  deckId: deck.id!,
                  isReview: isReview,
                ),
              ),
            ),
            ListTile(
              enabled: canStudy,
              title: Text("Mode écrit"),
              subtitle: canStudy ? null : Text("Ajoute au moins une carte"),
              onTap: () => openMode(
                WrittenStudyPage(
                  flashcards: flashcards,
                  deckId: deck.id!,
                  isReview: isReview,
                ),
              ),
            ),
            ListTile(
              enabled: canQuiz,
              title: Text("Mode QCM"),
              subtitle: canQuiz ? null : Text("Il faut au moins 2 cartes"),
              onTap: () => openMode(
                MultipleChoiceStudyPage(
                  flashcards: flashcards,
                  deck: deck,
                  isReview: isReview,
                  allCards: allCards,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
