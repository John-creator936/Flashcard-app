final String tableDecks = 'decks';

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

  static Deck fromJson(Map<String, Object?> json) => Deck(
    id: json[DeckFields.id] as int?,
    name: json[DeckFields.name] as String,
    createdTime: DateTime.parse(json[DeckFields.time] as String),
    deckType: json[DeckFields.deckType] as String,
    termLanguage: json[DeckFields.termLanguage] as String?,
    definitionLanguage: json[DeckFields.definitionLanguage] as String?,
  );

  Map<String, Object?> toJson() => {
    DeckFields.id: id,
    DeckFields.name: name,
    DeckFields.time: createdTime.toIso8601String(),
    DeckFields.deckType: deckType,
    DeckFields.termLanguage: termLanguage,
    DeckFields.definitionLanguage: definitionLanguage,
  };
}
