import 'package:go_router/go_router.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/movie_details_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const MainScreen(initialIndex: 1),
      ),
      GoRoute(
        path: '/bookmarks',
        builder: (context, state) => const MainScreen(initialIndex: 2),
      ),
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          if (idStr == null) {
            // Invalid movie ID, redirect to home
            return const MainScreen();
          }
          final id = int.tryParse(idStr);
          if (id == null || id <= 0) {
            // Invalid movie ID, redirect to home
            return const MainScreen();
          }
          return MovieDetailsScreen(movieId: id);
        },
      ),
    ],
    errorBuilder: (context, state) {
      // Handle unknown routes - redirect to home
      return const MainScreen();
    },
    redirect: (context, state) {
      // Handle deep links that need to navigate to home first, then to movie
      // This is handled by DeepLinkHandler in main.dart
      return null;
    },
  );

  /// Navigate to movie details from deep link
  /// Uses push to ensure back button works correctly
  static void navigateToMovie(int movieId) {
    router.push('/movie/$movieId');
  }

  /// Navigate to home screen
  static void navigateToHome() {
    // Only go to home if not already there
    if (router.routerDelegate.currentConfiguration.uri.path != '/') {
      router.go('/');
    }
  }
}

