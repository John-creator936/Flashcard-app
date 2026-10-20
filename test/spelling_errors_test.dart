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

  group('changeAccent', () {
    test('umlaut retiré', () {
      expect(SpellingErrors.changeAccent('Mädchen'), 'Madchen');
    });
    test('cédille retirée', () {
      expect(SpellingErrors.changeAccent('garçon'), 'garcon');
    });
    test('plusieurs accents, plusieurs possibilités', () {
      expect(
        SpellingErrors.changeAccent('élève'),
        isIn(['elève', 'èlève', 'êlève', 'éleve', 'éléve']),
      );
    });
    test('pas d\'accent → null', () {
      expect(SpellingErrors.changeAccent('Haus'), isNull);
    });
    test('mot vide → null', () {
      expect(SpellingErrors.changeAccent(''), isNull);
    });
    test('umlaut majuscule', () {
      expect(SpellingErrors.changeAccent('Übung'), 'Ubung');
    });
  });
  group('toggleIeEi', () {
    test('ie → ei', () {
      expect(SpellingErrors.toggleIeEi('Brief'), 'Breif');
    });
    test('ei → ie', () {
      expect(SpellingErrors.toggleIeEi('receive'), 'recieve');
    });
    test('ei et ie dans le même mot', () {
      expect(SpellingErrors.toggleIeEi('Feier'), isIn(['Fieer', 'Feeir']));
    });
    test('ni ie ni ei → null', () {
      expect(SpellingErrors.toggleIeEi('Haus'), isNull);
    });
  });

  group('togglePhF', () {
    test('ph → f, majuscule conservée', () {
      expect(SpellingErrors.togglePhF('Physik'), 'Fysik');
    });
    test('ph → f, minuscule', () {
      expect(SpellingErrors.togglePhF('photo'), 'foto');
    });
    test('f → ph', () {
      expect(SpellingErrors.togglePhF('Hafen'), 'Haphen');
    });
    test('F majuscule → Ph', () {
      expect(SpellingErrors.togglePhF('Fisch'), 'Phisch');
    });
    test('ff : variantes absurdes filtrées → null', () {
      expect(SpellingErrors.togglePhF('Kartoffel'), isNull);
    });
    test('ni ph ni f → null', () {
      expect(SpellingErrors.togglePhF('Haus'), isNull);
    });
  });
}
