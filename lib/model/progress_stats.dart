/// Les chiffres de « Ma progression » sur l'accueil.
///
/// [reviewedToday] compte une activité et chevauche les trois autres chiffres,
/// qui forment ensemble toutes les cartes utilisées dans au moins un deck.
class ProgressStats {
  final int reviewedToday;
  final int newCount;
  final int learningCount;
  final int masteredCount;

  const ProgressStats({
    required this.reviewedToday,
    required this.newCount,
    required this.learningCount,
    required this.masteredCount,
  });

  /// Intervalle à partir duquel une carte est « maîtrisée », repris d'Anki,
  /// qui appelle *mature* une carte d'intervalle 21 jours ou plus.
  static const int masteredThreshold = 21;
}
