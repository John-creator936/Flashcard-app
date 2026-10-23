import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/model/card.dart';
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
      'SELECT ${DeckCardFields.deckId}, COUNT(*) AS cardCount '
      'FROM $tableDecksCard GROUP BY ${DeckCardFields.deckId}',
    );
    final Map<int, int> counts = {};
    for (final row in rows) {
      counts[row['deckId'] as int] = row['cardCount'] as int;
    }
    return counts;
  }

  Future<void> createCardInDeck({
    required int deckId,
    required String term,
    required String definition,
    required DateTime createdTime,
  }) async {
    final Flashcard flashcard = Flashcard(
      term: term,
      definition: definition,
      createdTime: createdTime,
    );
    final Flashcard savedFlashcard = await CardRepository().create(flashcard);
    final DeckCardLink link = DeckCardLink(
      deckId: deckId,
      cardId: savedFlashcard.id!,
      createdTime: createdTime,
    );
    await linkCardToDeck(link);
  }
}
