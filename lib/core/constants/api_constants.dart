class ApiConstants {
  // TMDB API key provided by the user
  static const String apiKey = 'b9743d85573cbb0fa66d86a017d53710';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String imageBaseUrlOriginal = 'https://image.tmdb.org/t/p/original';
  
  // Endpoints
  static const String trendingMovies = '/trending/movie/day';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String movieDetails = '/movie';
  static const String searchMovies = '/search/movie';
}

