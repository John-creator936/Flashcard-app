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
}
