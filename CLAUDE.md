# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Essential Commands
```bash
# Install dependencies
flutter pub get

# Generate JSON serialization code (required after model changes)
dart run build_runner build

# Clean and regenerate code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test
```

### Build Commands
```bash
# Build APK
flutter build apk

# Build iOS
flutter build ios

# Build web
flutter build web
```

## Architecture Overview

This is a **Smart Water Management (智慧水务)** Flutter application using **Clean Architecture** with the following layers:

### State Management
- **Flutter BLoC** for complex state management (authentication, user management)
- **Cubit** for simpler state management scenarios
- **MultiBlocProvider** pattern for dependency injection

### Navigation
- **GoRouter** for declarative routing with bottom navigation
- Main routes: `/login`, `/register`, `/home`, `/main`, `/qr-scan`

### Data Layer Architecture
- **Repository Pattern** for data access abstraction
- **Service Layer** with mock/real API switching capability
- **Environment-based configuration** (Development/Staging/Production)
- **Runtime data source switching** (Mock/Real API) via developer settings

### Dependency Injection
- **GetIt** service locator pattern
- **Service registration** in `lib/config/service_locator.dart`
- **Lazy loading** of services for optimal performance

## Key Architectural Patterns

### Mock/Real API System
The app has a sophisticated mock system that allows runtime switching between mock data and real APIs:

```dart
// Switch between mock and real API
await AppConfig.setDataSource(DataSource.mock);  // or DataSource.api
```

- **Mock implementations** in `lib/services/api/mock/`
- **Real implementations** in `lib/services/api/implementations/`
- **Interfaces** in `lib/services/api/interfaces/`
- **Factory pattern** automatically selects correct implementation based on config

### QR Scanning Business Logic
The app includes specialized QR scanning functionality for water infrastructure management:

- **Acceptance (验收)**: Single and batch pipe acceptance
- **Installation (安装/核销)**: Pipe installation verification
- **Inspection (巡检)**: Pipe inspection and querying
- **Strategy pattern** for different scanning modes

### Environment Configuration
- **Three environments**: Development, Staging, Production
- **Runtime environment switching** via developer settings
- **Persistent configuration** stored in SharedPreferences
- **Different API endpoints** per environment

## Important Files and Directories

### Configuration
- `lib/config/app_config.dart` - Environment and data source configuration
- `lib/config/service_locator.dart` - Dependency injection setup
- `lib/config/routes.dart` - GoRouter navigation configuration

### Core Services
- `lib/services/api_service_factory.dart` - Factory for API service selection
- `lib/services/storage_service.dart` - SharedPreferences wrapper
- `lib/services/qr_scan_service.dart` - QR scanning business logic

### Models
- All models use **json_annotation** for serialization
- **Equatable** for value equality
- Generated files with `.g.dart` extension (run build_runner after changes)

### State Management
- `lib/bloc/` - Complex state management with BLoC
- `lib/cubits/` - Simple state management with Cubit

## Development Workflow

### After Model Changes
Always run code generation after modifying models:
```bash
dart run build_runner build
```

### Environment Setup
The app defaults to **Development + Mock** mode. To change:
1. Use developer settings in the app, or
2. Call setup functions in `service_locator.dart`:
   ```dart
   await setupMockEnvironment();        // Dev + Mock
   await setupDevelopmentEnvironment(); // Dev + Real API
   await setupProductionEnvironment();  // Prod + Real API
   ```

### Testing Strategy
- **Widget tests** in `/test/` directory
- **Mock data** with realistic network delays for testing
- **Comprehensive mock data generator** for all business scenarios

## Business Domain Knowledge

This app is specifically designed for water utility infrastructure management:
- **Pipe management** with QR code identification
- **Work order processing** for installation, inspection, and acceptance
- **Chinese language interface** for domestic water utility companies
- **Mobile-first design** for field workers

## Code Style Notes

- **Clean Architecture** principles enforced
- **Separation of concerns** between UI, business logic, and data
- **Interface-based design** for testability and flexibility
- **Comprehensive error handling** with proper user feedback
- **Consistent naming conventions** following Dart/Flutter standards

## Dependencies Notes

### Core Dependencies
- `flutter_bloc: ^8.1.3` - State management
- `go_router: ^14.2.7` - Navigation
- `get_it: ^7.7.0` - Dependency injection
- `dio: ^5.4.1` - HTTP client
- `mobile_scanner: ^5.0.1` - QR code scanning
- `shared_preferences: ^2.2.2` - Local storage

### Code Generation
- `json_annotation: ^4.8.1` + `json_serializable: ^6.7.1` - JSON serialization
- `build_runner: ^2.4.7` - Code generation runner

## Common Development Tasks

### Adding New API Endpoints
1. Define interface in `lib/services/api/interfaces/`
2. Create mock implementation in `lib/services/api/mock/`
3. Create real implementation in `lib/services/api/implementations/`
4. Update factory in `api_service_factory.dart`
5. Update repository to use new endpoint

### Adding New Models
1. Create model in appropriate `lib/models/` subdirectory
2. Add `json_annotation` and `equatable`
3. Run `dart run build_runner build`
4. Update repository and BLoC/Cubit as needed

### Adding New Pages
1. Create page in `lib/pages/` with appropriate subdirectory
2. Add route to `lib/config/routes.dart`
3. Create corresponding BLoC/Cubit for state management
4. Register dependencies in `service_locator.dart` if needed