import 'dart:math';

typedef SpellingRule = String? Function(String word);

class SpellingErrors {
  static const _vowels = 'aeiouyàâäéèêëîïôöûüù';
  static const _neverDoubled = 'hjqwxy'; //TODO: Vérifier source
  static const Map<String, List<String>> _accentConfusions = {
    'é': ['e', 'è', 'ê'],
    'è': ['e', 'é'],
    'ê': ['e', 'è'],
    'à': ['a'],
    'ç': ['c'],
    'ä': ['a'],
    'ö': ['o'],
    'ü': ['u'],
  };
  static const _maxAttempts = 20;

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

  static String? _pickRandom(List<String> possibleErrors) {
    if (possibleErrors.isEmpty) return null;
    return possibleErrors[Random().nextInt(possibleErrors.length)];
  }

  static String? toggleDoubleConsonant(String word) {
    final List<String> possibleErrors = [];
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
    return _pickRandom(possibleErrors);
  }

  static String? changeAccent(String word) {
    final List<String> possibleErrors = [];
    for (int i = 0; i <= word.length - 1; i++) {
      final letter = word[i];
      final lowerLetter = letter.toLowerCase();
      final isUpper = letter != lowerLetter;
      if (_accentConfusions.containsKey(lowerLetter)) {
        for (final confusion in _accentConfusions[lowerLetter]!) {
          final replacement = isUpper ? confusion.toUpperCase() : confusion;
          possibleErrors.add(
            word.substring(0, i) + replacement + word.substring(i + 1),
          );
        }
      }
    }
    return _pickRandom(possibleErrors);
  }

  static List<String> _replaceEachOccurrence(
    String word,
    String from,
    String to,
  ) {
    final List<String> variants = [];
    final lowerWord = word.toLowerCase();
    int i = lowerWord.indexOf(from);
    while (i != -1) {
      final bool isUpper = word[i] != lowerWord[i];
      final replacement = isUpper ? to[0].toUpperCase() + to.substring(1) : to;
      variants.add(
        word.substring(0, i) + replacement + word.substring(i + from.length),
      );
      i = lowerWord.indexOf(from, i + 1);
    }
    return variants;
  }

  static String? toggleIeEi(String word) => _pickRandom([
    ..._replaceEachOccurrence(word, 'ie', 'ei'),
    ..._replaceEachOccurrence(word, 'ei', 'ie'),
  ]);

  static String? togglePhF(String word) => _pickRandom([
    ..._replaceEachOccurrence(
      word,
      'f',
      'ph',
    ).where((variant) => !variant.contains('phf') && !variant.contains('fph')),
    ..._replaceEachOccurrence(word, 'ph', 'f'),
  ]);

  static String? deleteLetter(String word) {
    final List<String> possibleErrors = [];
    for (int i = 1; i <= word.length - 1; i++) {
      possibleErrors.add(word.substring(0, i) + word.substring(i + 1));
    }
    return _pickRandom(possibleErrors);
  }

  static String? swapAdjacentLetters(String word) {
    final List<String> possibleErrors = [];
    for (int i = 0; i <= word.length - 2; i++) {
      if (word[i] != word[i + 1] &&
          (i > 0 || word[i] != word[i].toUpperCase())) {
        possibleErrors.add(
          word.substring(0, i) + word[i + 1] + word[i] + word.substring(i + 2),
        );
      }
    }
    return _pickRandom(possibleErrors);
  }

  static String? _replaceAtEnd(
    String word,
    String from,
    String to, {
    int minPrefix = 0,
  }) {
    if (word.length - from.length >= minPrefix) {
      final lowerWord = word.toLowerCase();
      if (lowerWord.endsWith(from)) {
        int i = word.length - from.length;
        return word.substring(0, i) + to;
      }
    }
    return null;
  }

  static String? _replaceAtStart(String word, String from, String to) {
    final lowerWord = word.toLowerCase();
    if (lowerWord.startsWith(from)) {
      final bool isUpper = word[0] != lowerWord[0];
      String result = to + word.substring(from.length);
      if (isUpper && result.isNotEmpty) {
        result = result[0].toUpperCase() + result.substring(1);
      }
      return result;
    }
    return null;
  }

  static String? addUmlaut(String word) => _pickRandom([
    ..._replaceEachOccurrence(word, 'a', 'ä'),
    ..._replaceEachOccurrence(word, 'o', 'ö'),
    ..._replaceEachOccurrence(
      word,
      'u',
      'ü',
    ).where((variant) => !variant.toLowerCase().contains('eü')),
  ]);

