import '../../database/daos/movie_dao.dart';
import '../../database/entities/movie_table_entity.dart';
import '../../models/movie_model.dart';

abstract class MovieLocalDataSource {
  Future<List<MovieTableEntity>> getTrendingMovies();
  Future<List<MovieTableEntity>> getNowPlayingMovies();
  Future<List<MovieTableEntity>> getBookmarkedMovies();
  Future<MovieTableEntity?> getMovieById(int id);
  Future<void> insertTrendingMovies(List<MovieModel> movies);
  Future<void> insertNowPlayingMovies(List<MovieModel> movies);
  Future<void> insertMovie(MovieTableEntity movie);
  Future<void> bookmarkMovie(MovieModel movie);
  Future<void> unbookmarkMovie(int id);
  Future<bool> isMovieBookmarked(int id);
  Future<List<MovieTableEntity>> searchMovies(String query);
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  final MovieDao movieDao;

  MovieLocalDataSourceImpl(this.movieDao);

  @override
  Future<List<MovieTableEntity>> getTrendingMovies() async {
    return await movieDao.getTrendingMovies();
  }

  @override
  Future<List<MovieTableEntity>> getNowPlayingMovies() async {
    return await movieDao.getNowPlayingMovies();
  }

  @override
  Future<List<MovieTableEntity>> getBookmarkedMovies() async {
    return await movieDao.getBookmarkedMovies();
  }

  @override
  Future<MovieTableEntity?> getMovieById(int id) async {
    return await movieDao.getMovieById(id);
  }

  @override
  Future<void> insertTrendingMovies(List<MovieModel> movies) async {
    final entities = <MovieTableEntity>[];
    for (final movie in movies) {
      // Check if movie already exists and is bookmarked
      final existing = await movieDao.getMovieById(movie.id);
      final isBookmarked = existing?.isBookmarked ?? false;
      
      entities.add(MovieTableEntity.fromMovieModel(
        movie,
        isTrending: true,
        isNowPlaying: existing?.isNowPlaying ?? false, // Preserve now playing status
        isBookmarked: isBookmarked, // Preserve bookmark status
      ));
    }
    await movieDao.insertMovies(entities);
  }

  @override
  Future<void> insertNowPlayingMovies(List<MovieModel> movies) async {
    final entities = <MovieTableEntity>[];
    for (final movie in movies) {
      // Check if movie already exists and is bookmarked
      final existing = await movieDao.getMovieById(movie.id);
      final isBookmarked = existing?.isBookmarked ?? false;
      
      entities.add(MovieTableEntity.fromMovieModel(
        movie,
        isTrending: existing?.isTrending ?? false, // Preserve trending status
        isNowPlaying: true,
        isBookmarked: isBookmarked, // Preserve bookmark status
      ));
    }
    await movieDao.insertMovies(entities);
  }

  @override
  Future<void> insertMovie(MovieTableEntity movie) async {
    await movieDao.insertMovie(movie);
  }

  @override
  Future<void> bookmarkMovie(MovieModel movie) async {
    // Check if movie already exists to preserve existing flags
    final existing = await movieDao.getMovieById(movie.id);
    
    // Always update last_updated to current time when bookmarking
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    if (existing != null) {
      // Movie exists - update with preserved flags and new timestamp
      final entity = MovieTableEntity(
        id: existing.id,
        title: movie.title,
        overview: movie.overview,
        posterPath: movie.posterPath,
        backdropPath: movie.backdropPath,
        releaseDate: movie.releaseDate,
        voteAverage: movie.voteAverage,
        voteCount: movie.voteCount,
        popularity: movie.popularity,
        isTrending: existing.isTrending, // Preserve trending status
        isNowPlaying: existing.isNowPlaying, // Preserve now playing status
        isBookmarked: true, // Set bookmark status
        lastUpdated: currentTime, // Update timestamp to move to top
      );
      await movieDao.insertMovie(entity);
    } else {
      // New movie - insert with current timestamp
      final entity = MovieTableEntity.fromMovieModel(
        movie,
        isTrending: false,
        isNowPlaying: false,
        isBookmarked: true,
      );
      // Override lastUpdated to ensure it's current
      final entityWithTimestamp = MovieTableEntity(
        id: entity.id,
        title: entity.title,
        overview: entity.overview,
        posterPath: entity.posterPath,
        backdropPath: entity.backdropPath,
        releaseDate: entity.releaseDate,
        voteAverage: entity.voteAverage,
        voteCount: entity.voteCount,
        popularity: entity.popularity,
        isTrending: entity.isTrending,
        isNowPlaying: entity.isNowPlaying,
        isBookmarked: entity.isBookmarked,
        lastUpdated: currentTime,
      );
      await movieDao.insertMovie(entityWithTimestamp);
    }
  }

  @override
  Future<void> unbookmarkMovie(int id) async {
    await movieDao.updateBookmarkStatus(id, false);
  }

  @override
  Future<bool> isMovieBookmarked(int id) async {
    final movie = await movieDao.getMovieById(id);
    return movie?.isBookmarked ?? false;
  }

  @override
  Future<List<MovieTableEntity>> searchMovies(String query) async {
    final formattedQuery = MovieDao.formatSearchQuery(query);
    return await movieDao.searchMovies(formattedQuery);
  }
}

