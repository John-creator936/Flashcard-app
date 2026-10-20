import 'dart:math';

class SpellingErrors {
  static const _vowels = 'aeiouyàâäéèêëîïôöûüù';
  static const _neverDoubled = 'hjqwxy'; //TODO: Vérifier source

  static String? toggleFirstLetterCase(String word) {
    if (word.isEmpty) return null;
    final firstLetter = word[0];
    final toggledLetter = (firstLetter == firstLetter.toUpperCase())
        ? firstLetter.toLowerCase()
        : firstLetter.toUpperCase();
    if (toggledLetter == firstLetter) return null;
    final rest = word.substring(1);
    return toggledLetter + rest;
  }

  static bool _isVowel(String letter) =>
      (_vowels.contains(letter.toLowerCase()));

  static bool _isDoublableConsonant(String letter) {
    if (letter.toLowerCase() == letter.toUpperCase()) return false;
    if (_isVowel(letter)) return false;
    if (_neverDoubled.contains(letter.toLowerCase())) return false;
    return true;
  }

  static String? toggleDoubleConsonant(String word) {
    final possibleErrors = [];
    for (int i = 0; i <= word.length - 2; i++) {
      final letter = word[i];
      if (_isDoublableConsonant(letter) && word[i + 1] == letter) {
        possibleErrors.add(word.substring(0, i) + word.substring(i + 1));
      }
    }
    for (int i = 1; i <= word.length - 1; i++) {
      final letter = word[i];
      if (_isDoublableConsonant(letter) && _isVowel(word[i - 1])) {
        if (i == word.length - 1 || _isVowel(word[i + 1])) {
          possibleErrors.add(word.substring(0, i) + letter + word.substring(i));
        }
      }
    }
    if (possibleErrors.isEmpty) return null;
    return possibleErrors[Random().nextInt(possibleErrors.length)];
  }
}
