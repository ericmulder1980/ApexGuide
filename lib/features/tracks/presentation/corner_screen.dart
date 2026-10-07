import 'package:apexguide/core/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Guidance for one corner. Placeholder until CNT-005.
class CornerScreen extends StatelessWidget {
  /// Creates the corner screen for corner [cornerNo] of [trackId].
  const CornerScreen({
    required this.trackId,
    required this.cornerNo,
    super.key,
  });

  /// Id of the track the corner belongs to.
  final String trackId;

  /// Number of the corner within its track.
  final int cornerNo;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Corner',
      detail: 'Track $trackId, corner $cornerNo',
    );
  }
}
