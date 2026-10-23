import 'dart:convert';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/model/vocabulary_parser.dart';

class SharedDeck {
  final String name;
  final String deckType;
  final String? termLanguage;
  final String? definitionLanguage;
  final List<VocabularyPair> cards;

  const SharedDeck({
    required this.name,
    required this.deckType,
    this.termLanguage,
    this.definitionLanguage,
    required this.cards,
  });
}

class DeckShare {
  static const formatVersion = 1;

  static String encode(Deck deck, List<Flashcard> cards) {
    final data = {
      "format": formatVersion,
      "name": deck.name,
      "deckType": deck.deckType,
      "termLanguage": deck.termLanguage,
      "definitionLanguage": deck.definitionLanguage,
      "cards": cards
          .map((card) => {"term": card.term, "definition": card.definition})
          .toList(),
    };
    return jsonEncode(data);
  }

  static SharedDeck? decode(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    if (decoded['format'] != formatVersion) return null;
    if (decoded['name'] is! String || decoded['deckType'] is! String) {
      return null;
    }
    final rawCards = decoded['cards'];
    if (rawCards is! List) return null;
    final List<VocabularyPair> pairs = [];
    for (final rawCard in rawCards) {
      if (rawCard is Map &&
          rawCard['term'] is String &&
          rawCard['definition'] is String) {
        pairs.add(
          VocabularyPair(
            term: rawCard['term'],
            definition: rawCard['definition'],
          ),
        );
      }
    }
    String? termLanguage = decoded['termLanguage'] is String
        ? decoded['termLanguage']
        : null;
    String? definitionLanguage = decoded['definitionLanguage'] is String
        ? decoded['definitionLanguage']
        : null;
    return SharedDeck(
      name: decoded['name'],
      deckType: decoded['deckType'],
      termLanguage: termLanguage,
      definitionLanguage: definitionLanguage,
      cards: pairs,
    );
  }
}
