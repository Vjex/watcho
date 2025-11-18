import 'package:floor/floor.dart';
import '../../models/movie_model.dart';

@Entity(tableName: 'movies')
class MovieTableEntity {
  @primaryKey
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final int voteCount;
  final double popularity;
  final bool isTrending;
  final bool isNowPlaying;
  final bool isBookmarked;
  @ColumnInfo(name: 'last_updated')
  final int lastUpdated;

  MovieTableEntity({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.popularity,
    this.isTrending = false,
    this.isNowPlaying = false,
    this.isBookmarked = false,
    required this.lastUpdated,
  });

  factory MovieTableEntity.fromMovieModel(
    MovieModel model, {
    bool isTrending = false,
    bool isNowPlaying = false,
    bool isBookmarked = false,
  }) {
    return MovieTableEntity(
      id: model.id,
      title: model.title,
      overview: model.overview,
      posterPath: model.posterPath,
      backdropPath: model.backdropPath,
      releaseDate: model.releaseDate,
      voteAverage: model.voteAverage,
      voteCount: model.voteCount,
      popularity: model.popularity,
      isTrending: isTrending,
      isNowPlaying: isNowPlaying,
      isBookmarked: isBookmarked,
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );
  }

  MovieModel toMovieModel() {
    return MovieModel(
      adult: false,
      backdropPath: backdropPath,
      genreIds: [],
      id: id,
      originalLanguage: 'en',
      originalTitle: title,
      overview: overview,
      popularity: popularity,
      posterPath: posterPath,
      releaseDate: releaseDate,
      title: title,
      video: false,
      voteAverage: voteAverage,
      voteCount: voteCount,
    );
  }
}

