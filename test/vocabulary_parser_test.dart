import 'package:flashcard_app/model/vocabulary_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cleanText', () {
    test('point sous la lettre lu comme une cédille', () {
      expect(VocabularyParser.cleanText('der Kęrn, e'), 'der Kern, e');
    });
    test('plusieurs lettres dans un mot', () {
      expect(
        VocabularyParser.cleanText('erfįndet, erfąnd'),
        'erfindet, erfand',
      );
    });
    test("I' en début de mot → l'", () {
      expect(
        VocabularyParser.cleanText("1. I'exploitation, I'usine 2. l'activte"),
        "1. l'exploitation, l'usine 2. l'activte",
      );
    });
    test('un I normal ne change pas', () {
      expect(
        VocabularyParser.cleanText('die Industrie, n'),
        'die Industrie, n',
      );
    });
    test('espaces en trop retirés', () {
      expect(VocabularyParser.cleanText('  la machine  '), 'la machine');
    });
  });

  OcrLine lineAt(double left) => OcrLine(text: '', left: left, top: 0);

  group('columnThreshold', () {
    test('deux colonnes : frontière au milieu du plus grand écart', () {
      final lines = [
        1544,
        275,
        593,
        1853,
        360,
      ].map((x) => lineAt(x.toDouble())).toList();
      expect(VocabularyParser.columnThreshold(lines), 1068.5);
    });
    test('deux lignes', () {
      expect(VocabularyParser.columnThreshold([lineAt(100), lineAt(500)]), 300);
    });
    test('une seule ligne → infini', () {
      expect(VocabularyParser.columnThreshold([lineAt(100)]), double.infinity);
    });
    test('aucune ligne → infini', () {
      expect(VocabularyParser.columnThreshold([]), double.infinity);
    });
  });
}
