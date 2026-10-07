import 'package:flutter/material.dart';

/// Stand-in for a screen that a later feature builds.
class PlaceholderScreen extends StatelessWidget {
  /// Creates a placeholder showing [title] and an optional [detail] line.
  const PlaceholderScreen({required this.title, this.detail, super.key});

  /// Screen name.
  final String title;

  /// Extra information, such as path parameters.
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(detail ?? title)),
    );
  }
}
