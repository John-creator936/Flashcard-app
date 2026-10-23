import 'package:flashcard_app/model/deck_card.dart';
import 'package:flashcard_app/model/progress_stats.dart';
import 'package:sqflite/sqflite.dart';
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
      '''
    SELECT $tableCards.* FROM $tableCards
    JOIN $tableDecksCard ON $tableCards.${CardFields.id} = $tableDecksCard.${DeckCardFields.cardId}
    WHERE $tableDecksCard.${DeckCardFields.deckId} = ? 
    ORDER BY $orderBy
    ''',
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

  Future<int> countReviewedToday(int deckId, DateTime now) async {
    final db = await AppDatabase.instance.database;
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final result = await db.rawQuery(
      '''
    SELECT COUNT(*) FROM $tableCards
    JOIN $tableDecksCard ON $tableCards.${CardFields.id} = $tableDecksCard.${DeckCardFields.cardId}
    WHERE $tableDecksCard.${DeckCardFields.deckId} = ? AND $tableCards.${CardFields.lastReviewedTime} >= ?
    ''',
      [deckId, startOfDay],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<ProgressStats> readProgressStats(DateTime now) async {
    final db = await AppDatabase.instance.database;
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    const threshold = ProgressStats.masteredThreshold;
    final result = await db.rawQuery(
      '''
    SELECT
      SUM(CASE WHEN ${CardFields.lastReviewedTime} >= ? THEN 1 ELSE 0 END) AS reviewedToday,
      SUM(CASE WHEN ${CardFields.lastReviewedTime} IS NULL THEN 1 ELSE 0 END) AS newCount,
      SUM(CASE WHEN ${CardFields.lastReviewedTime} IS NOT NULL
               AND ${CardFields.intervalDays} < $threshold THEN 1 ELSE 0 END) AS learningCount,
      SUM(CASE WHEN ${CardFields.lastReviewedTime} IS NOT NULL
               AND ${CardFields.intervalDays} >= $threshold THEN 1 ELSE 0 END) AS masteredCount
    FROM $tableCards
    WHERE ${CardFields.id} IN (SELECT ${DeckCardFields.cardId} FROM $tableDecksCard)
    ''',
      [startOfDay],
    );
    final row = result.first;
    return ProgressStats(
      reviewedToday: (row['reviewedToday'] as int?) ?? 0,
      newCount: (row['newCount'] as int?) ?? 0,
      learningCount: (row['learningCount'] as int?) ?? 0,
      masteredCount: (row['masteredCount'] as int?) ?? 0,
    );
  }
}
