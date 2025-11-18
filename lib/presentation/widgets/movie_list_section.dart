import 'package:flutter/material.dart';
import 'movie_card.dart';
import '../../domain/entities/movie_entity.dart';

class MovieListSection extends StatefulWidget {
  final String title;
  final List<MovieEntity> movies;
  final Function(MovieEntity) onMovieTap;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  const MovieListSection({
    super.key,
    required this.title,
    required this.movies,
    required this.onMovieTap,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  @override
  State<MovieListSection> createState() => _MovieListSectionState();
}

class _MovieListSectionState extends State<MovieListSection> {
  final ScrollController _scrollController = ScrollController();
  bool _hasTriggeredLoadMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // User scrolled to 80% of the list
      if (widget.hasMore &&
          !widget.isLoadingMore &&
          widget.onLoadMore != null &&
          !_hasTriggeredLoadMore) {
        _hasTriggeredLoadMore = true;
        widget.onLoadMore!();
        // Reset flag after a delay to allow next load
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _hasTriggeredLoadMore = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 290,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: widget.movies.length + (widget.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end if there are more items
              if (index == widget.movies.length) {
                return Container(
                  width: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return MovieCard(
                movie: widget.movies[index],
                onTap: () => widget.onMovieTap(widget.movies[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

