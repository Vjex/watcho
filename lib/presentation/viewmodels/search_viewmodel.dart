import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../core/constants/app_constants.dart';

class SearchViewModel extends ChangeNotifier {
  final MovieRepository repository;

  SearchViewModel(this.repository);

  List<MovieEntity> _searchResults = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _query = '';
  int _currentPage = 1;
  bool _hasMore = true;
  Timer? _debounceTimer;

  List<MovieEntity> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get query => _query;
  bool get hasMore => _hasMore;

  void onQueryChanged(String query) {
    _query = query;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    // Start new timer
    _debounceTimer = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceDelay),
      () => _performSearch(query, page: 1),
    );
  }

  Future<void> _performSearch(String query, {int page = 1}) async {
    if (page == 1) {
      _isLoading = true;
      _error = null;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final results = await repository.searchMovies(query, page: page);
      
      if (page == 1) {
        _searchResults = results;
      } else {
        _searchResults.addAll(results);
      }
      
      _error = null;
      // Check if there are more pages (TMDB typically returns 20 movies per page)
      _hasMore = results.length >= 20;
    } catch (e) {
      _error = e.toString();
      if (page == 1) {
        _searchResults = [];
      }
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _query.isEmpty) return;

    _currentPage++;
    await _performSearch(_query, page: _currentPage);
  }

  void clearSearch() {
    _query = '';
    _searchResults = [];
    _error = null;
    _currentPage = 1;
    _hasMore = true;
    _debounceTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

