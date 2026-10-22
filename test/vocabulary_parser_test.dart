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

  OcrLine textLine(String text, double top) =>
      OcrLine(text: text, left: 0, top: top);

  group('mergeEntries', () {
    test('lignes triées de haut en bas', () {
      final lines = [
        textLine('das Werk, e', 446),
        textLine('der Kern, e', 228),
      ];
      expect(VocabularyParser.mergeEntries(lines), [
        'der Kern, e',
        'das Werk, e',
      ]);
    });
    test('suite après une virgule', () {
      final lines = [
        textLine('unternehmen unternimmt, unternahm,', 1168),
        textLine('hat unternommen', 1312),
        textLine('das Unternehmen, -', 1443),
      ];
      expect(VocabularyParser.mergeEntries(lines), [
        'unternehmen unternimmt, unternahm, hat unternommen',
        'das Unternehmen, -',
      ]);
    });
    test('ligne entièrement entre parenthèses', () {
      final lines = [
        textLine('der Ingenieur, e / die -in', 3263),
        textLine('(prononc. fr.)', 3341),
      ];
      expect(VocabularyParser.mergeEntries(lines), [
        'der Ingenieur, e / die -in (prononc. fr.)',
      ]);
    });
    test('parenthèse seulement au début : entrée à part', () {
      final lines = [
        textLine("1. l'exploitation, l'usine 2. l'activite", 888),
        textLine('(mettre) hors service, en service', 965),
      ];
      expect(VocabularyParser.mergeEntries(lines), hasLength(2));
    });
    test('texte nettoyé', () {
      expect(VocabularyParser.mergeEntries([textLine('der Kęrn, e', 0)]), [
        'der Kern, e',
      ]);
    });
    test('colonne vide', () {
      expect(VocabularyParser.mergeEntries([]), isEmpty);
    });
  });
}
