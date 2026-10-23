import 'package:flashcard_app/model/card.dart';

/// Choisit les cartes à proposer dans une Révision.
///
/// Les jours sont comptés en jours du calendrier : une carte prévue
/// « demain » est due dès minuit, quelle que soit l'heure de la révision.
class ReviewScheduler {
  /// Retire l'heure d'une date pour ne garder que le jour.
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Une carte est nouvelle si elle n'a jamais été révisée.
  static bool isNew(Flashcard card) => card.lastReviewedTime == null;

  /// Nombre de jours du calendrier depuis la dernière révision.
  /// Seulement pour une carte déjà révisée.
  static int elapsedDays(Flashcard card, DateTime now) =>
      _dateOnly(now).difference(_dateOnly(card.lastReviewedTime!)).inDays;

  /// Une carte est due si elle a déjà été révisée et que son intervalle
  /// est écoulé. Une carte nouvelle n'est jamais « due ».
  static bool isDue(Flashcard card, DateTime now) =>
      (!isNew(card) && elapsedDays(card, now) >= card.intervalDays);

  /// Retard relatif d'une carte : jours écoulés divisés par l'intervalle prévu.
  static double overdueRatio(Flashcard card, DateTime now) =>
      elapsedDays(card, now) / card.intervalDays;

  /// Renvoie les cartes à réviser, dans l'ordre et dans la limite donnée.
  ///
  /// D'abord les cartes dues, de la plus en retard à la moins en retard,
  /// puis les nouvelles cartes. `limit` est le nombre de cartes encore
  /// autorisées aujourd'hui.
  static List<Flashcard> cardsToReview(
    List<Flashcard> cards,
    DateTime now,
    int limit,
  ) {
    List<Flashcard> dueCards = cards.where((card) => isDue(card, now)).toList();
    // Du plus grand retard au plus petit
    dueCards.sort(
      (a, b) => overdueRatio(b, now).compareTo(overdueRatio(a, now)),
    );
    List<Flashcard> newCards = cards.where((card) => isNew(card)).toList();
    List<Flashcard> reviewCards = [...dueCards, ...newCards];
    return reviewCards.take(limit).toList();
  }
}
