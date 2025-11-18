import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/movie_entity.dart';

class MovieCard extends StatelessWidget {
  final MovieEntity movie;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        width: 150,
        constraints: const BoxConstraints(maxHeight: 290), // Constrain max height
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl,
                width: 150,
                height: 215, // Further reduced to ensure fit
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 150,
                  height: 215,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 150,
                  height: 215,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Use Flexible with constrained height for title
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 36), // Max 2 lines
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.15, // Tighter line height
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 3),
            // Rating row with fixed height
            SizedBox(
              height: 18, // Fixed height for rating row
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

