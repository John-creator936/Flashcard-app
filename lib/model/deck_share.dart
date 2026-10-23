import 'dart:convert';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/model/vocabulary_parser.dart';

/// Un deck lu depuis un fichier de partage, pas encore enregistré en base.
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

/// Convertit un deck en texte JSON pour le partager, et inversement.
///
/// Seuls le nom, le type, les langues et le texte des cartes sont partagés :
/// ni les ids, ni le progrès SM-2, qui sont propres à chaque utilisateur.
class DeckShare {
  /// Version du format, pour reconnaître un fichier créé par une ancienne
  /// version de l'app si le format change un jour.
  static const formatVersion = 1;

  /// Transforme un deck et ses cartes en texte JSON.
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

  /// Lit un texte JSON et renvoie le deck, ou `null` si le fichier n'est pas
  /// un deck valide.
  ///
  /// Chaque champ est vérifié, car le fichier peut venir de n'importe où.
  /// Une carte mal formée est ignorée, au lieu de faire échouer l'import.
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
