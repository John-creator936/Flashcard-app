import 'dart:math';
import 'package:flashcard_app/model/app_clock.dart';
import 'package:flashcard_app/model/card.dart';

/// Algorithme SM-2 de Woźniak, adapté avec des poids par mode.
///
/// Dans SM-2, l'intervalle (nombre de jours avant la prochaine révision)
/// dépend du nombre de révisions réussies d'affilée.
/// Ici, ce nombre est remplacé par des « points » : chaque mode en rapporte
/// selon sa difficulté (écrit 1, QCM et flashcard 0,5).
class SM2 {
  /// Facteur de facilité minimal fixé par Woźniak, pour que l'intervalle
  /// d'une carte difficile continue d'augmenter.
  static const double minEaseFactor = 1.3;

  /// Formule de Woźniak : nouveau facteur selon la note q (0 à 5).
  static double _updatedEaseFactor(double ef, int q) {
    return max(ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)), minEaseFactor);
  }

  /// Applique une révision à une carte et renvoie la carte mise à jour.
  ///
  /// Une réussite vaut la note 4 et un échec la note 2. Un échec remet
  /// les points à zéro et l'intervalle à 1 jour. Sinon, l'intervalle est de
  /// 1 jour jusqu'à 1 point, de 6 jours jusqu'à 2 points, puis il est
  /// multiplié par le facteur élevé à la puissance du poids.
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
