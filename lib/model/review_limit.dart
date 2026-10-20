import 'package:shared_preferences/shared_preferences.dart';

class ReviewLimit {
  static const int defaultLimit = 30;

  static String _key(int deckId) => 'deck_${deckId}_daily_limit';

  static Future<int> load(int deckId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(deckId);
    return prefs.getInt(key) ?? defaultLimit;
  }

  static Future<void> save(int deckId, int limit) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(deckId);
    await prefs.setInt(key, limit);
  }
}
