import '../../models/movie_model.dart';
import 'tmdb_api_service.dart';
import '../../../core/constants/api_constants.dart';

// Extension to handle Map response from Retrofit
extension MapResponse on Map<String, dynamic> {
  Map<String, dynamic> get data => this;
}

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getTrendingMovies({int page = 1});
  Future<List<MovieModel>> getNowPlayingMovies({int page = 1});
  Future<MovieModel> getMovieDetails(int id);
  Future<List<MovieModel>> searchMovies(String query, {int page = 1});
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final TmdbApiService apiService;

  MovieRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<MovieModel>> getTrendingMovies({int page = 1}) async {
    final response = await apiService.getTrendingMovies(
      ApiConstants.apiKey,
      page,
    );
    return response.results;
  }

  @override
  Future<List<MovieModel>> getNowPlayingMovies({int page = 1}) async {
    final response = await apiService.getNowPlayingMovies(
      ApiConstants.apiKey,
      page,
    );
    return response.results;
  }

  @override
  Future<MovieModel> getMovieDetails(int id) async {
    final response = await apiService.getMovieDetails(id, ApiConstants.apiKey);
    
    // Movie details API returns 'genres' (list of objects) instead of 'genre_ids' (list of ints)
    // Transform the response to match MovieModel structure
    final transformedResponse = Map<String, dynamic>.from(response);
    
    // Extract genre IDs from genres array if it exists
    if (transformedResponse.containsKey('genres') && 
        !transformedResponse.containsKey('genre_ids')) {
      final genres = transformedResponse['genres'];
      if (genres != null && genres is List) {
        transformedResponse['genre_ids'] = genres
            .whereType<Map<String, dynamic>>()
            .map((genre) => genre['id'])
            .whereType<int>()
            .toList();
      } else {
        transformedResponse['genre_ids'] = <int>[];
      }
    } else if (!transformedResponse.containsKey('genre_ids') || 
               transformedResponse['genre_ids'] == null) {
      // If neither genres nor genre_ids exist, set empty list
      transformedResponse['genre_ids'] = <int>[];
    } else if (transformedResponse['genre_ids'] is! List) {
      // Ensure genre_ids is a list
      transformedResponse['genre_ids'] = <int>[];
    }
    
    // Ensure all required fields have defaults if missing
    transformedResponse['adult'] ??= false;
    transformedResponse['original_language'] ??= 'en';
    transformedResponse['original_title'] ??= transformedResponse['title'] ?? '';
    transformedResponse['video'] ??= false;
    
    // Ensure numeric fields are properly typed
    if (transformedResponse['id'] != null) {
      transformedResponse['id'] = (transformedResponse['id'] as num).toInt();
    }
    if (transformedResponse['vote_average'] != null) {
      transformedResponse['vote_average'] = (transformedResponse['vote_average'] as num).toDouble();
    }
    if (transformedResponse['vote_count'] != null) {
      transformedResponse['vote_count'] = (transformedResponse['vote_count'] as num).toInt();
    }
    if (transformedResponse['popularity'] != null) {
      transformedResponse['popularity'] = (transformedResponse['popularity'] as num).toDouble();
    }
    
    return MovieModel.fromJson(transformedResponse);
  }

  @override
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    final response = await apiService.searchMovies(
      ApiConstants.apiKey,
      query,
      page,
    );
    return response.results;
  }
}

