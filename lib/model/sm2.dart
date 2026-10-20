import 'dart:math';
import 'package:flashcard_app/model/app_clock.dart';
import 'package:flashcard_app/model/card.dart';

class SM2 {
  static const double minEaseFactor = 1.3;

  /// Formule de Woźniak : nouveau facteur selon la note q (0 à 5).
  static double _updatedEaseFactor(double ef, int q) {
    return max(ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)), minEaseFactor);
  }

  /// Applique une révision à une carte et renvoie la carte mise à jour.
  static Flashcard review(
    Flashcard card, {
    required bool isSuccess,
    required double weight,
  }) {
    final q = isSuccess ? 4 : 2;
    final newEaseFactor = _updatedEaseFactor(card.easeFactor, q);

    if (!isSuccess) {
      return card.copy(
        easeFactor: newEaseFactor,
        points: 0,
        intervalDays: 1,
        lastReviewedTime: AppClock.now(),
      );
    }

    final newPoints = card.points + weight;
    final double newInterval;
    if (newPoints <= 1) {
      newInterval = 1;
    } else if (newPoints <= 2) {
      newInterval = 6;
    } else {
      newInterval = card.intervalDays * pow(newEaseFactor, weight).toDouble();
    }

    return card.copy(
      easeFactor: newEaseFactor,
      points: newPoints,
      intervalDays: newInterval,
      lastReviewedTime: AppClock.now(),
    );
  }
}
