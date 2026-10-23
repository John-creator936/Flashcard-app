/// Nom de la table des decks.
final String tableDecks = 'decks';

/// Langues proposées pour un deck de vocabulaire, avec leur nom affiché.
const Map<String, String> deckLanguages = {
  'fr': 'Français',
  'de': 'Allemand',
  'en': 'Anglais',
};

/// Noms des colonnes de la table `decks`.
class DeckFields {
  static final List<String> values = [
    id,
    name,
    time,
    deckType,
    termLanguage,
    definitionLanguage,
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String time = 'time';
  static final String deckType = 'deckType';
  static final String termLanguage = 'termLanguage';
  static final String definitionLanguage = 'definitionLanguage';
}

/// Un deck : un nom, un type et, pour le vocabulaire, une langue par côté.
///
/// [deckType] vaut 'translation' (vocabulaire), 'definition' ou 'other'
/// (réponses courtes). Il décide si le QCM peut proposer des pièges
/// d'orthographe.
class Deck {
  final int? id;
  final String name;
  final DateTime createdTime;
  final String deckType;
  final String? termLanguage;
  final String? definitionLanguage;

  const Deck({
    this.id,
    required this.name,
    required this.createdTime,
    this.deckType = 'other',
    this.termLanguage,
    this.definitionLanguage,
  });

  /// Copie le deck en remplaçant seulement les champs donnés.
  Deck copy({
    int? id,
    String? name,
    DateTime? createdTime,
    String? deckType,
    String? termLanguage,
    String? definitionLanguage,
  }) => Deck(
    id: id ?? this.id,
    name: name ?? this.name,
    createdTime: createdTime ?? this.createdTime,
    deckType: deckType ?? this.deckType,
    termLanguage: termLanguage ?? this.termLanguage,
    definitionLanguage: definitionLanguage ?? this.definitionLanguage,
  );

  /// Crée un deck à partir d'une ligne de la base.
  static Deck fromJson(Map<String, Object?> json) => Deck(
    id: json[DeckFields.id] as int?,
    name: json[DeckFields.name] as String,
    createdTime: DateTime.parse(json[DeckFields.time] as String),
    deckType: json[DeckFields.deckType] as String,
    termLanguage: json[DeckFields.termLanguage] as String?,
    definitionLanguage: json[DeckFields.definitionLanguage] as String?,
  );

  /// Convertit le deck en ligne pour la base.
  Map<String, Object?> toJson() => {
    DeckFields.id: id,
    DeckFields.name: name,
    DeckFields.time: createdTime.toIso8601String(),
    DeckFields.deckType: deckType,
    DeckFields.termLanguage: termLanguage,
    DeckFields.definitionLanguage: definitionLanguage,
  };
}
