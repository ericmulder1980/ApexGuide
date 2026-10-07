import 'package:flutter/material.dart';

/// Root widget. FND-001-T5 replaces the placeholder home with go_router.
class ApexGuideApp extends StatelessWidget {
  const ApexGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ApexGuide',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('ApexGuide')),
      ),
    );
  }
}
