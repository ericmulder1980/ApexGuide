import 'package:apexguide/app/app.dart';
import 'package:apexguide/app/route_error_screen.dart';
import 'package:apexguide/app/router.dart';
import 'package:apexguide/app/routes.dart';
import 'package:apexguide/features/activation/presentation/activation_screen.dart';
import 'package:apexguide/features/license/presentation/locked_screen.dart';
import 'package:apexguide/features/settings/presentation/settings_screen.dart';
import 'package:apexguide/features/start/presentation/start_screen.dart';
import 'package:apexguide/features/sync/presentation/first_sync_screen.dart';
import 'package:apexguide/features/tracks/presentation/corner_screen.dart';
import 'package:apexguide/features/tracks/presentation/track_list_screen.dart';
import 'package:apexguide/features/tracks/presentation/track_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps the app and navigates to [location].
Future<void> _pumpAt(WidgetTester tester, String location) async {
  final container = ProviderContainer.test();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const ApexGuideApp(),
    ),
  );
  container.read(routerProvider).go(location);
  await tester.pumpAndSettle();
}

void main() {
  group('every route renders its placeholder', () {
    final screens = <String, Type>{
      Routes.start: StartScreen,
      Routes.activation: ActivationScreen,
      Routes.firstSync: FirstSyncScreen,
      Routes.trackList: TrackListScreen,
      Routes.trackLocation('eefde'): TrackScreen,
      Routes.cornerLocation('eefde', 3): CornerScreen,
      Routes.settings: SettingsScreen,
      Routes.locked: LockedScreen,
    };

    for (final MapEntry(key: location, value: screen) in screens.entries) {
      testWidgets('$location shows $screen', (tester) async {
        await _pumpAt(tester, location);

        expect(find.byType(screen), findsOneWidget);
      });
    }
  });

  group('path parameters', () {
    testWidgets('track id reaches the track screen', (tester) async {
      await _pumpAt(tester, Routes.trackLocation('lelystad'));

      final screen = tester.widget<TrackScreen>(find.byType(TrackScreen));
      expect(screen.trackId, 'lelystad');
    });

    testWidgets('track id and corner number reach the corner screen', (
      tester,
    ) async {
      await _pumpAt(tester, Routes.cornerLocation('lelystad', 7));

      final screen = tester.widget<CornerScreen>(find.byType(CornerScreen));
      expect(screen.trackId, 'lelystad');
      expect(screen.cornerNo, 7);
    });
  });

  group('location helpers match the route table', () {
    test('trackLocation and cornerLocation equal the named locations', () {
      final router = ProviderContainer.test().read(routerProvider);

      expect(
        router.namedLocation(
          RouteNames.track,
          pathParameters: {Routes.trackIdParam: 'eefde'},
        ),
        Routes.trackLocation('eefde'),
      );
      expect(
        router.namedLocation(
          RouteNames.corner,
          pathParameters: {
            Routes.trackIdParam: 'eefde',
            Routes.cornerNoParam: '3',
          },
        ),
        Routes.cornerLocation('eefde', 3),
      );
    });
  });

  group('errors', () {
    testWidgets('unknown path shows the error screen', (tester) async {
      await _pumpAt(tester, '/does-not-exist');

      expect(find.byType(RouteErrorScreen), findsOneWidget);
    });

    testWidgets('non-numeric corner number shows the error screen', (
      tester,
    ) async {
      await _pumpAt(tester, '/tracks/eefde/corners/abc');

      expect(find.byType(RouteErrorScreen), findsOneWidget);
      expect(find.byType(CornerScreen), findsNothing);
    });
  });
}
