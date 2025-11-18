import 'package:flutter/foundation.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movie_repository.dart';

class BookmarksViewModel extends ChangeNotifier {
  final MovieRepository repository;

  BookmarksViewModel(this.repository);

  List<MovieEntity> _bookmarkedMovies = [];
  bool _isLoading = false;
  String? _error;

  List<MovieEntity> get bookmarkedMovies => _bookmarkedMovies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBookmarkedMovies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookmarkedMovies = await repository.getBookmarkedMovies();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeBookmark(int movieId) async {
    try {
      await repository.unbookmarkMovie(movieId);
      _bookmarkedMovies.removeWhere((movie) => movie.id == movieId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

