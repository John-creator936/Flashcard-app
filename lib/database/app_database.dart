import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/model/deck_card.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('flashcards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onConfigure: _onConfigure,
      onUpgrade: _upgradeDB,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Crée les trois tables : cartes, decks et liens entre eux.
  ///
  /// Many-to-many : une carte peut appartenir à plusieurs decks grâce
  /// à la table de liaison `decks_cards`. Sa clé primaire est composite
  /// (`deckId`, `cardId`) : un lien ne peut donc pas exister deux fois.
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE $tableDecks ( 
  ${DeckFields.id} $idType, 
  ${DeckFields.name} $textType,
  ${DeckFields.time} $textType,
  ${DeckFields.deckType} $textType DEFAULT 'other', 
  ${DeckFields.termLanguage} TEXT,
  ${DeckFields.definitionLanguage} TEXT
  )
''');

    await db.execute('''
CREATE TABLE $tableCards ( 
  ${CardFields.id} $idType, 
  ${CardFields.term} $textType,
  ${CardFields.definition} $textType,
  ${CardFields.time} $textType,
  ${CardFields.easeFactor} $realType DEFAULT 2.5,
  ${CardFields.points} $realType DEFAULT 0,
  ${CardFields.intervalDays} $realType DEFAULT 0,
  ${CardFields.lastReviewedTime} TEXT
  )
''');

    await db.execute('''
CREATE TABLE $tableDecksCard ( 
  ${DeckCardFields.deckId} $integerType, 
  ${DeckCardFields.cardId} $integerType,
  ${DeckCardFields.time} $textType,
  FOREIGN KEY (${DeckCardFields.deckId})
    REFERENCES $tableDecks (${DeckFields.id})
    ON DELETE CASCADE,
  FOREIGN KEY (${DeckCardFields.cardId})
    REFERENCES $tableCards (${CardFields.id})
    ON DELETE CASCADE,
  PRIMARY KEY (${DeckCardFields.deckId}, ${DeckCardFields.cardId})
  )
''');
  }

  /// Met à jour la structure d'une base existante sans perdre les données.
  ///
  /// Chaque bloc `if (oldVersion < N)` correspond à une version.
  /// Les anciens blocs ne doivent jamais être modifiés.
  /// Version 2 : colonnes de la Révision (SM-2) dans `cards`.
  /// Version 3 : type et langues du deck dans `decks`.
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableCards ADD COLUMN ${CardFields.easeFactor} REAL NOT NULL DEFAULT 2.5',
      );
      await db.execute(
        'ALTER TABLE $tableCards ADD COLUMN ${CardFields.points} REAL NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableCards ADD COLUMN ${CardFields.intervalDays} REAL NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableCards ADD COLUMN ${CardFields.lastReviewedTime} TEXT',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE $tableDecks ADD COLUMN ${DeckFields.deckType} TEXT NOT NULL DEFAULT 'other'",
      );
      await db.execute(
        "ALTER TABLE $tableDecks ADD COLUMN ${DeckFields.termLanguage} TEXT",
      );
      await db.execute(
        "ALTER TABLE $tableDecks ADD COLUMN ${DeckFields.definitionLanguage} TEXT",
      );
    }
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
