# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Master Service** is a Flutter mobile application for service professionals (masters) to manage job requests, track payments, and interact with clients. The app is built with Flutter and Dart, using a clean architecture pattern with feature-driven organization.

### Key Technologies
- **Framework**: Flutter (Dart)
- **State Management**: BLoC (flutter_bloc)
- **Navigation**: GoRouter
- **Networking**: Dio (HTTP client) and WebSocket (real-time events)
- **Localization**: Turkmen and Russian language support
- **Storage**: flutter_secure_storage for token persistence
- **Serialization**: Freezed and json_serializable code generation

## Architecture

### Directory Structure

```
lib/
├── main.dart                    # App entry point with error handling and DI setup
├── app/                         # App-level configuration and routing
│   ├── master_app.dart         # Root MaterialApp widget
│   ├── router/                 # Navigation and routing
│   │   ├── app_router.dart     # GoRouter setup with auth-based redirection
│   │   ├── app_routes.dart     # Route path constants
│   │   └── main_shell.dart     # Bottom navigation shell with TabBar
│   ├── theme/                  # Material Design theming
│   │   ├── app_theme.dart      # ThemeData configuration
│   │   └── app_colors.dart     # Color constants
│   ├── widgets/                # App-wide widgets (AppBottomNavBar)
│   └── localization/           # i18n setup and translations
├── core/                        # Cross-cutting concerns
│   ├── config/                 # AppConfig with environment variables
│   ├── errors/                 # AppError, Result types
│   ├── logging/                # ConsoleAppLogger
│   ├── network/                # ApiClient (Dio configuration)
│   ├── realtime/               # WebSocket client for real-time events
│   ├── storage/                # SecureTokenStorage for tokens
│   └── utils/                  # Status enums, constants
└── features/                    # Feature modules (clean architecture)
    ├── auth/                   # Authentication (login, OTP, session)
    ├── jobs/                   # Job management and details
    ├── master_profile/         # Master profile and home screen
    ├── settings/               # Settings and account management
    ├── payments/               # Payment history and balance
    ├── map/                    # Location/map integration
    └── categories/             # Service categories
```

### Feature Module Structure

Each feature follows clean architecture with layers:

```
features/<feature>/
├── domain/              # Business logic and entities
│   └── *.dart          # Domain models (JobRequest, Master, etc.)
├── data/               # Data sources and repository implementations
│   ├── local_*.dart    # Local data repositories (mock implementations)
│   └── *_impl.dart     # Repository implementations
├── application/        # State management (BLoC/Cubit)
│   └── *_cubit.dart    # Cubit for feature state
└── presentation/       # UI layer
    └── screens/        # Screen widgets
        └── *_screen.dart
```

### Key Architectural Patterns

1. **BLoC/Cubit Pattern**: State is managed via Cubits with immutable State objects that use `copyWith()` for updates
2. **Result Type**: `Result<T>` sealed class wraps `Success<T>` or `Failure<T>` for error handling
3. **Auth-Based Navigation**: `AppRouter` redirects routes based on `AuthCubit` state (splash → login → otp → home)
4. **Repository Pattern**: Domain defines abstract repositories; data layer provides implementations
5. **Real-time Events**: WebSocket events (new_job, job_assigned, job_status_changed) streamed to UI
6. **Secure Storage**: Access tokens and session flags persisted in encrypted secure storage

### State Management Flow

Each feature cubit follows this pattern:
```dart
class XyzState {
  final AppStatus status;        // idle, loading, success, failure
  final XyzData? data;
  final String? errorMessage;
  XyzState copyWith({...});      // Immutable updates
}

class XyzCubit extends Cubit<XyzState> {
  Future<void> load() async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      final data = await _repository.fetch();
      emit(state.copyWith(status: AppStatus.success, data: data));
    } on Object {
      emit(state.copyWith(status: AppStatus.failure, errorMessage: '...'));
    }
  }
}
```

## Common Development Tasks

### Build and Run

```bash
# Get dependencies
flutter pub get

# Run the app in debug mode
flutter run

# Run the app with specific flavor/build variant
flutter run --dart-define=API_BASE_URL=https://your-api.com --dart-define=REALTIME_URL=wss://your-realtime.com

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS)
flutter build ios --release
```

