import 'package:apexguide/core/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Shown for a location that matches no route or has invalid parameters.
class RouteErrorScreen extends StatelessWidget {
  /// Creates the error screen for [location].
  const RouteErrorScreen({required this.location, super.key});

  /// The location that could not be shown.
  final String location;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Page not found',
      detail: 'No page for $location',
    );
  }
}
