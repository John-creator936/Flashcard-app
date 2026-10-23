import 'package:shared_preferences/shared_preferences.dart';

/// Le nombre maximal de cartes à réviser par jour, propre à chaque deck.
///
/// Enregistré avec `shared_preferences`, sous la clé `deck_<id>_daily_limit`.
class ReviewLimit {
  static const int defaultLimit = 30;

  static String _key(int deckId) => 'deck_${deckId}_daily_limit';

  /// Lit la limite d'un deck, ou [defaultLimit] si elle n'a jamais été réglée.
  static Future<int> load(int deckId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(deckId);
    return prefs.getInt(key) ?? defaultLimit;
  }

  /// Enregistre la limite d'un deck.
  static Future<void> save(int deckId, int limit) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(deckId);
    await prefs.setInt(key, limit);
  }
}
