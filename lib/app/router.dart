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

/// The app's router. LIC-003 adds a `redirect` driven by license state here.
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
            path: Routes.track,
            name: RouteNames.track,
            builder: (context, state) => TrackScreen(
              trackId: state.pathParameters[Routes.trackIdParam]!,
            ),
            routes: [
              GoRoute(
                path: Routes.corner,
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
