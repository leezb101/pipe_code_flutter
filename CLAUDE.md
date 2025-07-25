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

#### Key Models
- `lib/models/user/user.dart` - Basic user information (role removed)
- `lib/models/user/user_role.dart` - Role enumeration with permissions
- `lib/models/project/project.dart` - Water management project details
- `lib/models/user/user_project_role.dart` - User-project-role associations
- `lib/models/menu/menu_config.dart` - Role-based menu configurations

### State Management
- `lib/bloc/` - Complex state management with BLoC
- `lib/cubits/` - Simple state management with Cubit

## Development Workflow

### After Model Changes
Always run code generation after modifying models:
```bash
dart run build_runner build
```

### User and Project Role Management
The app now supports a sophisticated user-project-role system:

#### Key Changes Made
1. **Removed direct role binding from User model** - roles are now project-specific
2. **Added UserRole enum** with 8 role types (suppliers, construction, supervisor, builder, check, builderSub, laborer, playgoer)
3. **Created Project model** for water management projects
4. **Implemented UserProjectRole** to manage user roles within specific projects
5. **Added MenuConfig system** that displays different menus based on user's current project role
6. **Refactored UserBloc** to support project switching and role management
7. **Updated HomePage** to dynamically show role-appropriate functionality

#### Project-Role Architecture
- Users can belong to multiple projects with different roles in each
- The app maintains a current project context with the user's role in that project
- Home page menus change based on the current project and role
- Users can switch between projects using the dropdown in the app bar

#### Role-Based Menu System
Each role has specific menu items and permissions:
- **Suppliers**: Product management, order management, delivery tracking
- **Construction**: Project overview, contract management, progress monitoring, quality control
- **Supervisor**: Inspection tasks, quality reports, acceptance management
- **Builder**: Construction tasks, material management, safety records, QR operations
- **Check**: Quality inspection, test reports
- **BuilderSub**: Sub-task allocation, team management
- **Laborer**: Work tasks, delegate operations (harvest/acceptance)
- **Playgoer**: Basic info, feedback

### Environment Setup
The app defaults to **Development + Mock** mode. To change:
1. Use developer settings in the app, or
2. Call setup functions in `service_locator.dart`:
   ```dart
   await setupMockEnvironment();        // Dev + Mock
   await setupDevelopmentEnvironment(); // Dev + Real API
   await setupProductionEnvironment();  // Prod + Real API
   ```

### Performance Optimizations

#### Repository Caching System
To prevent redundant data loading, the `UserRepository` implements an in-memory caching mechanism:

- **User data caching**: Avoids repeated `loadUserFromStorage` calls
- **Project context caching**: Reduces redundant project role lookups
- **Cache timeout**: 5-minute automatic cache expiration
- **Smart invalidation**: Cache cleared on user logout or data updates

#### Page Load Optimization
UI pages now check BLoC state before triggering data loads:

- **ProfilePage**: Only loads if state is `UserInitial` or `UserEmpty`
- **HomePage**: Only loads if state is not `UserProjectContextLoaded`
- **Prevents redundant calls** after successful login

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

## State Management Patterns

### BLoC Architecture Insights

#### Concerns and State Separation
- **UserBloc**: Only focuses on user basic information (login/registration/profile)
- **ProjectBloc**: Only manages project roles and menus (project switching/role management)

#### State Independence
- User login success ≠ Project must load successfully
- Project switching failure ≠ User needs to re-login
- Errors in one domain do not affect the other

#### Maintainability Benefits
- Clear responsibility boundaries: Each BLoC manages its own domain
- Improved testability: User and project logic can be tested independently
- Enhanced extensibility: Can add project-related features without affecting user management

#### State Flow Diagram
- User State: UserInitial → UserLoading → UserLoaded
                                    ↘ UserError/UserEmpty

- Project State: ProjectInitial → ProjectLoading → ProjectContextLoaded
                                          ↘ ProjectError/ProjectEmpty

#### Problem Resolution Workflow

##### Before Refactoring
- Login successful → UserBloc loads user data ✅
- UserBloc loads project data ❌ Fails
- emit UserEmpty ❌ User state cleared
- ProfilePage shows blank ❌

##### After Refactoring
- Login successful → UserBloc loads user data ✅ UserLoaded state
- ProjectBloc loads project data ❌ Fails
- emit ProjectError ✅ Only affects project state
- ProfilePage displays user information normally ✅
- HomePage shows project error information ✅

Key Improvement: Completely independent state flows, solving the original state coupling problem. This refactoring ensures robust user and project state management with clear separation of concerns.

## Code Best Practices

### Context Management
- **Important**: Don't use 'buildContext's across async gaps, guarded by an unrelated 'mounted' check.