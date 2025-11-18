import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/movie_response.dart';
import '../../../core/constants/api_constants.dart';

part 'tmdb_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class TmdbApiService {
  factory TmdbApiService(Dio dio, {String baseUrl}) = _TmdbApiService;

  @GET(ApiConstants.trendingMovies)
  Future<MovieResponse> getTrendingMovies(
    @Query('api_key') String apiKey,
    @Query('page') int page,
  );

  @GET(ApiConstants.nowPlayingMovies)
  Future<MovieResponse> getNowPlayingMovies(
    @Query('api_key') String apiKey,
    @Query('page') int page,
  );

  @GET('${ApiConstants.movieDetails}/{id}')
  Future<Map<String, dynamic>> getMovieDetails(
    @Path('id') int id,
    @Query('api_key') String apiKey,
  );

  @GET(ApiConstants.searchMovies)
  Future<MovieResponse> searchMovies(
    @Query('api_key') String apiKey,
    @Query('query') String query,
    @Query('page') int page,
  );
}

