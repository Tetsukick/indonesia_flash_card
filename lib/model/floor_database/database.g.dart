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

  TangoDao? _tangoDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 3,
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
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `TangoEntity` (`id` INTEGER, `indonesian` TEXT, `japanese` TEXT, `english` TEXT, `description` TEXT, `example` TEXT, `exampleJp` TEXT, `level` INTEGER, `partOfSpeech` INTEGER, `category` INTEGER, `frequency` INTEGER, `rankFrequency` INTEGER, PRIMARY KEY (`id`))');

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

  @override
  TangoDao get tangoDao {
    return _tangoDaoInstance ??= _$TangoDao(database, changeListener);
  }
}

class _$WordStatusDao extends WordStatusDao {
  _$WordStatusDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
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
  _$ActivityDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
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

class _$TangoDao extends TangoDao {
  _$TangoDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _tangoEntityInsertionAdapter = InsertionAdapter(
            database,
            'TangoEntity',
            (TangoEntity item) => <String, Object?>{
                  'id': item.id,
                  'indonesian': item.indonesian,
                  'japanese': item.japanese,
                  'english': item.english,
                  'description': item.description,
                  'example': item.example,
                  'exampleJp': item.exampleJp,
                  'level': item.level,
                  'partOfSpeech': item.partOfSpeech,
                  'category': item.category,
                  'frequency': item.frequency,
                  'rankFrequency': item.rankFrequency
                }),
        _tangoEntityUpdateAdapter = UpdateAdapter(
            database,
            'TangoEntity',
            ['id'],
            (TangoEntity item) => <String, Object?>{
                  'id': item.id,
                  'indonesian': item.indonesian,
                  'japanese': item.japanese,
                  'english': item.english,
                  'description': item.description,
                  'example': item.example,
                  'exampleJp': item.exampleJp,
                  'level': item.level,
                  'partOfSpeech': item.partOfSpeech,
                  'category': item.category,
                  'frequency': item.frequency,
                  'rankFrequency': item.rankFrequency
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TangoEntity> _tangoEntityInsertionAdapter;

  final UpdateAdapter<TangoEntity> _tangoEntityUpdateAdapter;

  @override
  Future<List<TangoEntity>> getAllTangoList(
    int offset,
    int limit,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM TangoEntity ORDER BY indonesian ASC LIMIT ?1,?2',
        mapper: (Map<String, Object?> row) => TangoEntity(
            id: row['id'] as int?,
            indonesian: row['indonesian'] as String?,
            japanese: row['japanese'] as String?,
            english: row['english'] as String?,
            description: row['description'] as String?,
            example: row['example'] as String?,
            exampleJp: row['exampleJp'] as String?,
            level: row['level'] as int?,
            partOfSpeech: row['partOfSpeech'] as int?,
            category: row['category'] as int?,
            frequency: row['frequency'] as int?,
            rankFrequency: row['rankFrequency'] as int?),
        arguments: [offset, limit]);
  }

  @override
  Future<int?> getCountTangoList() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM TangoEntity',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<List<TangoEntity>> getTangoListByIndonesian(String name) async {
    return _queryAdapter.queryList(
        'SELECT * FROM TangoEntity WHERE LOWER(indonesian) = ?1 ORDER BY indonesian ASC',
        mapper: (Map<String, Object?> row) => TangoEntity(id: row['id'] as int?, indonesian: row['indonesian'] as String?, japanese: row['japanese'] as String?, english: row['english'] as String?, description: row['description'] as String?, example: row['example'] as String?, exampleJp: row['exampleJp'] as String?, level: row['level'] as int?, partOfSpeech: row['partOfSpeech'] as int?, category: row['category'] as int?, frequency: row['frequency'] as int?, rankFrequency: row['rankFrequency'] as int?),
        arguments: [name]);
  }

  @override
  Future<List<TangoEntity>> getTangoListByCategory(int categoryId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM TangoEntity WHERE category = ?1 ORDER BY indonesian ASC',
        mapper: (Map<String, Object?> row) => TangoEntity(
            id: row['id'] as int?,
            indonesian: row['indonesian'] as String?,
            japanese: row['japanese'] as String?,
            english: row['english'] as String?,
            description: row['description'] as String?,
            example: row['example'] as String?,
            exampleJp: row['exampleJp'] as String?,
            level: row['level'] as int?,
            partOfSpeech: row['partOfSpeech'] as int?,
            category: row['category'] as int?,
            frequency: row['frequency'] as int?,
            rankFrequency: row['rankFrequency'] as int?),
        arguments: [categoryId]);
  }

  @override
  Future<List<TangoEntity>> getTangoListByPartOfSpeech(int partOfSpeech) async {
    return _queryAdapter.queryList(
        'SELECT * FROM TangoEntity WHERE partOfSpeech = ?1 ORDER BY indonesian ASC',
        mapper: (Map<String, Object?> row) => TangoEntity(id: row['id'] as int?, indonesian: row['indonesian'] as String?, japanese: row['japanese'] as String?, english: row['english'] as String?, description: row['description'] as String?, example: row['example'] as String?, exampleJp: row['exampleJp'] as String?, level: row['level'] as int?, partOfSpeech: row['partOfSpeech'] as int?, category: row['category'] as int?, frequency: row['frequency'] as int?, rankFrequency: row['rankFrequency'] as int?),
        arguments: [partOfSpeech]);
  }

  @override
  Future<List<TangoEntity>> getTangoListByLevel(
    int levelMin,
    int levelMax,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM TangoEntity WHERE level >= ?1 AND level <= ?2 ORDER BY indonesian ASC',
        mapper: (Map<String, Object?> row) => TangoEntity(id: row['id'] as int?, indonesian: row['indonesian'] as String?, japanese: row['japanese'] as String?, english: row['english'] as String?, description: row['description'] as String?, example: row['example'] as String?, exampleJp: row['exampleJp'] as String?, level: row['level'] as int?, partOfSpeech: row['partOfSpeech'] as int?, category: row['category'] as int?, frequency: row['frequency'] as int?, rankFrequency: row['rankFrequency'] as int?),
        arguments: [levelMin, levelMax]);
  }

  @override
  Future<List<TangoEntity>> getTangoListByFrequency(
    int frequencyFactorMin,
    int frequencyFactorMax,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM TangoEntity WHERE rankFrequency >= ?1 AND rankFrequency <= ?2 ORDER BY indonesian ASC',
        mapper: (Map<String, Object?> row) => TangoEntity(id: row['id'] as int?, indonesian: row['indonesian'] as String?, japanese: row['japanese'] as String?, english: row['english'] as String?, description: row['description'] as String?, example: row['example'] as String?, exampleJp: row['exampleJp'] as String?, level: row['level'] as int?, partOfSpeech: row['partOfSpeech'] as int?, category: row['category'] as int?, frequency: row['frequency'] as int?, rankFrequency: row['rankFrequency'] as int?),
        arguments: [frequencyFactorMin, frequencyFactorMax]);
  }

  @override
  Future<void> deleteAllTango() async {
    await _queryAdapter.queryNoReturn('DELETE FROM TangoEntity');
  }

  @override
  Future<void> insertTangoEntity(TangoEntity tango) async {
    await _tangoEntityInsertionAdapter.insert(tango, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateTangoEntity(TangoEntity tango) async {
    await _tangoEntityUpdateAdapter.update(tango, OnConflictStrategy.abort);
  }
}