### Code Generation

The project uses code generation for serialization and model freezing:

```bash
# Run build_runner to generate code (Freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation during development
flutter pub run build_runner watch
```

### Linting and Analysis

```bash
# Analyze Dart code for errors and style issues
flutter analyze

# Format code (applies the linter rules)
dart format lib test
```

### Testing

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/features/auth/application/auth_cubit_test.dart

# Run tests with coverage
flutter test --coverage

# Run tests matching a pattern
flutter test -k "auth_cubit"
```

### Localization

The app supports Turkmen and Russian. Translations are managed in `lib/app/localization/app_localizations.dart`. To add a new string:
1. Add the key-value pair to the localization file
2. Access via `AppLocalizations.of(context).text('key')`

## Environment Configuration

App configuration is managed via `AppConfig` in `lib/core/config/app_config.dart`. Use `--dart-define` flags when building:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://api.example.com \
  --dart-define=REALTIME_URL=wss://realtime.example.com \
  --dart-define=REQUIRE_RUNTIME_CONFIG=true
```

Key variables:
- `API_BASE_URL`: Base URL for REST API (default: https://api.example.com)
- `REALTIME_URL`: WebSocket URL for real-time events (default: wss://realtime.example.com)
- `REQUIRE_RUNTIME_CONFIG`: When true, validates config at runtime in production builds

## Authentication Flow

1. **Splash Screen** (initial state): Restores previous session or redirects to login
2. **Phone Login**: User enters phone number, OTP is requested
3. **OTP Verification**: User enters OTP code
4. **Home Screen**: Authenticated user lands on home with tabs (Home, Jobs, Map, Settings)
5. **Sign Out**: Clears secure storage and redirects to login

The `AuthCubit` manages this flow and broadcasts state changes via `GoRouterRefreshStream` to trigger navigation updates.

## Key Dependencies

- **flutter_bloc (9.1.1)**: State management
- **go_router (17.2.3)**: Navigation and routing
- **dio (5.9.2)**: HTTP client for REST API
- **web_socket_channel (3.0.3)**: WebSocket for real-time events
- **flutter_secure_storage (10.1.0)**: Encrypted token storage
- **flutter_map (8.3.0)**: Map display and location
- **freezed + json_serializable**: Code generation for models

## Common Patterns When Modifying Code

### Adding a New Feature

1. Create a feature folder under `lib/features/<feature>/`
2. Start with domain models in `domain/`
3. Implement repository interface in `domain/` and implementation in `data/`
4. Create a Cubit in `application/` following the standard state pattern
5. Build presentation screens in `presentation/screens/`
6. Add routes to `AppRouter` in `lib/app/router/app_router.dart`

### Adding API Integration

1. Inject `ApiClient` or `WebSocketRealtimeClient` into the repository
2. Make HTTP calls via `apiClient.dio.get()`, `post()`, etc.
3. Handle responses and wrap errors in `AppError`
4. Use the `Result<T>` type for success/failure outcomes

### Error Handling

- Always catch errors in Cubit methods and emit a failure state
- Use friendly error messages for user display (see `AuthCubit._friendlyAuthError()`)
- Log errors via `AppLogger` for debugging

### Testing

- Mock repositories and data sources
- Test Cubit state transitions with `BlocTest`
- Use `JobAcceptancePolicyTest` as a reference for domain logic testing

## File Modification Guidelines

When modifying files that require code generation (models with `@freezed`, `@JsonSerializable`), always run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

After major changes to dependencies or pubspec.yaml:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Debugging

- Use `flutter run -v` for verbose logging
- Access logs via `AppLogger` (logged to developer console)
- Check `main.dart` for error boundary setup with `runZonedGuarded`
- Real-time events logged in `WebSocketRealtimeClient._handleMessage()`

## Git Workflow

- Clean up build artifacts before committing: `flutter clean`
- Don't commit build/, .dart_tool/, or pubspec.lock unless necessary
- Run `flutter analyze` and tests before committing
