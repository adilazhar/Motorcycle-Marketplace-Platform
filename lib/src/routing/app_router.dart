import 'package:bike_listing/src/fetures/authentication/presentation/login_screen.dart';
import 'package:bike_listing/home_screen.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/signup_screen.dart';
import 'package:bike_listing/src/providers/firebase_auth.dart';
import 'package:bike_listing/src/routing/go_router_refresh_stream.dart';
import 'package:bike_listing/src/routing/not_found_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  CustomTransitionPage buildPageWithDefaultTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Define slide animation
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  final auth = ref.watch(firebaseAuthProvider);
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/login',
    redirect: (context, state) {
      // TODO: Add Redirect Logic As Needed
      final isLoggedIn = auth.currentUser != null;
      if (isLoggedIn) {
        if (state.uri.path == '/login') {
          return '/';
        }
      }
      // else {
      //   if (state.uri.path != '/login') {
      //     return '/login';
      //   }
      // }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
            context: context, state: state, child: HomeScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
            context: context, state: state, child: LoginScreen()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
            context: context, state: state, child: SignupScreen()),
      ),
    ],
  );
}
