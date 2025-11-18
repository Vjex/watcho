import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/search_screen.dart';
import '../../presentation/screens/bookmarks_screen.dart';
import '../../presentation/screens/movie_details_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/bookmarks',
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MovieDetailsScreen(movieId: id);
        },
      ),
    ],
    // Handle deep links - this would be configured in AndroidManifest.xml and Info.plist
    // For now, deep links are handled through share functionality
  );
}

