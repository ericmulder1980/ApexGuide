import 'package:apexguide/app/app.dart';
import 'package:apexguide/app/router.dart';
import 'package:apexguide/app/routes.dart';
import 'package:apexguide/features/start/presentation/start_screen.dart';
import 'package:apexguide/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ApexGuideApp boots to the start screen at /', (tester) async {
    final container = ProviderContainer.test();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ApexGuideApp(),
      ),
    );
    await tester.pumpAndSettle();

    final router = container.read(routerProvider);
    expect(router.routerDelegate.currentConfiguration.uri.path, Routes.start);
    expect(find.byType(StartScreen), findsOneWidget);
  });

  test('lockPortrait requests portrait-up only', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await lockPortrait();

    final call = calls.singleWhere(
      (c) => c.method == 'SystemChrome.setPreferredOrientations',
    );
    expect(call.arguments, ['DeviceOrientation.portraitUp']);
  });
}
