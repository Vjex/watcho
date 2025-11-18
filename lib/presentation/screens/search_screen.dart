import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';
import '../widgets/movie_card.dart';
import '../../domain/entities/movie_entity.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController? _searchController;
  SearchViewModel? _viewModel;
  bool _isUpdatingFromViewModel = false;
  bool _initialized = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted || _initialized) return;
    
    // Get ViewModel reference safely in didChangeDependencies
    _viewModel = context.read<SearchViewModel>();
    _searchController = TextEditingController(text: _viewModel!.query);
    
    // Listen to ViewModel changes to sync controller
    _viewModel!.addListener(_syncController);
    _initialized = true;
  }

  void _syncController() {
    if (!mounted || _viewModel == null || _searchController == null) return;
    if (!_isUpdatingFromViewModel && _searchController!.text != _viewModel!.query) {
      _isUpdatingFromViewModel = true;
      _searchController!.text = _viewModel!.query;
      _isUpdatingFromViewModel = false;
    }
  }

  void _onScroll() {
    if (_viewModel == null || !_scrollController.hasClients) return;
    
    // Load more when user scrolls near the bottom (80%)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (_viewModel!.hasMore &&
          !_viewModel!.isLoadingMore &&
          !_viewModel!.isLoading) {
        _viewModel!.loadMore();
      }
    }
  }

  @override
  void dispose() {
    // Use saved reference instead of context.read()
    _viewModel?.removeListener(_syncController);
    _searchController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToMovieDetails(MovieEntity movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movieId: movie.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Movies'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<SearchViewModel>(
              builder: (context, viewModel, child) {
                if (_searchController == null) {
                  return const SizedBox.shrink();
                }
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for movies...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: viewModel.query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController?.clear();
                              viewModel.clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    if (!_isUpdatingFromViewModel) {
                      viewModel.onQueryChanged(value);
                    }
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.query.isEmpty) {
                  return const Center(
                    child: Text(
                      'Start typing to search for movies...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${viewModel.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.onQueryChanged(viewModel.query),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.searchResults.isEmpty) {
                  return const Center(
                    child: Text(
                      'No movies found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: viewModel.searchResults.length +
                      (viewModel.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show loading indicator at the end
                    if (index == viewModel.searchResults.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final movie = viewModel.searchResults[index];
                    return MovieCard(
                      movie: movie,
                      onTap: () => _navigateToMovieDetails(movie),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

