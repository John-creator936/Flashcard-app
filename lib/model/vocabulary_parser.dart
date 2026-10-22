import 'dart:math';

class OcrLine {
  final String text;
  final double left;
  final double top;

  const OcrLine({required this.text, required this.left, required this.top});
}

class VocabularyPair {
  final String term;
  final String definition;

  const VocabularyPair({required this.term, required this.definition});
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

  static bool _isContinuation(String previous, String current) {
    return previous.endsWith(',') ||
        (current.startsWith('(') && current.endsWith(')'));
  }

  static List<String> mergeEntries(List<OcrLine> column) {
    final sortedLines = [...column]..sort((a, b) => a.top.compareTo(b.top));
    List<String> entries = [];
    for (final line in sortedLines) {
      final text = cleanText(line.text);
      if (entries.isNotEmpty && _isContinuation(entries.last, text)) {
        entries.last = '${entries.last} $text';
      } else {
        entries.add(text);
      }
    }
    return entries;
  }

  static List<VocabularyPair> parse(List<OcrLine> lines) {
    final threshold = columnThreshold(lines);
    final leftLines = lines.where((line) => line.left < threshold).toList();
    final rightLines = lines.where((line) => line.left >= threshold).toList();
    final terms = mergeEntries(leftLines);
    final definitions = mergeEntries(rightLines);
    final pairCount = max(terms.length, definitions.length);
    final List<VocabularyPair> pairs = [];
    for (int i = 0; i < pairCount; i++) {
      final term = (i < terms.length) ? terms[i] : '';
      final definition = (i < definitions.length) ? definitions[i] : '';
      pairs.add(VocabularyPair(term: term, definition: definition));
    }
    return pairs;
  }
}
