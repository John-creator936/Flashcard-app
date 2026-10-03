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
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableDecks ( 
  ${DeckFields.id} $idType, 
  ${DeckFields.name} $textType,
  ${DeckFields.time} $textType
  )
''');

    await db.execute('''
CREATE TABLE $tableCards ( 
  ${CardFields.id} $idType, 
  ${CardFields.term} $textType,
  ${CardFields.definition} $textType,
  ${CardFields.time} $textType
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

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
