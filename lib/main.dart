import 'package:apexguide/app/app.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lockPortrait();
  runApp(const ProviderScope(child: ApexGuideApp()));
}

/// Locks the app to portrait. AndroidManifest.xml and Info.plist set the same
/// orientation so the launch screen is portrait too.
Future<void> lockPortrait() {
  return SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
}
