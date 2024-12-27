import 'package:bike_listing/src/fetures/authentication/presentation/login_screen.dart';
import 'package:bike_listing/home_screen.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/signup_screen.dart';
import 'package:bike_listing/src/providers/firebase_auth.dart';
import 'package:bike_listing/src/routing/go_router_refresh_stream.dart';
import 'package:bike_listing/src/routing/not_found_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
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
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
    ],
  );
}
