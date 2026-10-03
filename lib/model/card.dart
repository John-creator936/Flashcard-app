final String tableCards = 'cards';

class CardFields {
  static final List<String> values = [
    /// Add all fields
    id, term, definition, time,
  ];

  static final String id = '_id';
  static final String term = 'term';
  static final String definition = 'definition';
  static final String time = 'time';
}

class Flashcard {
  final int? id;
  final String term;
  final String definition;
  final DateTime createdTime;

  const Flashcard({
    this.id,
    required this.term,
    required this.definition,
    required this.createdTime,
  });

  Flashcard copy({
    int? id,
    String? term,
    String? definition,
    DateTime? createdTime,
  }) => Flashcard(
    id: id ?? this.id,
    term: term ?? this.term,
    definition: definition ?? this.definition,
    createdTime: createdTime ?? this.createdTime,
  );

  static Flashcard fromJson(Map<String, Object?> json) => Flashcard(
    id: json[CardFields.id] as int?,
    term: json[CardFields.term] as String,
    definition: json[CardFields.definition] as String,
    createdTime: DateTime.parse(json[CardFields.time] as String),
  );

  Map<String, Object?> toJson() => {
    CardFields.id: id,
    CardFields.term: term,
    CardFields.definition: definition,
    CardFields.time: createdTime.toIso8601String(),
  };
}
