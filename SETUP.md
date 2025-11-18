# Quick Setup Guide

## Step 1: Get TMDB API Key
1. Go to https://www.themoviedb.org/
2. Sign up/Login
3. Go to Settings > API
4. Request an API key (it's free)
5. Copy your API key

## Step 2: Add API Key to App
Edit `lib/core/constants/api_constants.dart`:
```dart
static const String apiKey = 'YOUR_API_KEY_HERE';  // Replace with your key
```

## Step 3: Install Dependencies
```bash
flutter pub get
```

## Step 4: Generate Code
This generates code for Retrofit, JSON serialization, and Floor database:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Step 5: Run the App
```bash
flutter run
```

## Troubleshooting

### If build_runner fails:
- Make sure all dependencies are installed: `flutter pub get`
- Try cleaning first: `flutter clean && flutter pub get`
- Then run: `flutter pub run build_runner build --delete-conflicting-outputs`

### If you see API errors:
- Verify your API key is correct in `api_constants.dart`
- Check your internet connection
- Make sure the API key has proper permissions in TMDB settings

### If database errors occur:
- Delete the app and reinstall
- Or clear app data on your device

## What You'll See

1. **Home Tab**: Trending and Now Playing movies
2. **Search Tab**: Search for any movie (with debounced search)
3. **Bookmarks Tab**: Your saved movies

## Features Implemented

✅ All required features  
✅ Both bonus tasks (debounced search + deep linking)  
✅ Offline support with local database  
✅ MVVM architecture  
✅ Repository pattern  
✅ Clean code structure  

Enjoy your movies app! 🎬

