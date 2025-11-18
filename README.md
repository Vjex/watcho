# Watcho - Movies Database Application

A Flutter application that displays trending and now-playing movies using the TMDB API. Users can search for movies, view details, bookmark favorites, and share movies with deep linking support.

## Features

✅ **Home Screen** - Displays trending and now-playing movies  
✅ **Movie Details** - Full movie information with bookmark and share functionality  
✅ **Search** - Real-time search with debounced API calls (500ms delay)  
✅ **Bookmarks** - Save and manage favorite movies  
✅ **Offline Support** - Movies are cached in local database for offline access  
✅ **Deep Linking** - Share movies with custom deep links  
✅ **MVVM Architecture** - Clean architecture with separation of concerns  
✅ **Repository Pattern** - Data layer abstraction  

## Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture with:

- **Domain Layer**: Entities and repository interfaces
- **Data Layer**: Models, data sources (remote & local), repository implementations
- **Presentation Layer**: UI screens, widgets, and view models
- **Core Layer**: Constants, utilities, dependency injection, routing

## Setup Instructions

### 1. Get TMDB API Key

1. Visit [TMDB](https://www.themoviedb.org/)
2. Create an account and go to Settings > API
3. Request an API key
4. Copy your API key

### 2. Configure API Key

Open `lib/core/constants/api_constants.dart` and replace `YOUR_TMDB_API_KEY_HERE` with your actual API key:

```dart
static const String apiKey = 'YOUR_ACTUAL_API_KEY';
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Generate Code

Run the build_runner to generate required code for:
- Retrofit API service
- JSON serialization
- Floor database

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── constants/       # API constants, app constants
│   ├── di/              # Dependency injection
│   ├── router/          # Navigation routing
│   └── utils/           # Utility classes
├── data/
│   ├── datasources/     # Remote and local data sources
│   ├── database/        # Floor database entities and DAOs
│   ├── models/          # Data models with JSON serialization
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Domain entities
│   └── repositories/    # Repository interfaces
└── presentation/
    ├── screens/         # UI screens
    ├── viewmodels/      # ViewModels for state management
    └── widgets/         # Reusable widgets
```

## Dependencies

- **retrofit** + **dio**: Networking and API calls
- **floor**: Local SQLite database
- **provider**: State management
- **cached_network_image**: Image loading and caching
- **share_plus**: Share functionality
- **go_router**: Navigation and deep linking
- **connectivity_plus**: Network connectivity checking

## Deep Linking

The app supports deep linking with the scheme: `watcho://movie/{movieId}`

Example: `watcho://movie/12345`

When a movie is shared, it includes this deep link that can be used to navigate directly to the movie details screen.

## Offline Support

The app automatically caches:
- Trending movies
- Now playing movies
- Movie details
- Bookmarked movies

When offline, the app will display cached data from the local database.

## Search Feature

The search feature includes:
- **Debounced search**: Waits 500ms after user stops typing before making API call
- **Real-time updates**: Results update as user types
- **Offline search**: Searches local database when offline

## Platform Support

✅ Android  
✅ iOS

## Notes

- Make sure to add your TMDB API key before running the app
- The first run will fetch data from the API and cache it locally
- Bookmarked movies persist across app restarts
- Deep links work when the app is installed and running
