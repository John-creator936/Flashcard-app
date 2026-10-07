import 'package:shared_preferences/shared_preferences.dart';

class StudyOptions {
  final bool reversed;
  final bool shuffled;

  const StudyOptions({this.reversed = false, this.shuffled = false});

  StudyOptions copy({bool? reversed, bool? shuffled}) => StudyOptions(
    reversed: reversed ?? this.reversed,
    shuffled: shuffled ?? this.shuffled,
  );

  static Future<StudyOptions> load(int deckId) async {
    final prefs = await SharedPreferences.getInstance();
    final reversed = prefs.getBool('deck_${deckId}_reversed') ?? false;
    final shuffled = prefs.getBool('deck_${deckId}_shuffled') ?? false;
    return StudyOptions(reversed: reversed, shuffled: shuffled);
  }

  Future<void> save(int deckId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('deck_${deckId}_reversed', reversed);
    await prefs.setBool('deck_${deckId}_shuffled', shuffled);
  }
}
