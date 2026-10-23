import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/model/deck_share.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final deck = Deck(
    name: 'Allemand – Literatur',
    createdTime: DateTime(2026, 10, 23),
    deckType: 'translation',
    termLanguage: 'de',
    definitionLanguage: 'fr',
  );
  final cards = [
    Flashcard(
      term: 'die Literatur, en',
      definition: 'la littérature',
      createdTime: DateTime(2026, 10, 23),
    ),
    Flashcard(
      term: 'das Buch, ¨er',
      definition: 'le livre',
      createdTime: DateTime(2026, 10, 23),
    ),
  ];

  group('aller-retour', () {
    final shared = DeckShare.decode(DeckShare.encode(deck, cards))!;

    test('nom, type et langues conservés', () {
      expect(shared.name, 'Allemand – Literatur');
      expect(shared.deckType, 'translation');
      expect(shared.termLanguage, 'de');
      expect(shared.definitionLanguage, 'fr');
    });
    test('cartes conservées, dans l\'ordre', () {
      expect(shared.cards, hasLength(2));
      expect(shared.cards[1].term, 'das Buch, ¨er');
      expect(shared.cards[1].definition, 'le livre');
    });
  });

  group('fichiers invalides', () {
    test('pas du JSON → null', () {
      expect(DeckShare.decode('ceci n\'est pas du JSON'), isNull);
    });
    test('JSON mais pas un objet → null', () {
      expect(DeckShare.decode('[1, 2, 3]'), isNull);
    });
    test('mauvaise version de format → null', () {
      expect(
        DeckShare.decode(
          '{"format": 99, "name": "A", "deckType": "other", "cards": []}',
        ),
        isNull,
      );
    });
    test('nom manquant → null', () {
      expect(
        DeckShare.decode('{"format": 1, "deckType": "other", "cards": []}'),
        isNull,
      );
    });
    test('cartes manquantes → null', () {
      expect(
        DeckShare.decode('{"format": 1, "name": "A", "deckType": "other"}'),
        isNull,
      );
    });
  });

  group('cas tolérés', () {
    test('carte abîmée ignorée, les autres gardées', () {
      final shared = DeckShare.decode(
        '{"format": 1, "name": "A", "deckType": "other", "cards": ['
        '{"term": "ja", "definition": "oui"}, '
        '{"term": 42}, '
        '{"term": "nein", "definition": "non"}]}',
      )!;
      expect(shared.cards.map((pair) => pair.term), ['ja', 'nein']);
    });
    test('langues absentes → null', () {
      final shared = DeckShare.decode(
        '{"format": 1, "name": "A", "deckType": "other", "cards": []}',
      )!;
      expect(shared.termLanguage, isNull);
      expect(shared.definitionLanguage, isNull);
    });
  });
}
