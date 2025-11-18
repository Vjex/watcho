import '../entities/movie_entity.dart';

abstract class MovieRepository {
  Future<List<MovieEntity>> getTrendingMovies({int page = 1});
  Future<List<MovieEntity>> getNowPlayingMovies({int page = 1});
  Future<MovieEntity> getMovieDetails(int id);
  Future<List<MovieEntity>> searchMovies(String query, {int page = 1});
  Future<List<MovieEntity>> getBookmarkedMovies();
  Future<void> bookmarkMovie(MovieEntity movie);
  Future<void> unbookmarkMovie(int id);
  Future<bool> isMovieBookmarked(int id);
}

