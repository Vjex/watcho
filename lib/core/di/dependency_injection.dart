import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/datasources/remote/tmdb_api_service.dart';
import '../../data/datasources/remote/movie_remote_datasource.dart';
import '../../data/datasources/local/movie_local_datasource.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../core/utils/network_info.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/retry_interceptor.dart';

class DependencyInjection {
  static Future<void> setup() async {
    // Initialize database with migration
    final database = await $FloorAppDatabase
        .databaseBuilder(AppConstants.databaseName)
        .addMigrations([
          // // Migration from version 1 to 2: Add last_updated column
          // Migration(1, 2, (database) async {
          //   // Check if column already exists by querying the schema
          //   final result = await database.rawQuery(
          //     "PRAGMA table_info(movies)",
          //   );
          //   final hasLastUpdated = result.any((row) => row['name'] == 'last_updated');
            
          //   if (!hasLastUpdated) {
          //     // SQLite doesn't support adding NOT NULL columns directly
          //     // So we add it as nullable first, then update existing rows
          //     await database.execute(
          //       'ALTER TABLE movies ADD COLUMN last_updated INTEGER',
          //     );
          //     // Update existing rows with current timestamp
          //     final currentTime = DateTime.now().millisecondsSinceEpoch;
          //     await database.execute(
          //       'UPDATE movies SET last_updated = $currentTime WHERE last_updated IS NULL',
          //     );
          //   }
          // }),
        ])
        .build();

    // Initialize Dio with retry logic
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Add retry interceptor for connection errors
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      maxRetries: 3,
      retryDelay: const Duration(seconds: 1),
    ));

    // Initialize API Service
    final apiService = TmdbApiService(dio);

    // Initialize Data Sources
    final remoteDataSource = MovieRemoteDataSourceImpl(apiService);
    final localDataSource = MovieLocalDataSourceImpl(database.movieDao);

    // Initialize Network Info
    final networkInfo = NetworkInfo(Connectivity());

    // Initialize Repository
    final movieRepository = MovieRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );

    // Store repository
    _movieRepository = movieRepository;
  }

  static MovieRepository? _movieRepository;

  static MovieRepository get repository {
    if (_movieRepository == null) {
      throw Exception('DependencyInjection.setup() must be called first');
    }
    return _movieRepository!;
  }
}

