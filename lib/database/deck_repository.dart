import '../model/deck.dart';
import 'app_database.dart';

/// Lecture et écriture des decks dans la base.
class DeckRepository {
  /// Enregistre un nouveau deck et le renvoie avec son id.
  Future<Deck> create(Deck deck) async {
    final db = await AppDatabase.instance.database;

    final id = await db.insert(tableDecks, deck.toJson());
    return deck.copy(id: id);
  }

  /// Lit un deck par son id. Lance une exception s'il n'existe pas.
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

  /// Lit tous les decks, du plus récent au plus ancien.
  Future<List<Deck>> readAllDecks() async {
    final db = await AppDatabase.instance.database;

    final orderBy = '${DeckFields.time} DESC';

    final result = await db.query(tableDecks, orderBy: orderBy);

    return result.map((json) => Deck.fromJson(json)).toList();
  }

  /// Met à jour un deck existant.
  Future<int> update(Deck deck) async {
    final db = await AppDatabase.instance.database;

    return db.update(
      tableDecks,
      deck.toJson(),
      where: '${DeckFields.id} = ?',
      whereArgs: [deck.id],
    );
  }

  /// Supprime un deck et ses liens, mais pas ses cartes (qui peuvent être
  /// dans d'autres decks).
  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.database;

    return await db.delete(
      tableDecks,
      where: '${DeckFields.id} = ?',
      whereArgs: [id],
    );
  }
}
