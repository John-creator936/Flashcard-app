import 'dart:math';
import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/review_limit.dart';
import 'package:flashcard_app/model/review_scheduler.dart';

/// Les cartes d'un deck et ce qu'il reste à réviser aujourd'hui.
///
/// Regroupe les calculs utilisés à la fois par l'accueil et par la page du deck.
class DeckReviewInfo {
  final List<Flashcard> cards;
  final int dailyLimit;
  final int remainingToday;
  final List<Flashcard> reviewCards;

  const DeckReviewInfo({
    required this.cards,
    required this.dailyLimit,
    required this.remainingToday,
    required this.reviewCards,
  });

  /// Charge les cartes, la limite du jour et les cartes à réviser d'un deck.
  static Future<DeckReviewInfo> load(int deckId, DateTime now) async {
    final loadedCards = await CardRepository().readCardsByDeck(deckId);
    final loadedLimit = await ReviewLimit.load(deckId);
    final reviewedToday = await CardRepository().countReviewedToday(
      deckId,
      now,
    );
    final remainingToday = max(0, loadedLimit - reviewedToday);
    final reviewCards = ReviewScheduler.cardsToReview(
      loadedCards,
      now,
      remainingToday,
    );
    return DeckReviewInfo(
      cards: loadedCards,
      dailyLimit: loadedLimit,
      remainingToday: remainingToday,
      reviewCards: reviewCards,
    );
  }
}
