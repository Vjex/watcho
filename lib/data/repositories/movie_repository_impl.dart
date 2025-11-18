import '../../domain/repositories/movie_repository.dart';
import '../../domain/entities/movie_entity.dart';
import '../datasources/remote/movie_remote_datasource.dart';
import '../datasources/local/movie_local_datasource.dart';
import '../models/movie_model.dart';
import '../database/entities/movie_table_entity.dart';
import '../../core/utils/network_info.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<MovieEntity>> getTrendingMovies({int page = 1}) async {
    if (await networkInfo.isConnected) {
      try {
        final movies = await remoteDataSource.getTrendingMovies(page: page);
        // Only cache first page to avoid database bloat
        if (page == 1) {
          await localDataSource.insertTrendingMovies(movies);
        }
        return movies;
      } catch (e) {
        // If network fails, return cached data (only first page)
        if (page == 1) {
          final cachedMovies = await localDataSource.getTrendingMovies();
          return cachedMovies.map((e) => e.toMovieModel()).toList();
        }
        return [];
      }
    } else {
      // Offline: only return cached first page
      if (page == 1) {
        final cachedMovies = await localDataSource.getTrendingMovies();
        return cachedMovies.map((e) => e.toMovieModel()).toList();
      }
      return [];
    }
  }

  @override
  Future<List<MovieEntity>> getNowPlayingMovies({int page = 1}) async {
    if (await networkInfo.isConnected) {
      try {
        final movies = await remoteDataSource.getNowPlayingMovies(page: page);
        // Only cache first page to avoid database bloat
        if (page == 1) {
          await localDataSource.insertNowPlayingMovies(movies);
        }
        return movies;
      } catch (e) {
        // If network fails, return cached data (only first page)
        if (page == 1) {
          final cachedMovies = await localDataSource.getNowPlayingMovies();
          return cachedMovies.map((e) => e.toMovieModel()).toList();
        }
        return [];
      }
    } else {
      // Offline: only return cached first page
      if (page == 1) {
        final cachedMovies = await localDataSource.getNowPlayingMovies();
        return cachedMovies.map((e) => e.toMovieModel()).toList();
      }
      return [];
    }
  }

  @override
  Future<MovieEntity> getMovieDetails(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final movie = await remoteDataSource.getMovieDetails(id);
        // Save to local DB for offline access, preserving bookmark status
        final existing = await localDataSource.getMovieById(id);
        final entity = MovieTableEntity.fromMovieModel(
          movie,
          isTrending: existing?.isTrending ?? false,
          isNowPlaying: existing?.isNowPlaying ?? false,
          isBookmarked: existing?.isBookmarked ?? false, // Preserve bookmark status
        );
        await localDataSource.insertMovie(entity);
        return movie;
      } catch (e) {
        final cachedMovie = await localDataSource.getMovieById(id);
        if (cachedMovie != null) {
          return cachedMovie.toMovieModel();
        }
        rethrow;
      }
    } else {
      final cachedMovie = await localDataSource.getMovieById(id);
      if (cachedMovie != null) {
        return cachedMovie.toMovieModel();
      }
      throw Exception('Movie not found in cache');
    }
  }

  @override
  Future<List<MovieEntity>> searchMovies(String query, {int page = 1}) async {
    if (await networkInfo.isConnected) {
      try {
        final movies = await remoteDataSource.searchMovies(query, page: page);
        return movies;
      } catch (e) {
        // Fallback to local search (only first page)
        if (page == 1) {
          final cachedMovies = await localDataSource.searchMovies(query);
          return cachedMovies.map((e) => e.toMovieModel()).toList();
        }
        return [];
      }
    } else {
      // Offline: only return cached first page
      if (page == 1) {
        final cachedMovies = await localDataSource.searchMovies(query);
        return cachedMovies.map((e) => e.toMovieModel()).toList();
      }
      return [];
    }
  }

  @override
  Future<List<MovieEntity>> getBookmarkedMovies() async {
    final bookmarkedMovies = await localDataSource.getBookmarkedMovies();
    return bookmarkedMovies.map((e) => e.toMovieModel()).toList();
  }

  @override
  Future<void> bookmarkMovie(MovieEntity movie) async {
    if (movie is MovieModel) {
      await localDataSource.bookmarkMovie(movie);
    } else {
      // Convert entity to model if needed
      final movieModel = MovieModel(
        adult: false,
        backdropPath: movie.backdropPath,
        genreIds: [],
        id: movie.id,
        originalLanguage: 'en',
        originalTitle: movie.title,
        overview: movie.overview,
        popularity: movie.popularity,
        posterPath: movie.posterPath,
        releaseDate: movie.releaseDate,
        title: movie.title,
        video: false,
        voteAverage: movie.voteAverage,
        voteCount: movie.voteCount,
      );
      await localDataSource.bookmarkMovie(movieModel);
    }
  }

  @override
  Future<void> unbookmarkMovie(int id) async {
    await localDataSource.unbookmarkMovie(id);
  }

  @override
  Future<bool> isMovieBookmarked(int id) async {
    return await localDataSource.isMovieBookmarked(id);
  }
}

