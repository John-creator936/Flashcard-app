import 'package:shared_preferences/shared_preferences.dart';

class StudyOptions {
  final bool reversed;
  final bool shuffled;
  final bool spellingTraps;

  const StudyOptions({
    this.reversed = false,
    this.shuffled = false,
    this.spellingTraps = false,
  });

  StudyOptions copy({bool? reversed, bool? shuffled, bool? spellingTraps}) =>
      StudyOptions(
        reversed: reversed ?? this.reversed,
        shuffled: shuffled ?? this.shuffled,
        spellingTraps: spellingTraps ?? this.spellingTraps,
      );

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

  Future<void> save(int deckId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('deck_${deckId}_reversed', reversed);
    await prefs.setBool('deck_${deckId}_shuffled', shuffled);
    await prefs.setBool('deck_${deckId}_spellingTraps', spellingTraps);
  }
}
