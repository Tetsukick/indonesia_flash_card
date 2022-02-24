// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  WordStatusDao? _wordStatusDaoInstance;

  ActivityDao? _activityDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `WordStatus` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `wordId` INTEGER NOT NULL, `status` INTEGER NOT NULL, `isBookmarked` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Activity` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `wordId` INTEGER NOT NULL, `date` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  WordStatusDao get wordStatusDao {
    return _wordStatusDaoInstance ??= _$WordStatusDao(database, changeListener);
  }

  @override
  ActivityDao get activityDao {
    return _activityDaoInstance ??= _$ActivityDao(database, changeListener);
  }
}

class _$WordStatusDao extends WordStatusDao {
  _$WordStatusDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _wordStatusInsertionAdapter = InsertionAdapter(
            database,
            'WordStatus',
            (WordStatus item) => <String, Object?>{
                  'id': item.id,
                  'wordId': item.wordId,
                  'status': item.status,
                  'isBookmarked': item.isBookmarked ? 1 : 0
                }),
        _wordStatusUpdateAdapter = UpdateAdapter(
            database,
            'WordStatus',
            ['id'],
            (WordStatus item) => <String, Object?>{
                  'id': item.id,
                  'wordId': item.wordId,
                  'status': item.status,
                  'isBookmarked': item.isBookmarked ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<WordStatus> _wordStatusInsertionAdapter;

  final UpdateAdapter<WordStatus> _wordStatusUpdateAdapter;

  @override
  Future<List<WordStatus>> findAllWordStatus() async {
    return _queryAdapter.queryList('SELECT * FROM WordStatus',
        mapper: (Map<String, Object?> row) => WordStatus(
            id: row['id'] as int?,
            wordId: row['wordId'] as int,
            status: row['status'] as int,
            isBookmarked: (row['isBookmarked'] as int) != 0));
  }

  @override
  Future<WordStatus?> findWordStatusById(int id) async {
    return _queryAdapter.query('SELECT * FROM WordStatus WHERE wordId = ?1',
        mapper: (Map<String, Object?> row) => WordStatus(
            id: row['id'] as int?,
            wordId: row['wordId'] as int,
            status: row['status'] as int,
            isBookmarked: (row['isBookmarked'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<List<WordStatus>> findBookmarkWordStatus() async {
    return _queryAdapter.queryList(
        'SELECT * FROM WordStatus WHERE isBookmarked = 1',
        mapper: (Map<String, Object?> row) => WordStatus(
            id: row['id'] as int?,
            wordId: row['wordId'] as int,
            status: row['status'] as int,
            isBookmarked: (row['isBookmarked'] as int) != 0));
  }

  @override
  Future<void> insertWordStatus(WordStatus wordStatus) async {
    await _wordStatusInsertionAdapter.insert(
        wordStatus, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateWordStatus(WordStatus wordStatus) async {
    await _wordStatusUpdateAdapter.update(wordStatus, OnConflictStrategy.abort);
  }
}

class _$ActivityDao extends ActivityDao {
  _$ActivityDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _activityInsertionAdapter = InsertionAdapter(
            database,
            'Activity',
            (Activity item) => <String, Object?>{
                  'id': item.id,
                  'wordId': item.wordId,
                  'date': item.date
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Activity> _activityInsertionAdapter;

  @override
  Future<List<Activity>> findAllActivity() async {
    return _queryAdapter.queryList('SELECT * FROM Activity',
        mapper: (Map<String, Object?> row) => Activity(
            id: row['id'] as int?,
            wordId: row['wordId'] as int,
            date: row['date'] as String));
  }

  @override
  Future<List<Activity>> findActivityById(int id) async {
    return _queryAdapter.queryList('SELECT * FROM Activity WHERE wordId = ?1',
        mapper: (Map<String, Object?> row) => Activity(
            id: row['id'] as int?,
            wordId: row['wordId'] as int,
            date: row['date'] as String),
        arguments: [id]);
  }

  @override
  Future<List<Activity>> findActivityByDate(String date) async {
    return _queryAdapter.queryList('SELECT * FROM Activity WHERE date = ?1',
        mapper: (Map<String, Object?> row) => Activity(
            id: row['id'] as int?,
            wordId: row['wordId'] as int,
            date: row['date'] as String),
        arguments: [date]);
  }

  @override
  Future<void> insertActivity(Activity activity) async {
    await _activityInsertionAdapter.insert(activity, OnConflictStrategy.abort);
  }
}
