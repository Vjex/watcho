import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'bookmarks_screen.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/bookmarks_viewmodel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const BookmarksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          final previousIndex = _currentIndex;
          setState(() {
            _currentIndex = index;
          });
          
          // Reload data when switching to Home or Bookmarks tab
          if (index == 0 && previousIndex != 0) {
            // Switched to Home tab
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<HomeViewModel>().loadMovies();
            });
          } else if (index == 2 && previousIndex != 2) {
            // Switched to Bookmarks tab
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<BookmarksViewModel>().loadBookmarkedMovies();
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
        ],
      ),
    );
  }
}

