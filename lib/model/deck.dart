final String tableDecks = 'decks';

class DeckFields {
  static final List<String> values = [id, name, time];

  static final String id = '_id';
  static final String name = 'name';
  static final String time = 'time';
}

class Deck {
  final int? id;
  final String name;
  final DateTime createdTime;

  const Deck({this.id, required this.name, required this.createdTime});

  Deck copy({int? id, String? name, DateTime? createdTime}) => Deck(
    id: id ?? this.id,
    name: name ?? this.name,
    createdTime: createdTime ?? this.createdTime,
  );

  static Deck fromJson(Map<String, Object?> json) => Deck(
    id: json[DeckFields.id] as int?,
    name: json[DeckFields.name] as String,
    createdTime: DateTime.parse(json[DeckFields.time] as String),
  );

  Map<String, Object?> toJson() => {
    DeckFields.id: id,
    DeckFields.name: name,
    DeckFields.time: createdTime.toIso8601String(),
  };
}