  static String? devoiceFinalConsonant(String word) => _pickRandom(
    [
      _replaceAtEnd(word, 'd', 't'),
      _replaceAtEnd(word, 'b', 'p'),
    ].whereType<String>().toList(),
  );

  static String? simplifyTzCk(String word) => _pickRandom([
    ..._replaceEachOccurrence(word, 'tz', 'z'),
    ..._replaceEachOccurrence(word, 'ck', 'k'),
  ]);

  static String? toggleVF(String word) => _pickRandom([
    ..._replaceEachOccurrence(word, 'v', 'f'),
    ..._replaceEachOccurrence(word, 'f', 'v').where(
      (variant) =>
          !variant.toLowerCase().contains('vf') &&
          !variant.toLowerCase().contains('fv'),
    ),
  ]);

  static String? dropSilentLetter(String word) => _pickRandom(
    [
      _replaceAtEnd(word, 't', ''),
      _replaceAtEnd(word, 'd', ''),
      _replaceAtEnd(word, 's', ''),
      _replaceAtEnd(word, 'x', ''),
      _replaceAtEnd(word, 'p', ''),
      _replaceAtStart(word, 'h', ''),
    ].whereType<String>().toList(),
  );

  static String? toggleFrenchEnding(String word) => _pickRandom(
    [
      _replaceAtEnd(word, 'é', 'er'),
      _replaceAtEnd(word, 'é', 'ez'),
      _replaceAtEnd(word, 'er', 'é'),
      _replaceAtEnd(word, 'er', 'ez'),
      _replaceAtEnd(word, 'ez', 'é'),
      _replaceAtEnd(word, 'ez', 'er'),
    ].whereType<String>().toList(),
  );

  static String? toggleEntAnt(String word) => _pickRandom(
    [
      _replaceAtEnd(word, 'ent', 'ant', minPrefix: 3),
      _replaceAtEnd(word, 'ant', 'ent', minPrefix: 3),
    ].whereType<String>().toList(),
  );

  static String? toggleEauAuO(String word) => _pickRandom(
    (word.toLowerCase().contains('eau'))
        ? [
            ..._replaceEachOccurrence(word, 'eau', 'au'),
            ..._replaceEachOccurrence(word, 'eau', 'o'),
          ]
        : [
            ..._replaceEachOccurrence(word, 'au', 'o'),
            ..._replaceEachOccurrence(
              word,
              'au',
              'eau',
            ).where((variant) => !variant.toLowerCase().startsWith('eau')),
          ],
  );

  static String? dropEnglishSilentLetter(String word) => _pickRandom(
    [
      _replaceAtEnd(word, 'mb', 'm'),
      _replaceAtStart(word, 'kn', 'n'),
      _replaceAtStart(word, 'wr', 'r'),
      _replaceAtStart(word, 'wh', 'w'),
    ].whereType<String>().toList(),
  );

  static String? toggleAbleIble(String word) => _pickRandom(
    [
      _replaceAtEnd(word, 'able', 'ible', minPrefix: 3),
      _replaceAtEnd(word, 'ible', 'able', minPrefix: 3),
    ].whereType<String>().toList(),
  );

  static const List<SpellingRule> _mainRules = [
    toggleFirstLetterCase,
    toggleDoubleConsonant,
    changeAccent,
    toggleIeEi,
    togglePhF,
  ];
  static const List<SpellingRule> _backupRules = [
    deleteLetter,
    swapAdjacentLetters,
  ];
  static const Map<String, List<SpellingRule>> _languageRules = {
    'de': [addUmlaut, devoiceFinalConsonant, simplifyTzCk, toggleVF],
    'fr': [dropSilentLetter, toggleFrenchEnding, toggleEntAnt, toggleEauAuO],
    'en': [dropEnglishSilentLetter, toggleAbleIble, toggleEntAnt],
  };

  static void _addErrors(
    String answer,
    List<SpellingRule> rules,
    Set<String> errors,
    int count,
  ) {
    final shuffledRules = [...rules]..shuffle();
    int attempts = 0;
    while (errors.length < count && attempts < _maxAttempts) {
      final rule = shuffledRules[attempts % shuffledRules.length];
      final error = rule(answer);
      if (error != null && error != answer && error.isNotEmpty) {
        errors.add(error);
      }
      attempts++;
    }
  }

  static List<String> generate(
    String answer, {
    String? language,
    int count = 3,
  }) {
    final Set<String> errors = {};
    final mainRules = [..._mainRules, ...?_languageRules[language]];
    _addErrors(answer, mainRules, errors, count);
    _addErrors(answer, _backupRules, errors, count);
    return errors.toList();
  }
}
