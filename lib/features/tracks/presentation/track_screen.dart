import 'package:apexguide/core/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// One track with its corners. Placeholder until CNT-002.
class TrackScreen extends StatelessWidget {
  /// Creates the track screen for [trackId].
  const TrackScreen({required this.trackId, super.key});

  /// Id of the track to show.
  final String trackId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(title: 'Track', detail: 'Track $trackId');
  }
}
