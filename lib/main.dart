import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/dependency_injection.dart';
import 'core/router/app_router.dart';
import 'core/handlers/deep_link_handler.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/viewmodels/search_viewmodel.dart';
import 'presentation/viewmodels/bookmarks_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await DependencyInjection.setup();
  
  // Initialize deep link handler
  final deepLinkHandler = DeepLinkHandler();
  await deepLinkHandler.initialize();
  
  runApp(MyApp(deepLinkHandler: deepLinkHandler));
}

class MyApp extends StatefulWidget {
  final DeepLinkHandler deepLinkHandler;
  
  const MyApp({super.key, required this.deepLinkHandler});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    widget.deepLinkHandler.dispose();
    super.dispose();
  }

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
      child: MaterialApp.router(
        title: 'Watcho',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
