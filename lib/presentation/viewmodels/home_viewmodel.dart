import 'package:flutter/foundation.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movie_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieRepository repository;

  HomeViewModel(this.repository);

  List<MovieEntity> _trendingMovies = [];
  List<MovieEntity> _nowPlayingMovies = [];
  bool _isLoading = false;
  bool _isLoadingMoreTrending = false;
  bool _isLoadingMoreNowPlaying = false;
  String? _error;
  
  int _trendingPage = 1;
  int _nowPlayingPage = 1;
  bool _hasMoreTrending = true;
  bool _hasMoreNowPlaying = true;

  List<MovieEntity> get trendingMovies => _trendingMovies;
  List<MovieEntity> get nowPlayingMovies => _nowPlayingMovies;
  bool get isLoading => _isLoading;
  bool get isLoadingMoreTrending => _isLoadingMoreTrending;
  bool get isLoadingMoreNowPlaying => _isLoadingMoreNowPlaying;
  String? get error => _error;
  bool get hasMoreTrending => _hasMoreTrending;
  bool get hasMoreNowPlaying => _hasMoreNowPlaying;

  Future<void> loadMovies() async {
    _isLoading = true;
    _error = null;
    _trendingPage = 1;
    _nowPlayingPage = 1;
    _hasMoreTrending = true;
    _hasMoreNowPlaying = true;
    notifyListeners();

    try {
      final trending = await repository.getTrendingMovies(page: 1);
      final nowPlaying = await repository.getNowPlayingMovies(page: 1);

      _trendingMovies = trending;
      _nowPlayingMovies = nowPlaying;
      _error = null;
      
      // Check if there are more pages (TMDB typically returns 20 movies per page)
      _hasMoreTrending = trending.length >= 20;
      _hasMoreNowPlaying = nowPlaying.length >= 20;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreTrendingMovies() async {
    if (_isLoadingMoreTrending || !_hasMoreTrending) return;

    _isLoadingMoreTrending = true;
    notifyListeners();

    try {
      _trendingPage++;
      final movies = await repository.getTrendingMovies(page: _trendingPage);
      
      if (movies.isEmpty) {
        _hasMoreTrending = false;
      } else {
        _trendingMovies.addAll(movies);
        // Check if there are more pages
        _hasMoreTrending = movies.length >= 20;
      }
    } catch (e) {
      _trendingPage--; // Revert page on error
      _error = e.toString();
    } finally {
      _isLoadingMoreTrending = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNowPlayingMovies() async {
    if (_isLoadingMoreNowPlaying || !_hasMoreNowPlaying) return;

    _isLoadingMoreNowPlaying = true;
    notifyListeners();

    try {
      _nowPlayingPage++;
      final movies = await repository.getNowPlayingMovies(page: _nowPlayingPage);
      
      if (movies.isEmpty) {
        _hasMoreNowPlaying = false;
      } else {
        _nowPlayingMovies.addAll(movies);
        // Check if there are more pages
        _hasMoreNowPlaying = movies.length >= 20;
      }
    } catch (e) {
      _nowPlayingPage--; // Revert page on error
      _error = e.toString();
    } finally {
      _isLoadingMoreNowPlaying = false;
      notifyListeners();
    }
  }
}

