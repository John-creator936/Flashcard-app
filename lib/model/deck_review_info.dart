import 'dart:math';
import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/review_limit.dart';
import 'package:flashcard_app/model/review_scheduler.dart';

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
