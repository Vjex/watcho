import 'package:flutter/foundation.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movie_repository.dart';

class MovieDetailsViewModel extends ChangeNotifier {
  final MovieRepository repository;
  final int movieId;

  MovieDetailsViewModel(this.repository, this.movieId);

  MovieEntity? _movie;
  bool _isLoading = false;
  String? _error;
  bool _isBookmarked = false;

  MovieEntity? get movie => _movie;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isBookmarked => _isBookmarked;

  Future<void> loadMovieDetails() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _movie = await repository.getMovieDetails(movieId);
      _isBookmarked = await repository.isMovieBookmarked(movieId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleBookmark() async {
    if (_movie == null) return;

    try {
      if (_isBookmarked) {
        await repository.unbookmarkMovie(movieId);
        _isBookmarked = false;
      } else {
        await repository.bookmarkMovie(_movie!);
        _isBookmarked = true;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

