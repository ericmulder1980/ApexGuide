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

  /// One track, relative to [trackList].
  static const track = ':$trackIdParam';

  /// One corner, relative to [track].
  static const corner = 'corners/:$cornerNoParam';

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
      '${trackLocation(trackId)}/corners/$cornerNo';
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

  /// Name of [Routes.track].
  static const track = 'track';

  /// Name of [Routes.corner].
  static const corner = 'corner';

  /// Name of [Routes.settings].
  static const settings = 'settings';

  /// Name of [Routes.locked].
  static const locked = 'locked';
}
