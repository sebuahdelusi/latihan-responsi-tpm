import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import '../models/article_model.dart';

class DbService {
  DbService._();
  static final DbService instance = DbService._();

  static const _dbName = 'news_cache.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, _dbName);
    return openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE articles(
            id INTEGER NOT NULL,
            category TEXT NOT NULL,
            title TEXT,
            url TEXT,
            image_url TEXT,
            news_site TEXT,
            summary TEXT,
            published_at TEXT,
            updated_at TEXT,
            PRIMARY KEY (id, category)
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_articles_category ON articles(category)');
      },
    );
  }

  Future<void> upsertArticles(String category, List<ArticleModel> items) async {
    final db = await database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        'articles',
        item.toMap(category),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<ArticleModel>> getArticlesByCategory(String category) async {
    final db = await database;
    final rows = await db.query(
      'articles',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'published_at DESC',
    );
    return rows.map(ArticleModel.fromMap).toList();
  }

  Future<ArticleModel?> getArticleById(String category, int id) async {
    final db = await database;
    final rows = await db.query(
      'articles',
      where: 'category = ? AND id = ?',
      whereArgs: [category, id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ArticleModel.fromMap(rows.first);
  }
}
