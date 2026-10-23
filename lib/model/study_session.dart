import 'package:shared_preferences/shared_preferences.dart';

/// L'avancement d'une session d'entraînement, pour la reprendre plus tard.
///
/// Une session par deck et par mode. [deckCardIds] garde les cartes du deck
/// au moment de l'enregistrement : si le deck a changé depuis, la session
/// n'est plus valable et on recommence à zéro.
class StudySession {
  final List<int> studyCardIds;
  final int currentCardIndex;
  final List<int> failedCardIds;
  final List<int> deckCardIds;

  const StudySession({
    required this.studyCardIds,
    required this.currentCardIndex,
    required this.failedCardIds,
    required this.deckCardIds,
  });

  static String _prefix(int deckId, String mode) => 'session_${deckId}_$mode';

  /// Enregistre la session. `shared_preferences` ne connaît pas les listes
  /// d'entiers, d'où la conversion des ids en texte.
  Future<void> save(int deckId, String mode) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _prefix(deckId, mode);
    await prefs.setInt('${prefix}_currentCardIndex', currentCardIndex);
    await prefs.setStringList(
      '${prefix}_studyCardIds',
      studyCardIds.map((id) => id.toString()).toList(),
    );
    await prefs.setStringList(
      '${prefix}_failedCardIds',
      failedCardIds.map((id) => id.toString()).toList(),
    );
    await prefs.setStringList(
      '${prefix}_deckCardIds',
      deckCardIds.map((id) => id.toString()).toList(),
    );
  }

  /// Lit la session d'un deck et d'un mode, ou `null` s'il n'y en a pas.
  static Future<StudySession?> load(int deckId, String mode) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _prefix(deckId, mode);

    final index = prefs.getInt('${prefix}_currentCardIndex');
    if (index == null) {
      return null;
    }
    final studyCardIds = prefs.getStringList('${prefix}_studyCardIds') ?? [];
    final failedCardIds = prefs.getStringList('${prefix}_failedCardIds') ?? [];
    final deckCardIds = prefs.getStringList('${prefix}_deckCardIds') ?? [];

    return StudySession(
      studyCardIds: studyCardIds.map((text) => int.parse(text)).toList(),
      currentCardIndex: index,
      failedCardIds: failedCardIds.map((text) => int.parse(text)).toList(),
      deckCardIds: deckCardIds.map((text) => int.parse(text)).toList(),
    );
  }

  /// Efface la session, par exemple quand elle est terminée sans échec.
  static Future<void> clear(int deckId, String mode) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _prefix(deckId, mode);
    await prefs.remove('${prefix}_studyCardIds');
    await prefs.remove('${prefix}_currentCardIndex');
    await prefs.remove('${prefix}_failedCardIds');
    await prefs.remove('${prefix}_deckCardIds');
  }
}
