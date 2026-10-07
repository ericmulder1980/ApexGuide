/// Route paths and names. Screens navigate through these, never through
/// string literals.
abstract final class Routes {
  /// Branded start screen.
  static const start = '/';

  /// License key activation.
  static const activation = '/activate';

  /// First content sync after activation.
  static const firstSync = '/sync';

  /// List of the tenant's tracks.
  static const trackList = '/tracks';

  /// Route pattern for one track, relative to [trackList]. Not a location:
  /// navigate with [trackLocation].
  static const trackSegment = ':$trackIdParam';

  /// Path segment that groups a track's corners.
  static const cornersSegment = 'corners';

  /// Route pattern for one corner, relative to [trackSegment]. Not a
  /// location: navigate with [cornerLocation].
  static const cornerSegment = '$cornersSegment/:$cornerNoParam';

  /// App settings.
  static const settings = '/settings';

  /// Shown when the license is expired or revoked.
  static const locked = '/locked';

  /// Path parameter for a track's id.
  static const trackIdParam = 'trackId';

  /// Path parameter for a corner's number within its track.
  static const cornerNoParam = 'cornerNo';

  /// Location of the track with [trackId].
  static String trackLocation(String trackId) => '$trackList/$trackId';

  /// Location of corner [cornerNo] of the track with [trackId].
  static String cornerLocation(String trackId, int cornerNo) =>
      '${trackLocation(trackId)}/$cornersSegment/$cornerNo';
}

/// Route names, for `context.goNamed`.
abstract final class RouteNames {
  /// Name of [Routes.start].
  static const start = 'start';

  /// Name of [Routes.activation].
  static const activation = 'activation';

  /// Name of [Routes.firstSync].
  static const firstSync = 'firstSync';

  /// Name of [Routes.trackList].
  static const trackList = 'trackList';

  /// Name of [Routes.trackSegment].
  static const track = 'track';

  /// Name of [Routes.cornerSegment].
  static const corner = 'corner';

  /// Name of [Routes.settings].
  static const settings = 'settings';

  /// Name of [Routes.locked].
  static const locked = 'locked';
}
