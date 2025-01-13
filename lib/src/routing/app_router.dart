import 'package:bike_listing/scaffold_with_nav_bar.dart';
import 'package:bike_listing/src/fetures/authentication/data/auth_user_repository.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/account_screen.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/controller/forgot_password_screen.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/login_screen.dart';
import 'package:bike_listing/home_screen.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/name_entry_screen.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/password_reset_email_sent_screen.dart';
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
  // ref.read(watchAppUserProvider);
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/login',
    redirect: (context, state) {
      // final currentRoute = state.uri.path;
      final isGoingToLogin = state.uri.path == '/login';
      final isGoingToSignup = state.uri.path == '/signup';
      // final isGoingToHome = state.uri.path == '/';
      final isLoggedIn = auth.currentUser != null;
      final isEmailVerified =
          ref.read(authUserRepositoryProvider).currentUser?.isEmailVerified ??
              false;

      // if (isLoggedIn && !isEmailVerified) {
      //   return '/signup?goToVerificationPage=true';
      // }

      if (isLoggedIn &&
          isEmailVerified &&
          (isGoingToLogin || isGoingToSignup)) {
        return '/';
      }
      // if (isLoggedIn &&  (isGoingToSignup || isGoingToLogin)) {
      //   return '/';
      // }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(
                context: context, state: state, child: HomeScreen()),
          ),
          GoRoute(
              path: '/wishlist',
              pageBuilder: (context, state) => buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: Scaffold(body: Center(child: Text('Wishlist'))))),
          GoRoute(
            path: '/my_ads',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: Scaffold(body: Center(child: Text('My Ads')))),
          ),
          GoRoute(
            path: '/account',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: AccountScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
          path: '/sell',
          pageBuilder: (context, state) => MaterialPage(
                fullscreenDialog: true,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text('Sell'),
                  ),
                  body: Center(
                    child: Text('Sell'),
                  ),
                ),
              )),
      GoRoute(
        path: '/account',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
            context: context, state: state, child: AccountScreen()),
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
      GoRoute(
        path: '/name_entry',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
            context: context, state: state, child: NameEntryScreen()),
      ),
      GoRoute(
        path: '/forgot_password',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
            context: context, state: state, child: ForgotPasswordScreen()),
        routes: [
          GoRoute(
            path: 'email_sent',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: PasswordResetEmailSentScreen()),
          ),
        ],
      ),
    ],
  );
}
