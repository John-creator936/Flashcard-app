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
  OcrLine at(String text, double left, double top) =>
      OcrLine(text: text, left: left, top: top);

  group('parse', () {
    final realPage = [
      // Colonne française
      at('le noyau', 1639, 106),
      at('la centrale nucléaire', 1644, 169),
      at("l'usine", 1654, 325),
      at('la fabrique', 1544, 471),
      at('le, la fabricant-e', 1551, 601),
      at("l'industrie", 1682, 748),
      at("1. I'exploitation, I'usine 2. l'activte", 1694, 888),
      at('(mettre) hors service, en service', 1697, 965),
      at('entreprendre', 1582, 1123),
      at("I'entreprise", 1598, 1355),
      at('la section, le rayon, la division', 1728, 1468),
      at('le chef de rayon', 1733, 1578),
      at('fabriquer, produire', 1619, 1714),
      at('la production', 1751, 1866),
      at('le produit', 1760, 2016),
      at('productif', 1769, 2165),
      at('le rendement, la performance,', 1779, 2284),
      at("I'exploit", 1784, 2404),
      at('la machine', 1672, 2555),
      at('le, la mécanicien-ne', 1681, 2692),
      at('la technique', 1689, 2851),
      at('le, la technicien-ne', 1698, 2992),
      at('technique', 1704, 3151),
      at("l'ingénieur-e", 1714, 3295),
      at('inventer', 1853, 3529),
      // Colonne allemande
      at('der Kęrn, e', 360, 228),
      at('das Kęrnkraftwerk', 365, 291),
      at('das Węrk, e', 378, 446),
      at('die Fabrik, en', 275, 595),
      at('der Fabrikant, en, en / die -in', 285, 689),
      at('die Industrie, n', 413, 868),
      at('der Betrieb, e', 425, 1016),
      at('auBer Betrieb, in Betrieb (setzen)', 429, 1044),
      at('unternehmen unternimmt, unternahm,', 329, 1168),
      at('hat unternommen', 336, 1312),
      at('das Unternehmen, -', 347, 1443),
      at('die Abteilung, en (Abt.)', 470, 1563),
      at('der Abtelungsleiter', 475, 1659),
      at('her/stellen (produzieren)', 377, 1785),
      at('die Produktion, en', 499, 1935),
      at('das Produkt, e', 510, 2082),
      at('produktiv (un-)', 521, 2218),
      at('die Leistung, en', 530, 2362),
      at('die Maschine, n', 440, 2581),
      at('der Mechaniker, - / die -in', 448, 2716),
      at('die Tęchnik, en', 456, 2855),
      at('der Tęchniker, - / die -in', 464, 2990),
      at('tęchnisch', 471, 3130),
      at('der Ingenieur, e / die -in', 477, 3263),
      at('(prononc. fr.)', 480, 3341),
      at('erfinden erfindet, erfand,', 591, 3482),
      at('hat erfunden', 593, 3559),
    ];

    test('vraie page : 24 paires', () {
      expect(VocabularyParser.parse(realPage), hasLength(24));
    });
    test('vraie page : première paire', () {
      final pair = VocabularyParser.parse(realPage)[0];
      expect(pair.term, 'der Kern, e');
      expect(pair.definition, 'le noyau');
    });
    test('vraie page : sous-entrée', () {
      final pair = VocabularyParser.parse(realPage)[1];
      expect(pair.term, 'das Kernkraftwerk');
      expect(pair.definition, 'la centrale nucléaire');
    });
    test('vraie page : terme sur deux lignes', () {
      final pair = VocabularyParser.parse(realPage)[8];
      expect(pair.term, 'unternehmen unternimmt, unternahm, hat unternommen');
      expect(pair.definition, 'entreprendre');
    });
    test('vraie page : définition sur deux lignes', () {
      final pair = VocabularyParser.parse(realPage)[16];
      expect(pair.term, 'die Leistung, en');
      expect(pair.definition, "le rendement, la performance, l'exploit");
    });
    test('vraie page : dernière paire', () {
      final pair = VocabularyParser.parse(realPage)[23];
      expect(pair.term, 'erfinden erfindet, erfand, hat erfunden');
      expect(pair.definition, 'inventer');
    });
    test('colonnes de tailles différentes : côté vide', () {
      final pairs = VocabularyParser.parse([
        at('der Kern, e', 100, 0),
        at('das Werk, e', 100, 50),
        at('le noyau', 900, 0),
      ]);
      expect(pairs, hasLength(2));
      expect(pairs[1].term, 'das Werk, e');
      expect(pairs[1].definition, '');
    });
    test('titre de section et numéro de page ignorés', () {
      final pairs = VocabularyParser.parse([
        at('10.3 Literatur', 100, 0),
        at('die Literatur, en', 100, 100),
        at('das Buch, "er', 100, 200),
        at('la littérature', 900, 90),
        at('le livre', 900, 190),
        at('139', 950, 900),
      ]);
      expect(pairs, hasLength(2));
      expect(pairs[0].term, 'die Literatur, en');
      expect(pairs[0].definition, 'la littérature');
    });
    test('un sens numéroté n\'est pas du bruit', () {
      final pairs = VocabularyParser.parse([
        at('die Seite, n', 100, 0),
        at('1. le côté, la face 2. la page', 900, 0),
      ]);
      expect(pairs.single.definition, '1. le côté, la face 2. la page');
    });
  });
}
