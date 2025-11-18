import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/viewmodels/search_viewmodel.dart';
import 'presentation/viewmodels/bookmarks_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await DependencyInjection.setup();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final movieRepository = DependencyInjection.repository;
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(movieRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(movieRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BookmarksViewModel(movieRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Watcho',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
