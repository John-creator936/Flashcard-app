/// Nom de la table de liaison entre decks et cartes.
final String tableDecksCard = 'decks_cards';

/// Noms des colonnes de la table `decks_cards`.
class DeckCardFields {
  static final List<String> values = [deckId, cardId, time];

  static final String deckId = 'deckId';
  static final String cardId = 'cardId';
  static final String time = 'time';
}

/// Le lien entre un deck et une carte : une carte peut être dans plusieurs decks.
///
/// [createdTime] est la date d'ajout de la carte au deck, qui sert à garder
/// l'ordre des cartes dans le deck.
class DeckCardLink {
  final int deckId;
  final int cardId;
  final DateTime createdTime;

  const DeckCardLink({
    required this.deckId,
    required this.cardId,
    required this.createdTime,
  });

  /// Crée un lien à partir d'une ligne de la base.
  static DeckCardLink fromJson(Map<String, Object?> json) => DeckCardLink(
    deckId: json[DeckCardFields.deckId] as int,
    cardId: json[DeckCardFields.cardId] as int,
    createdTime: DateTime.parse(json[DeckCardFields.time] as String),
  );

  /// Convertit le lien en ligne pour la base.
  Map<String, Object?> toJson() => {
    DeckCardFields.deckId: deckId,
    DeckCardFields.cardId: cardId,
    DeckCardFields.time: createdTime.toIso8601String(),
  };
}
