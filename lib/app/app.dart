import 'package:apexguide/app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget.
class ApexGuideApp extends ConsumerWidget {
  /// Creates the root widget.
  const ApexGuideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ApexGuide',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
