import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../domain/entities/movie_entity.dart';
import '../widgets/movie_list_section.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadMovies();
    });
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
        title: const Text('Watcho'),
        elevation: 0,
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.trendingMovies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null && viewModel.trendingMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadMovies(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadMovies(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MovieListSection(
                    title: 'Trending Movies',
                    movies: viewModel.trendingMovies,
                    onMovieTap: _navigateToMovieDetails,
                    onLoadMore: viewModel.loadMoreTrendingMovies,
                    isLoadingMore: viewModel.isLoadingMoreTrending,
                    hasMore: viewModel.hasMoreTrending,
                  ),
                  const SizedBox(height: 16),
                  MovieListSection(
                    title: 'Now Playing',
                    movies: viewModel.nowPlayingMovies,
                    onMovieTap: _navigateToMovieDetails,
                    onLoadMore: viewModel.loadMoreNowPlayingMovies,
                    isLoadingMore: viewModel.isLoadingMoreNowPlaying,
                    hasMore: viewModel.hasMoreNowPlaying,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

