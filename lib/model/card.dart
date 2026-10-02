final String tableCards = 'cards';

class CardFields {
  static final List<String> values = [
    /// Add all fields
    id, term, deckId, definition, time,
  ];

  static final String id = '_id';
  static final String deckId = 'deckId';
  static final String term = 'term';
  static final String definition = 'definition';
  static final String time = 'time';
}

class Flashcard {
  final int? id;
  final int deckId;
  final String term;
  final String definition;
  final DateTime createdTime;

  const Flashcard({
    this.id,
    required this.deckId,
    required this.term,
    required this.definition,
    required this.createdTime,
  });

  Flashcard copy({
    int? id,
    int? deckId,
    String? term,
    String? definition,
    DateTime? createdTime,
  }) => Flashcard(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    term: term ?? this.term,
    definition: definition ?? this.definition,
    createdTime: createdTime ?? this.createdTime,
  );

  static Flashcard fromJson(Map<String, Object?> json) => Flashcard(
    id: json[CardFields.id] as int?,
    deckId: json[CardFields.deckId] as int,
    term: json[CardFields.term] as String,
    definition: json[CardFields.definition] as String,
    createdTime: DateTime.parse(json[CardFields.time] as String),
  );

  Map<String, Object?> toJson() => {
    CardFields.id: id,
    CardFields.deckId: deckId,
    CardFields.term: term,
    CardFields.definition: definition,
    CardFields.time: createdTime.toIso8601String(),
  };
}
