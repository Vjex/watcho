// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
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

  MovieDao? _movieDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
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
            'CREATE TABLE IF NOT EXISTS `movies` (`id` INTEGER NOT NULL, `title` TEXT NOT NULL, `overview` TEXT NOT NULL, `posterPath` TEXT, `backdropPath` TEXT, `releaseDate` TEXT, `voteAverage` REAL NOT NULL, `voteCount` INTEGER NOT NULL, `popularity` REAL NOT NULL, `isTrending` INTEGER NOT NULL, `isNowPlaying` INTEGER NOT NULL, `isBookmarked` INTEGER NOT NULL, `last_updated` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  MovieDao get movieDao {
    return _movieDaoInstance ??= _$MovieDao(database, changeListener);
  }
}

class _$MovieDao extends MovieDao {
  _$MovieDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _movieTableEntityInsertionAdapter = InsertionAdapter(
            database,
            'movies',
            (MovieTableEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'overview': item.overview,
                  'posterPath': item.posterPath,
                  'backdropPath': item.backdropPath,
                  'releaseDate': item.releaseDate,
                  'voteAverage': item.voteAverage,
                  'voteCount': item.voteCount,
                  'popularity': item.popularity,
                  'isTrending': item.isTrending ? 1 : 0,
                  'isNowPlaying': item.isNowPlaying ? 1 : 0,
                  'isBookmarked': item.isBookmarked ? 1 : 0,
                  'last_updated': item.lastUpdated
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MovieTableEntity> _movieTableEntityInsertionAdapter;

  @override
  Future<List<MovieTableEntity>> getTrendingMovies() async {
    return _queryAdapter.queryList(
        'SELECT * FROM movies WHERE isTrending = 1 ORDER BY popularity DESC',
        mapper: (Map<String, Object?> row) => MovieTableEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            overview: row['overview'] as String,
            posterPath: row['posterPath'] as String?,
            backdropPath: row['backdropPath'] as String?,
            releaseDate: row['releaseDate'] as String?,
            voteAverage: row['voteAverage'] as double,
            voteCount: row['voteCount'] as int,
            popularity: row['popularity'] as double,
            isTrending: (row['isTrending'] as int) != 0,
            isNowPlaying: (row['isNowPlaying'] as int) != 0,
            isBookmarked: (row['isBookmarked'] as int) != 0,
            lastUpdated: row['last_updated'] as int));
  }

  @override
  Future<List<MovieTableEntity>> getNowPlayingMovies() async {
    return _queryAdapter.queryList(
        'SELECT * FROM movies WHERE isNowPlaying = 1 ORDER BY releaseDate DESC',
        mapper: (Map<String, Object?> row) => MovieTableEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            overview: row['overview'] as String,
            posterPath: row['posterPath'] as String?,
            backdropPath: row['backdropPath'] as String?,
            releaseDate: row['releaseDate'] as String?,
            voteAverage: row['voteAverage'] as double,
            voteCount: row['voteCount'] as int,
            popularity: row['popularity'] as double,
            isTrending: (row['isTrending'] as int) != 0,
            isNowPlaying: (row['isNowPlaying'] as int) != 0,
            isBookmarked: (row['isBookmarked'] as int) != 0,
            lastUpdated: row['last_updated'] as int));
  }

  @override
  Future<List<MovieTableEntity>> getBookmarkedMovies() async {
    return _queryAdapter.queryList(
        'SELECT * FROM movies WHERE isBookmarked = 1 ORDER BY last_updated DESC',
        mapper: (Map<String, Object?> row) => MovieTableEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            overview: row['overview'] as String,
            posterPath: row['posterPath'] as String?,
            backdropPath: row['backdropPath'] as String?,
            releaseDate: row['releaseDate'] as String?,
            voteAverage: row['voteAverage'] as double,
            voteCount: row['voteCount'] as int,
            popularity: row['popularity'] as double,
            isTrending: (row['isTrending'] as int) != 0,
            isNowPlaying: (row['isNowPlaying'] as int) != 0,
            isBookmarked: (row['isBookmarked'] as int) != 0,
            lastUpdated: row['last_updated'] as int));
  }

  @override
  Future<MovieTableEntity?> getMovieById(int id) async {
    return _queryAdapter.query('SELECT * FROM movies WHERE id = ?1',
        mapper: (Map<String, Object?> row) => MovieTableEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            overview: row['overview'] as String,
            posterPath: row['posterPath'] as String?,
            backdropPath: row['backdropPath'] as String?,
            releaseDate: row['releaseDate'] as String?,
            voteAverage: row['voteAverage'] as double,
            voteCount: row['voteCount'] as int,
            popularity: row['popularity'] as double,
            isTrending: (row['isTrending'] as int) != 0,
            isNowPlaying: (row['isNowPlaying'] as int) != 0,
            isBookmarked: (row['isBookmarked'] as int) != 0,
            lastUpdated: row['last_updated'] as int),
        arguments: [id]);
  }

  @override
  Future<List<MovieTableEntity>> searchMovies(String query) async {
    return _queryAdapter.queryList(
        'SELECT * FROM movies WHERE title LIKE ?1 OR overview LIKE ?1',
        mapper: (Map<String, Object?> row) => MovieTableEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            overview: row['overview'] as String,
            posterPath: row['posterPath'] as String?,
            backdropPath: row['backdropPath'] as String?,
            releaseDate: row['releaseDate'] as String?,
            voteAverage: row['voteAverage'] as double,
            voteCount: row['voteCount'] as int,
            popularity: row['popularity'] as double,
            isTrending: (row['isTrending'] as int) != 0,
            isNowPlaying: (row['isNowPlaying'] as int) != 0,
            isBookmarked: (row['isBookmarked'] as int) != 0,
            lastUpdated: row['last_updated'] as int),
        arguments: [query]);
  }

  @override
  Future<void> updateBookmarkStatus(
    int id,
    bool isBookmarked,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE movies SET isBookmarked = ?2 WHERE id = ?1',
        arguments: [id, isBookmarked ? 1 : 0]);
  }

  @override
  Future<void> deleteOldTrendingMovies() async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM movies WHERE isTrending = 1 AND isNowPlaying = 0 AND isBookmarked = 0');
  }

  @override
  Future<void> deleteOldNowPlayingMovies() async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM movies WHERE isNowPlaying = 1 AND isTrending = 0 AND isBookmarked = 0');
  }

  @override
  Future<void> insertMovie(MovieTableEntity movie) async {
    await _movieTableEntityInsertionAdapter.insert(
        movie, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertMovies(List<MovieTableEntity> movies) async {
    await _movieTableEntityInsertionAdapter.insertList(
        movies, OnConflictStrategy.replace);
  }
}
