import 'dart:math';

/// Une ligne lue par ML Kit, avec la position de son coin supérieur gauche.
class OcrLine {
  final String text;
  final double left;
  final double top;

  const OcrLine({required this.text, required this.left, required this.top});
}

/// Un terme et sa définition. Sert à l'OCR et au partage de decks.
class VocabularyPair {
  final String term;
  final String definition;

  const VocabularyPair({required this.term, required this.definition});
}

/// Transforme les lignes lues sur une page de vocabulaire en paires.
///
/// Conçu pour les listes à deux colonnes (allemand à gauche, français à
/// droite). Les colonnes sont séparées par la position des lignes, et non
/// par un séparateur comme « - », qui n'est pas fiable dans un manuel.
class VocabularyParser {
  /// Lettres mal lues par ML Kit : le manuel ajoute sous certaines voyelles
  /// un signe qui indique leur prononciation, et l'OCR le lit comme un accent
  /// (ę au lieu de e).
  static const Map<String, String> _ocrFixes = {
    'ę': 'e',
    'ą': 'a',
    'į': 'i',
    'ų': 'u',
    'ė': 'e',
  };

  /// Corrige les erreurs de lecture connues : [_ocrFixes], et « I' » lu à la
  /// place de « l' ».
  static String cleanText(String text) {
    String result = text;
    for (final entry in _ocrFixes.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    result = result.replaceAll(RegExp(r"\bI'"), "l'");
    return result.trim();
  }

  /// Renvoie la position horizontale qui sépare les deux colonnes.
  ///
  /// C'est le milieu du plus grand écart entre les positions `left` triées.
  /// Avec moins de 2 lignes, tout reste dans la colonne de gauche.
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

  /// Une ligne continue l'entrée précédente si celle-ci finit par une virgule,
  /// ou si elle est entièrement entre parenthèses.
  static bool _isContinuation(String previous, String current) {
    return previous.endsWith(',') ||
        (current.startsWith('(') && current.endsWith(')'));
  }

  /// Trie une colonne de haut en bas et regroupe les entrées écrites
  /// sur plusieurs lignes.
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

  /// Une ligne est ignorée si ce n'est pas du vocabulaire : un numéro de page
  /// (« 112 ») ou un titre de section (« 10.3 Literatur »).
  static bool _isNoise(String text) {
    return RegExp(r'^\d+$').hasMatch(text) ||
        RegExp(r'^\d+\.\d+').hasMatch(text);
  }

  /// Renvoie les paires terme / définition lues sur la page.
  ///
  /// Les entrées sont associées par rang. Si une colonne en a plus que
  /// l'autre, les entrées en trop gardent un côté vide, que l'utilisateur
  /// complétera.
  static List<VocabularyPair> parse(List<OcrLine> lines) {
    final usefulLines = lines
        .where((line) => !_isNoise(cleanText(line.text)))
        .toList();
    final threshold = columnThreshold(usefulLines);
    final leftLines = usefulLines
        .where((line) => line.left < threshold)
        .toList();
    final rightLines = usefulLines
        .where((line) => line.left >= threshold)
        .toList();
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
