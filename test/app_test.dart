import 'package:apexguide/app/app.dart';
import 'package:apexguide/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ApexGuideApp renders the placeholder home', (tester) async {
    await tester.pumpWidget(const ApexGuideApp());

    expect(find.text('ApexGuide'), findsOneWidget);
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
