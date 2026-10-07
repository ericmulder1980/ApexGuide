import 'package:apexguide/core/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Branded start screen. Placeholder until THM-002.
class StartScreen extends StatelessWidget {
  /// Creates the start screen.
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'ApexGuide');
  }
}
