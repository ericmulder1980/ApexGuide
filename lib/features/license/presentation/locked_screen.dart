import 'package:apexguide/core/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Shown when the license is expired or revoked. Placeholder until LIC-004.
class LockedScreen extends StatelessWidget {
  /// Creates the locked screen.
  const LockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Locked');
  }
}
