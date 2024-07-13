import 'package:commute_guide/constants/routes.dart';
import 'package:commute_guide/models/commute_trip.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/screens/login_screen.dart';
import 'package:commute_guide/screens/main_screen.dart';
import 'package:commute_guide/screens/navigation_screen.dart';
import 'package:commute_guide/screens/signup_screen.dart';
import 'package:commute_guide/screens/splash_screen.dart';
import 'package:commute_guide/screens/tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

GoRouter generateRouterDelegate(WidgetRef ref) {
  return GoRouter(
    // initialLocation: Routes.login,
    initialLocation: Routes.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = ref.read(globalProvider).isAuthenticated;
      if (!isAuthenticated) {
        if (state.fullPath == Routes.splash) return null;
        if (state.fullPath == Routes.signup) return Routes.signup;
        return Routes.login;
      }

      if (state.fullPath == Routes.signup || state.fullPath == Routes.login) {
        return Routes.home;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: Routes.login,
        name: Routes.login,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            MaterialPage<void>(
          key: state.pageKey,
          name: 'Login',
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: Routes.signup,
        name: Routes.signup,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            MaterialPage<void>(
          key: state.pageKey,
          name: 'Signup',
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: Routes.home,
        name: Routes.home,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            MaterialPage<void>(
          key: state.pageKey,
          name: 'Home',
          child: const MainScreen(),
        ),
        routes: [
          GoRoute(
              path: Routes.navigation,
              name: Routes.navigation,
              pageBuilder: (BuildContext context, GoRouterState state) {
                final data = state.extra as Map<String, Object?>;
                // final data = state.extra is AfterSignupRouteArgument
                //     ? state.extra as AfterSignupRouteArgument
                //     : null;
                // ref.read(afterSignupProvider).name = data?.name;
                return MaterialPage<void>(
                  key: state.pageKey,
                  name: 'Record',
                  child: NavigationScreen(
                    changeMainProvider: data['main_provider']
                        as ChangeNotifierProvider<MainProvider>,
                    trip: data['trip'] as CommuteTrip,
                  ),
                );
              }),
          GoRoute(
              path: Routes.track,
              name: Routes.track,
              pageBuilder: (BuildContext context, GoRouterState state) {
                final data = state.extra as Map<String, Object?>;
                return MaterialPage<void>(
                  key: state.pageKey,
                  name: 'Track',
                  child: TrackingScreen(
                    changeMainProvider: data['main_provider'] as MainProvider,
                    id: data['id'] as String,
                  ),
                );
              }),
        ],
      ),
      GoRoute(
        path: Routes.splash,
        name: Routes.splash,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            MaterialPage<void>(
          key: state.pageKey,
          name: 'Splash',
          child: const SplashScreen(),
        ),
      ),
    ],
  );
}
