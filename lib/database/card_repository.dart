import 'package:flashcard_app/model/deck_card.dart';
import '../model/card.dart';
import 'app_database.dart';

class CardRepository {
  Future<Flashcard> create(Flashcard card) async {
    final db = await AppDatabase.instance.database;

    final id = await db.insert(tableCards, card.toJson());
    return card.copy(id: id);
  }

  Future<Flashcard> readCard(int id) async {
    final db = await AppDatabase.instance.database;

    final maps = await db.query(
      tableCards,
      columns: CardFields.values,
      where: '${CardFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Flashcard.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Flashcard>> readCardsByDeck(int deckId) async {
    final db = await AppDatabase.instance.database;

    final orderBy = '$tableDecksCard.${DeckCardFields.time} ASC';

    final result = await db.rawQuery(
      'SELECT $tableCards.* FROM $tableCards JOIN $tableDecksCard ON $tableCards.${CardFields.id} = $tableDecksCard.${DeckCardFields.cardId} WHERE $tableDecksCard.${DeckCardFields.deckId} = ? ORDER BY $orderBy',
      [deckId],
    );

    return result.map((json) => Flashcard.fromJson(json)).toList();
  }

  Future<int> update(Flashcard card) async {
    final db = await AppDatabase.instance.database;

    return db.update(
      tableCards,
      card.toJson(),
      where: '${CardFields.id} = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.database;

    return await db.delete(
      tableCards,
      where: '${CardFields.id} = ?',
      whereArgs: [id],
    );
  }
}
