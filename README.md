# Flutter Bloc Template

A clean architecture Flutter template using Bloc/Cubit for state management and GoRouter for navigation.

## Features

- **State Management**: Flutter Bloc with Cubit
- **Navigation**: GoRouter with bottom navigation
- **Architecture**: Clean architecture with repository pattern
- **Dependency Injection**: GetIt service locator
- **HTTP Client**: Dio for API calls
- **Local Storage**: SharedPreferences for data persistence
- **JSON Serialization**: json_annotation with code generation

## Project Structure

```
lib/
├── bloc/           # Bloc classes for complex state management
│   └── auth/       # Authentication bloc
├── cubits/         # Cubit classes for simple state management
├── config/         # App configuration
│   ├── routes.dart         # GoRouter configuration
│   └── service_locator.dart # Dependency injection setup
├── models/         # Data models
│   ├── user/
│   └── list_item/
├── pages/          # UI pages
│   ├── auth/       # Login/Register pages
│   ├── home/       # Home page
│   ├── list/       # List page with pull-to-refresh
│   ├── profile/    # Profile page
│   └── main_page.dart # Main page with bottom navigation
├── repositories/   # Data repositories
├── services/       # Services (API, Storage)
├── utils/          # Utility functions
└── widgets/        # Reusable widgets
```

## Pages Implemented

1. **Login Page**: Authentication with username/password
2. **Register Page**: User registration with validation
3. **Home Page**: Welcome screen with app info
4. **List Page**: Scrollable list with pull-to-refresh functionality
5. **Profile Page**: User profile with logout functionality

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Generate code for JSON serialization:
   ```bash
   dart run build_runner build
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Architecture Overview

- **Presentation Layer**: Pages and widgets
- **Business Logic Layer**: Bloc/Cubit classes
- **Data Layer**: Repositories and services
- **Models**: Data transfer objects with JSON serialization

## Key Dependencies

- `flutter_bloc`: State management
- `go_router`: Navigation
- `get_it`: Dependency injection
- `dio`: HTTP client
- `shared_preferences`: Local storage
- `json_annotation`: JSON serialization
- `equatable`: Value equality

## Development Notes

- Mock API calls are configured for demo purposes
- Local storage is used to persist authentication state
- Clean architecture principles are followed
- All pages include proper error handling and loading states