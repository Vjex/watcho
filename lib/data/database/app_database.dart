import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'entities/movie_table_entity.dart';
import 'daos/movie_dao.dart';
import '../../core/constants/app_constants.dart';

part 'app_database.g.dart';

@Database(version: AppConstants.databaseVersion, entities: [MovieTableEntity])
abstract class AppDatabase extends FloorDatabase {
  MovieDao get movieDao;
}

