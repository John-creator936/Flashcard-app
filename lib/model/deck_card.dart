final String tableDecksCard = 'decks_cards';

class DeckCardFields {
  static final List<String> values = [deckId, cardId, time];

  static final String deckId = 'deckId';
  static final String cardId = 'cardId';
  static final String time = 'time';
}

class DeckCardLink {
  final int deckId;
  final int cardId;
  final DateTime createdTime;

  const DeckCardLink({
    required this.deckId,
    required this.cardId,
    required this.createdTime,
  });

  static DeckCardLink fromJson(Map<String, Object?> json) => DeckCardLink(
    deckId: json[DeckCardFields.deckId] as int,
    cardId: json[DeckCardFields.cardId] as int,
    createdTime: DateTime.parse(json[DeckCardFields.time] as String),
  );

  Map<String, Object?> toJson() => {
    DeckCardFields.deckId: deckId,
    DeckCardFields.cardId: cardId,
    DeckCardFields.time: createdTime.toIso8601String(),
  };
}
