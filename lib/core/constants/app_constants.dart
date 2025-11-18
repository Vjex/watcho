class AppConstants {
  // Deep Link Scheme
  static const String deepLinkScheme = 'watcho';
  static const String deepLinkHost = 'movie';
  
  // Database
  static const String databaseName = 'movies_database.db';
  static const int databaseVersion = 2; // Incremented to fix last_updated column issue
  
  // Search debounce delay (milliseconds)
  static const int searchDebounceDelay = 500;
}

