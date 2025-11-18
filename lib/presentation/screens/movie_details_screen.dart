import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../viewmodels/movie_details_viewmodel.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/dependency_injection.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late final MovieDetailsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MovieDetailsViewModel(
      DependencyInjection.repository,
      widget.movieId,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadMovieDetails();
    });
  }

  void _shareMovie() {
    final movie = _viewModel.movie;
    if (movie != null) {
      final deepLink = '${AppConstants.deepLinkScheme}://${AppConstants.deepLinkHost}/${movie.id}';
      final shareText = 'Check out ${movie.title}!\n$deepLink';
      Share.share(shareText);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        body: Consumer<MovieDetailsViewModel>(
          builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null || viewModel.movie == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.error ?? "Movie not found"}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadMovieDetails(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final movie = viewModel.movie!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: movie.backdropUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      viewModel.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    onPressed: () => viewModel.toggleBookmark(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: _shareMovie,
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: movie.posterUrl,
                              width: 120,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${movie.voteAverage.toStringAsFixed(1)} (${movie.voteCount} votes)',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                if (movie.releaseDate != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Release: ${movie.releaseDate}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.overview,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
          },
        ),
      ),
    );
  }
}

