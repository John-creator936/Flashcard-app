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
  group('deleteLetter', () {
    test('ne supprime jamais la première lettre', () {
      expect(SpellingErrors.deleteLetter('Haus'), isIn(['Hus', 'Has', 'Hau']));
    });
    test('mot de deux lettres', () {
      expect(SpellingErrors.deleteLetter('ja'), 'j');
    });
    test('une seule lettre → null', () {
      expect(SpellingErrors.deleteLetter('a'), isNull);
    });
    test('mot vide → null', () {
      expect(SpellingErrors.deleteLetter(''), isNull);
    });
  });

  group('swapAdjacentLetters', () {
    test('inversions possibles', () {
      expect(
        SpellingErrors.swapAdjacentLetters('Haus'),
        isIn(['Huas', 'Hasu']),
      );
    });
    test('position 0 autorisée si minuscule', () {
      expect(SpellingErrors.swapAdjacentLetters('ja'), 'aj');
    });
    test('position 0 exclue si majuscule → null', () {
      expect(SpellingErrors.swapAdjacentLetters('Ja'), isNull);
    });
    test('lettres identiques ignorées', () {
      expect(SpellingErrors.swapAdjacentLetters('Otto'), 'Otot');
    });
    test('mot vide → null', () {
      expect(SpellingErrors.swapAdjacentLetters(''), isNull);
    });
    test('majuscules au milieu autorisées', () {
      expect(
        SpellingErrors.swapAdjacentLetters('HaUS'),
        isIn(['HUaS', 'HaSU']),
      );
    });
  });
  group('generate', () {
    test('mot court : principales puis secours', () {
      expect(SpellingErrors.generate('ja').toSet(), {'Ja', 'j', 'aj'});
    });
    test('règles principales prioritaires', () {
      final errors = SpellingErrors.generate('Haus');
      expect(errors, hasLength(3));
      expect(errors, containsAll(['haus', 'Hauss']));
    });
    test('jamais la bonne réponse, jamais de doublon', () {
      for (final word in ['Kartoffeln', 'élève', 'Brief', 'Physik', 'ja']) {
        final errors = SpellingErrors.generate(word);
        expect(errors, isNot(contains(word)));
        expect(errors.toSet(), hasLength(errors.length));
      }
    });
    test('count respecté', () {
      expect(SpellingErrors.generate('Kartoffeln', count: 1), hasLength(1));
    });
    test('une seule lettre : moins de 3 erreurs', () {
      expect(SpellingErrors.generate('a'), ['A']);
    });
    test('mot vide : aucune erreur', () {
      expect(SpellingErrors.generate(''), isEmpty);
    });
  });
  group('addUmlaut', () {
    test('u → ü', () {
      expect(SpellingErrors.addUmlaut('Mutter'), 'Mütter');
    });
    test('o → ö', () {
      expect(SpellingErrors.addUmlaut('schon'), 'schön');
    });
    test('A majuscule → Ä', () {
      expect(SpellingErrors.addUmlaut('Apfel'), 'Äpfel');
    });
    test('plusieurs voyelles', () {
      expect(SpellingErrors.addUmlaut('Haus'), isIn(['Häus', 'Haüs']));
    });
    test('eu exclu → null', () {
      expect(SpellingErrors.addUmlaut('neu'), isNull);
    });
    test('ni a, ni o, ni u → null', () {
      expect(SpellingErrors.addUmlaut('Tisch'), isNull);
    });
  });

  group('devoiceFinalConsonant', () {
    test('d → t', () {
      expect(SpellingErrors.devoiceFinalConsonant('Hund'), 'Hunt');
    });
    test('b → p', () {
      expect(SpellingErrors.devoiceFinalConsonant('Dieb'), 'Diep');
    });
    test('d au milieu ignoré', () {
      expect(SpellingErrors.devoiceFinalConsonant('Bruder'), isNull);
    });
    test('pas de d ni de b final → null', () {
      expect(SpellingErrors.devoiceFinalConsonant('Haus'), isNull);
    });
  });

  group('simplifyTzCk', () {
    test('tz → z', () {
      expect(SpellingErrors.simplifyTzCk('Katze'), 'Kaze');
    });
    test('ck → k', () {
      expect(SpellingErrors.simplifyTzCk('Zucker'), 'Zuker');
    });
    test('ni tz ni ck → null', () {
      expect(SpellingErrors.simplifyTzCk('Haus'), isNull);
    });
  });

  group('toggleVF', () {
    test('V → F, majuscule conservée', () {
      expect(SpellingErrors.toggleVF('Vater'), 'Fater');
    });
    test('F → V', () {
      expect(SpellingErrors.toggleVF('Fenster'), 'Venster');
    });
    test('ff : variantes filtrées → null', () {
      expect(SpellingErrors.toggleVF('Kartoffel'), isNull);
    });
    test('ni v ni f → null', () {
      expect(SpellingErrors.toggleVF('Haus'), isNull);
    });
  });
}
