import 'package:apexguide/app/route_error_screen.dart';
import 'package:apexguide/app/routes.dart';
import 'package:apexguide/features/activation/presentation/activation_screen.dart';
import 'package:apexguide/features/license/presentation/locked_screen.dart';
import 'package:apexguide/features/settings/presentation/settings_screen.dart';
import 'package:apexguide/features/start/presentation/start_screen.dart';
import 'package:apexguide/features/sync/presentation/first_sync_screen.dart';
import 'package:apexguide/features/tracks/presentation/corner_screen.dart';
import 'package:apexguide/features/tracks/presentation/track_list_screen.dart';
import 'package:apexguide/features/tracks/presentation/track_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

/// The app's router, built once for the app's lifetime.
///
/// LIC-003 adds license gating here. Do not `ref.watch` license state in this
/// provider: that rebuilds the GoRouter and resets navigation. Instead:
/// - `ref.listen` to license state and bump a `ValueNotifier` passed as
///   `refreshListenable` (dispose it with `ref.onDispose`);
/// - read license state with `ref.read` inside `redirect`;
/// - deny by default: only start, activation and locked are open without a
///   valid license. `redirect` also runs for the initial location, which on
///   Android any app can choose through the `route` intent extra.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final router = GoRouter(
    initialLocation: Routes.start,
    errorBuilder: (context, state) =>
        RouteErrorScreen(location: state.uri.toString()),
    routes: [
      GoRoute(
        path: Routes.start,
        name: RouteNames.start,
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: Routes.activation,
        name: RouteNames.activation,
        builder: (context, state) => const ActivationScreen(),
      ),
      GoRoute(
        path: Routes.firstSync,
        name: RouteNames.firstSync,
        builder: (context, state) => const FirstSyncScreen(),
      ),
      GoRoute(
        path: Routes.trackList,
        name: RouteNames.trackList,
        builder: (context, state) => const TrackListScreen(),
        routes: [
          GoRoute(
            path: Routes.trackSegment,
            name: RouteNames.track,
            builder: (context, state) => TrackScreen(
              trackId: state.pathParameters[Routes.trackIdParam]!,
            ),
            routes: [
              GoRoute(
                path: Routes.cornerSegment,
                name: RouteNames.corner,
                builder: (context, state) {
                  final cornerNo = int.tryParse(
                    state.pathParameters[Routes.cornerNoParam]!,
                  );
                  if (cornerNo == null) {
                    return RouteErrorScreen(location: state.uri.toString());
                  }
                  return CornerScreen(
                    trackId: state.pathParameters[Routes.trackIdParam]!,
                    cornerNo: cornerNo,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.locked,
        name: RouteNames.locked,
        builder: (context, state) => const LockedScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}
