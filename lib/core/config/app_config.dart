import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config.g.dart';

/// Build-time configuration, passed with
/// `flutter run --dart-define-from-file=config/dev.json`.
///
/// The config files hold no secrets (DEC-011).
class AppConfig {
  /// Creates a configuration with explicit values.
  const AppConfig({required this.apiBaseUrl, required this.useMockApi});

  /// Reads the values defined at build time. Without a config file the app
  /// falls back to the mock API, so it never reaches production by accident.
  const AppConfig.fromEnvironment()
    : apiBaseUrl = const String.fromEnvironment('API_BASE_URL'),
      useMockApi = const bool.fromEnvironment(
        'USE_MOCK_API',
        defaultValue: true,
      );

  /// Base URL of the central application's API.
  final String apiBaseUrl;

  /// Whether the app talks to the mock API (DEC-003) instead of [apiBaseUrl].
  final bool useMockApi;
}

/// The build-time [AppConfig]. Tests override it with
/// `appConfigProvider.overrideWithValue(...)`.
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) => const AppConfig.fromEnvironment();
