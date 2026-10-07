import 'package:apexguide/core/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// First content sync after activation. Placeholder until SYN-003.
class FirstSyncScreen extends StatelessWidget {
  /// Creates the first sync screen.
  const FirstSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'First sync');
  }
}
