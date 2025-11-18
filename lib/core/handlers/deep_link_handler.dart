import 'dart:async';
import 'package:flutter/material.dart';
import '../services/deep_link_service.dart';
import '../router/app_router.dart';

class DeepLinkHandler {
  final DeepLinkService _deepLinkService = DeepLinkService();
  StreamSubscription<DeepLinkData>? _linkSubscription;
  bool _isNavigating = false;

  /// Initialize deep link handling
  Future<void> initialize() async {
    await _deepLinkService.initialize();
    
    _linkSubscription = _deepLinkService.linkStream.listen(
      (DeepLinkData linkData) {
        _handleDeepLink(linkData);
      },
      onError: (error) {
        // Handle error - could show a snackbar or log
        debugPrint('Deep link error: $error');
      },
    );
  }

  /// Handle different types of deep links
  void _handleDeepLink(DeepLinkData linkData) {
    if (_isNavigating) return; // Prevent multiple simultaneous navigations
    
    switch (linkData.type) {
      case DeepLinkType.movie:
        _handleMovieDeepLink(linkData.movieId!);
        break;
      case DeepLinkType.invalid:
        _handleInvalidDeepLink();
        break;
      case DeepLinkType.unknown:
        _handleUnknownDeepLink(linkData.originalUri);
        break;
    }
  }

  /// Handle movie deep link
  /// Navigation flow: Home -> Movie Details (so back button works correctly)
  void _handleMovieDeepLink(int movieId) {
    if (movieId <= 0) {
      _handleInvalidDeepLink();
      return;
    }

    if (_isNavigating) return;
    _isNavigating = true;

    // Use a post-frame callback to ensure router is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // First ensure we're on home screen
        AppRouter.navigateToHome();
        
        // Then navigate to movie details after a delay
        // This ensures home screen is loaded first, so back button works
        // The delay allows the home screen to render before pushing movie details
        Future.delayed(const Duration(milliseconds: 800), () {
          try {
            AppRouter.navigateToMovie(movieId);
          } catch (e) {
            debugPrint('Error navigating to movie details: $e');
          } finally {
            _isNavigating = false;
          }
        });
      } catch (e) {
        debugPrint('Error navigating to home: $e');
        _isNavigating = false;
      }
    });
  }

  /// Handle invalid deep links
  void _handleInvalidDeepLink() {
    debugPrint('Invalid deep link received');
    // Navigate to home on invalid deep link
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        AppRouter.navigateToHome();
      } catch (e) {
        debugPrint('Error navigating to home: $e');
      }
    });
  }

  /// Handle unknown deep links
  void _handleUnknownDeepLink(Uri? uri) {
    debugPrint('Unknown deep link received: $uri');
    // Navigate to home on unknown deep link
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        AppRouter.navigateToHome();
      } catch (e) {
        debugPrint('Error navigating to home: $e');
      }
    });
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
    _isNavigating = false;
  }
}

