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
}
