import 'package:floor/floor.dart';
import '../entities/movie_table_entity.dart';

@dao
abstract class MovieDao {
  @Query('SELECT * FROM movies WHERE isTrending = 1 ORDER BY popularity DESC')
  Future<List<MovieTableEntity>> getTrendingMovies();

  @Query('SELECT * FROM movies WHERE isNowPlaying = 1 ORDER BY releaseDate DESC')
  Future<List<MovieTableEntity>> getNowPlayingMovies();

  @Query('SELECT * FROM movies WHERE isBookmarked = 1 ORDER BY last_updated DESC')
  Future<List<MovieTableEntity>> getBookmarkedMovies();

  @Query('SELECT * FROM movies WHERE id = :id')
  Future<MovieTableEntity?> getMovieById(int id);

  @Query('SELECT * FROM movies WHERE title LIKE :query OR overview LIKE :query')
  Future<List<MovieTableEntity>> searchMovies(String query);

  // Helper method to format search query
  static String formatSearchQuery(String query) {
    return '%$query%';
  }

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertMovie(MovieTableEntity movie);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertMovies(List<MovieTableEntity> movies);

  @Query('UPDATE movies SET isBookmarked = :isBookmarked WHERE id = :id')
  Future<void> updateBookmarkStatus(int id, bool isBookmarked);

  @Query('DELETE FROM movies WHERE isTrending = 1 AND isNowPlaying = 0 AND isBookmarked = 0')
  Future<void> deleteOldTrendingMovies();

  @Query('DELETE FROM movies WHERE isNowPlaying = 1 AND isTrending = 0 AND isBookmarked = 0')
  Future<void> deleteOldNowPlayingMovies();
}

