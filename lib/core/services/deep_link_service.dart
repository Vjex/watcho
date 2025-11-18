import 'dart:async';
import 'package:app_links/app_links.dart';
import '../constants/app_constants.dart';

enum DeepLinkType {
  movie,
  unknown,
  invalid,
}

class DeepLinkData {
  final DeepLinkType type;
  final int? movieId;
  final Uri? originalUri;

  DeepLinkData({
    required this.type,
    this.movieId,
    this.originalUri,
  });
}

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  final StreamController<DeepLinkData> _linkController = StreamController<DeepLinkData>.broadcast();
  bool _isInitialized = false;

  Stream<DeepLinkData> get linkStream => _linkController.stream;

  /// Initialize deep link listening
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Listen for deep links when app is running (hot/warm start)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (Object err) {
        _linkController.add(DeepLinkData(
          type: DeepLinkType.invalid,
          originalUri: null,
        ));
      },
    );

    // Check for initial link (when app is opened from a deep link - cold start)
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        // Delay to ensure app is fully initialized
        await Future.delayed(const Duration(milliseconds: 500));
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Handle deep link parsing and validation
  void _handleDeepLink(Uri uri) {
    final parsed = parseDeepLink(uri);
    _linkController.add(parsed);
  }

  /// Parse deep link and extract data
  /// Supports both custom scheme (watcho://movie/123) and HTTPS (https://watcho.app/movie/123)
  DeepLinkData parseDeepLink(Uri uri) {
    try {
      // Check if it's a custom scheme deep link: watcho://movie/123
      if (uri.scheme == AppConstants.deepLinkScheme) {
        // Check host
        if (uri.host != AppConstants.deepLinkHost) {
          return DeepLinkData(
            type: DeepLinkType.unknown,
            originalUri: uri,
          );
        }

        // Parse path segments
        final pathSegments = uri.pathSegments;
        
        // Handle empty path or root
        if (pathSegments.isEmpty) {
          return DeepLinkData(
            type: DeepLinkType.invalid,
            originalUri: uri,
          );
        }

        // Handle movie deep link: watcho://movie/123
        if (pathSegments.isNotEmpty) {
          final movieIdStr = pathSegments.first;
          final movieId = int.tryParse(movieIdStr);
          
          if (movieId != null && movieId > 0) {
            return DeepLinkData(
              type: DeepLinkType.movie,
              movieId: movieId,
              originalUri: uri,
            );
          } else {
            return DeepLinkData(
              type: DeepLinkType.invalid,
              originalUri: uri,
            );
          }
        }
      }
      // Check if it's an HTTPS deep link: https://watcho.app/movie/123
      else if (uri.scheme == 'https' || uri.scheme == 'http') {
        // Check domain
        if (uri.host == AppConstants.httpsDeepLinkDomain || 
            uri.host.endsWith('.${AppConstants.httpsDeepLinkDomain}')) {
          // Check path starts with /movie
          if (uri.path.startsWith(AppConstants.httpsDeepLinkPath)) {
            // Extract movie ID from path: /movie/123
            final pathSegments = uri.pathSegments;
            if (pathSegments.length >= 2 && pathSegments[0] == 'movie') {
              final movieIdStr = pathSegments[1];
              final movieId = int.tryParse(movieIdStr);
              
              if (movieId != null && movieId > 0) {
                return DeepLinkData(
                  type: DeepLinkType.movie,
                  movieId: movieId,
                  originalUri: uri,
                );
              } else {
                return DeepLinkData(
                  type: DeepLinkType.invalid,
                  originalUri: uri,
                );
              }
            } else {
              return DeepLinkData(
                type: DeepLinkType.invalid,
                originalUri: uri,
              );
            }
          } else {
            return DeepLinkData(
              type: DeepLinkType.unknown,
              originalUri: uri,
            );
          }
        } else {
          return DeepLinkData(
            type: DeepLinkType.unknown,
            originalUri: uri,
          );
        }
      } else {
        return DeepLinkData(
          type: DeepLinkType.unknown,
          originalUri: uri,
        );
      }

      return DeepLinkData(
        type: DeepLinkType.unknown,
        originalUri: uri,
      );
    } catch (e) {
      return DeepLinkData(
        type: DeepLinkType.invalid,
        originalUri: uri,
      );
    }
  }

  /// Generate deep link URL for a movie
  /// Uses HTTPS URL for better clickability in messaging apps
  static String generateMovieDeepLink(int movieId) {
    if (movieId <= 0) {
      throw ArgumentError('Movie ID must be greater than 0');
    }
    // Use HTTPS URL for better clickability in SMS/messaging apps
    return 'https://${AppConstants.httpsDeepLinkDomain}${AppConstants.httpsDeepLinkPath}/$movieId';
  }
  
  /// Generate custom scheme deep link (for internal use)
  static String generateCustomSchemeDeepLink(int movieId) {
    if (movieId <= 0) {
      throw ArgumentError('Movie ID must be greater than 0');
    }
    return '${AppConstants.deepLinkScheme}://${AppConstants.deepLinkHost}/$movieId';
  }

  /// Check if URI is a valid deep link for this app
  bool isValidDeepLink(Uri uri) {
    // Check custom scheme
    if (uri.scheme == AppConstants.deepLinkScheme &&
        uri.host == AppConstants.deepLinkHost) {
      return true;
    }
    // Check HTTPS scheme
    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        (uri.host == AppConstants.httpsDeepLinkDomain ||
         uri.host.endsWith('.${AppConstants.httpsDeepLinkDomain}')) &&
        uri.path.startsWith(AppConstants.httpsDeepLinkPath)) {
      return true;
    }
    return false;
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
    _linkController.close();
    _isInitialized = false;
  }
}

