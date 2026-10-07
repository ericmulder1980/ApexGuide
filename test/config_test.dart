import 'dart:convert';
import 'dart:io';

import 'package:apexguide/core/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _readConfig(String name) {
  final file = File('config/$name.json');
  return jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
}

void main() {
  group('AppConfig.fromEnvironment', () {
    // `flutter test` runs without --dart-define-from-file, so every key is
    // undefined here.
    test('falls back to the mock API when no config file is passed', () {
      const config = AppConfig.fromEnvironment();

      expect(config.apiBaseUrl, isEmpty);
      expect(config.useMockApi, isTrue);
    });
  });

  group('appConfigProvider', () {
    test('provides the build-time config', () {
      final container = ProviderContainer.test();

      final config = container.read(appConfigProvider);

      expect(config.useMockApi, isTrue);
    });

    test('can be overridden in tests', () {
      const override = AppConfig(
        apiBaseUrl: 'https://api.test',
        useMockApi: false,
      );
      final container = ProviderContainer.test(
        overrides: [appConfigProvider.overrideWithValue(override)],
      );

      expect(container.read(appConfigProvider), same(override));
    });
  });

  group('config files', () {
    for (final name in ['dev', 'prod']) {
      test('$name.json defines exactly the AppConfig keys', () {
        final values = _readConfig(name);

        expect(values.keys, unorderedEquals(['API_BASE_URL', 'USE_MOCK_API']));
        expect(values['API_BASE_URL'], isA<String>());
        expect(values['USE_MOCK_API'], isA<bool>());
      });
    }

    test('dev uses the mock API and prod does not', () {
      expect(_readConfig('dev')['USE_MOCK_API'], isTrue);
      expect(_readConfig('prod')['USE_MOCK_API'], isFalse);
    });
  });
}
