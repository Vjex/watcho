import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/movie_entity.dart';

part 'movie_model.g.dart';

@JsonSerializable()
class MovieModel extends MovieEntity {
  final bool adult;
  @JsonKey(name: 'backdrop_path')
  @override
  final String? backdropPath;
  @JsonKey(name: 'genre_ids')
  final List<int> genreIds;
  @override
  final int id;
  @JsonKey(name: 'original_language')
  final String originalLanguage;
  @JsonKey(name: 'original_title')
  final String originalTitle;
  @override
  final String overview;
  @override
  final double popularity;
  @JsonKey(name: 'poster_path')
  @override
  final String? posterPath;
  @JsonKey(name: 'release_date')
  @override
  final String? releaseDate;
  @override
  final String title;
  final bool video;
  @JsonKey(name: 'vote_average')
  @override
  final double voteAverage;
  @JsonKey(name: 'vote_count')
  @override
  final int voteCount;

  MovieModel({
    required this.adult,
    this.backdropPath,
    required this.genreIds,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    this.posterPath,
    this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  }) : super(
          id: id,
          title: title,
          overview: overview,
          posterPath: posterPath,
          backdropPath: backdropPath,
          releaseDate: releaseDate,
          voteAverage: voteAverage,
          voteCount: voteCount,
          popularity: popularity,
        );

  factory MovieModel.fromJson(Map<String, dynamic> json) =>
      _$MovieModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieModelToJson(this);
}

