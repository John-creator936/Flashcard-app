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

  static double columnThreshold(List<OcrLine> lines) {
    final List<double> sortedLefts = lines.map((line) => line.left).toList()
      ..sort();
    double maxGap = 0.0;
    double threshold = 0.0;
    if (lines.length < 2) {
      return double.infinity;
    }
    for (int i = 0; i < lines.length - 1; i++) {
      double gap = sortedLefts[i + 1] - sortedLefts[i];
      if (gap > maxGap) {
        maxGap = gap;
        threshold = (sortedLefts[i + 1] + sortedLefts[i]) / 2;
      }
    }
    return threshold;
  }
}
