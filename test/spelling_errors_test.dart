import 'package:flashcard_app/model/spelling_errors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toggleFirstLetterCase', () {
    test('majuscule → minuscule', () {
      expect(SpellingErrors.toggleFirstLetterCase('Haus'), 'haus');
    });
    test('minuscule → majuscule', () {
      expect(SpellingErrors.toggleFirstLetterCase('lundi'), 'Lundi');
    });
    test('lettre accentuée', () {
      expect(SpellingErrors.toggleFirstLetterCase('élève'), 'Élève');
    });
    test('mot d\'une seule lettre', () {
      expect(SpellingErrors.toggleFirstLetterCase('a'), 'A');
    });
    test('commence par un chiffre → null', () {
      expect(SpellingErrors.toggleFirstLetterCase('3D'), isNull);
    });
    test('mot vide → null', () {
      expect(SpellingErrors.toggleFirstLetterCase(''), isNull);
    });
  });

  group('toggleDoubleConsonant', () {
    test('simplifie une consonne doublée', () {
      expect(SpellingErrors.toggleDoubleConsonant('Kartoffeln'), 'Kartofeln');
    });
    test('double une consonne finale après une voyelle', () {
      expect(SpellingErrors.toggleDoubleConsonant('Haus'), 'Hauss');
    });
    test('plusieurs possibilités', () {
      expect(
        SpellingErrors.toggleDoubleConsonant('Tomate'),
        isIn(['Tommate', 'Tomatte']),
      );
    });
    test('les deux sens peuvent sortir', () {
      expect(
        SpellingErrors.toggleDoubleConsonant('Bagger'),
        isIn(['Bager', 'Baggerr']),
      );
    });
    test('le tirage varie', () {
      final results = <String?>{};
      for (int i = 0; i < 50; i++) {
        results.add(SpellingErrors.toggleDoubleConsonant('Tomate'));
      }
      expect(results, {'Tommate', 'Tomatte'});
    });
    test('consonne suivie d\'une autre consonne → null', () {
      expect(SpellingErrors.toggleDoubleConsonant('lundi'), isNull);
    });
    test('lettre jamais doublée (h) → null', () {
      expect(SpellingErrors.toggleDoubleConsonant('Ehe'), isNull);
    });
    test('pas de consonne doublable → null', () {
      expect(SpellingErrors.toggleDoubleConsonant('ja'), isNull);
    });
    test('mot vide → null', () {
      expect(SpellingErrors.toggleDoubleConsonant(''), isNull);
    });
  });
}
