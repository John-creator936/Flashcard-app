class OcrLine {
  final String text;
  final double left;
  final double top;

  const OcrLine({required this.text, required this.left, required this.top});
}

class VocabularyParser {
  static const Map<String, String> _ocrFixes = {
    'ę': 'e',
    'ą': 'a',
    'į': 'i',
    'ų': 'u',
  };

  static String cleanText(String text) {
    String result = text;
    for (final entry in _ocrFixes.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    result = result.replaceAll(RegExp(r"\bI'"), "l'");
    return result.trim();
  }
}
