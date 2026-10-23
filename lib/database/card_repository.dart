import 'package:flashcard_app/model/deck_card.dart';
import 'package:flashcard_app/model/progress_stats.dart';
import 'package:sqflite/sqflite.dart';
import '../model/card.dart';
import 'app_database.dart';

/// Lecture et écriture des cartes dans la base.
class CardRepository {
  /// Enregistre une nouvelle carte et la renvoie avec son id.
  Future<Flashcard> create(Flashcard card) async {
    final db = await AppDatabase.instance.database;

    final id = await db.insert(tableCards, card.toJson());
    return card.copy(id: id);
  }

  /// Lit une carte par son id. Lance une exception si elle n'existe pas.
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

  /// Lit les cartes d'un deck, dans l'ordre où elles y ont été ajoutées.
  ///
  /// Passe par la table de liaison, puisqu'une carte peut être dans
  /// plusieurs decks.
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

  /// Met à jour une carte, partout où elle est utilisée.
  Future<int> update(Flashcard card) async {
    final db = await AppDatabase.instance.database;

    return db.update(
      tableCards,
      card.toJson(),
      where: '${CardFields.id} = ?',
      whereArgs: [card.id],
    );
  }

  /// Supprime une carte de tous les decks.
  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.database;

    return await db.delete(
      tableCards,
      where: '${CardFields.id} = ?',
      whereArgs: [id],
    );
  }

  /// Compte les cartes d'un deck révisées depuis minuit, pour la limite du jour.
  ///
  /// Les dates sont stockées en texte ISO, qui se compare comme une date.
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

  /// Calcule les chiffres de « Ma progression » en une seule requête.
  ///
  /// Chaque `SUM(CASE …)` compte les cartes qui remplissent une condition.
  /// `IN` compte une carte partagée une seule fois et ignore les cartes orphelines.
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
