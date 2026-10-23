import 'package:flashcard_app/model/deck_card.dart';
import 'package:sqflite/sql.dart';
import 'app_database.dart';

class DeckCardRepository {
  Future<DeckCardLink> linkCardToDeck(DeckCardLink deckCard) async {
    final db = await AppDatabase.instance.database;

    await db.insert(
      tableDecksCard,
      deckCard.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return deckCard;
  }

  Future<int> unlinkCardFromDeck(int deckId, int cardId) async {
    final db = await AppDatabase.instance.database;

    return await db.delete(
      tableDecksCard,
      where: '${DeckCardFields.cardId} = ? AND ${DeckCardFields.deckId} = ?',
      whereArgs: [cardId, deckId],
    );
  }

  Future<Map<int, int>> countCardsPerDeck() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery(
      'SELECT deckId, COUNT(*) AS cardCount FROM decks_cards GROUP BY deckId',
    );
    final Map<int, int> counts = {};
    for (final row in rows) {
      counts[row['deckId'] as int] = row['cardCount'] as int;
    }
    return counts;
  }
}
