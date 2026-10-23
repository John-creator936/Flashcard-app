import 'package:shared_preferences/shared_preferences.dart';

/// Les options d'un mode : inverser les côtés, mélanger, pièges d'orthographe.
///
/// Mémorisées par deck (et non par mode), avec `shared_preferences`.
class StudyOptions {
  final bool reversed;
  final bool shuffled;
  final bool spellingTraps;

  const StudyOptions({
    this.reversed = false,
    this.shuffled = false,
    this.spellingTraps = false,
  });

  /// Copie les options en remplaçant seulement les champs donnés.
  StudyOptions copy({bool? reversed, bool? shuffled, bool? spellingTraps}) =>
      StudyOptions(
        reversed: reversed ?? this.reversed,
        shuffled: shuffled ?? this.shuffled,
        spellingTraps: spellingTraps ?? this.spellingTraps,
      );

  /// Lit les options d'un deck. Une option jamais réglée vaut `false`.
  static Future<StudyOptions> load(int deckId) async {
    final prefs = await SharedPreferences.getInstance();
    final reversed = prefs.getBool('deck_${deckId}_reversed') ?? false;
    final shuffled = prefs.getBool('deck_${deckId}_shuffled') ?? false;
    final spellingTraps =
        prefs.getBool('deck_${deckId}_spellingTraps') ?? false;
    return StudyOptions(
      reversed: reversed,
      shuffled: shuffled,
      spellingTraps: spellingTraps,
    );
  }

  /// Enregistre les options d'un deck.
  Future<void> save(int deckId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('deck_${deckId}_reversed', reversed);
    await prefs.setBool('deck_${deckId}_shuffled', shuffled);
    await prefs.setBool('deck_${deckId}_spellingTraps', spellingTraps);
  }
}
