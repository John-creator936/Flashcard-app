import '../model/deck.dart';
import 'app_database.dart';

class DeckRepository {
  Future<Deck> create(Deck deck) async {
    final db = await AppDatabase.instance.database;

    final id = await db.insert(tableDecks, deck.toJson());
    return deck.copy(id: id);
  }

  Future<Deck> readDeck(int id) async {
    final db = await AppDatabase.instance.database;

    final maps = await db.query(
      tableDecks,
      columns: DeckFields.values,
      where: '${DeckFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Deck.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Deck>> readAllDecks() async {
    final db = await AppDatabase.instance.database;

    final orderBy = '${DeckFields.time} DESC';

    final result = await db.query(tableDecks, orderBy: orderBy);

    return result.map((json) => Deck.fromJson(json)).toList();
  }

  Future<int> update(Deck deck) async {
    final db = await AppDatabase.instance.database;

    return db.update(
      tableDecks,
      deck.toJson(),
      where: '${DeckFields.id} = ?',
      whereArgs: [deck.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.database;

    return await db.delete(
      tableDecks,
      where: '${DeckFields.id} = ?',
      whereArgs: [id],
    );
  }
}
