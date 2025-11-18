import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bookmarks_viewmodel.dart';
import '../widgets/movie_card.dart';
import '../../domain/entities/movie_entity.dart';
import 'movie_details_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarksViewModel>().loadBookmarkedMovies();
    });
  }

  void _navigateToMovieDetails(MovieEntity movie) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movieId: movie.id),
      ),
    );
    // Refresh bookmarks when returning from details screen
    if (mounted) {
      context.read<BookmarksViewModel>().loadBookmarkedMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks'),
        elevation: 0,
      ),
      body: Consumer<BookmarksViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.bookmarkedMovies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null && viewModel.bookmarkedMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadBookmarkedMovies(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.bookmarkedMovies.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No bookmarked movies yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadBookmarkedMovies(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: viewModel.bookmarkedMovies.length,
              itemBuilder: (context, index) {
                final movie = viewModel.bookmarkedMovies[index];
                return MovieCard(
                  movie: movie,
                  onTap: () => _navigateToMovieDetails(movie),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

