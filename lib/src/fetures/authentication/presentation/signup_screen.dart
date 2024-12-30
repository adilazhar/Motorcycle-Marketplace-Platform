import 'package:bike_listing/src/fetures/authentication/presentation/controller/signup_screen_controller.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/signup_email_page.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/signup_password_page.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/signup_verification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signupScreenControllerProvider);
    final controller = ref.read(signupScreenControllerProvider.notifier);

    ref.listen(signupScreenControllerProvider, (previous, current) {
      if (current.errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(current.errorMessage)),
        );
      }

      if (current.isEmailVerified) {
        context.go('/');
      }
    });

    return Scaffold(
      body: PageView(
        controller: state.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SignupEmailPage(
            emailKey: state.emailKey,
            emailController: state.emailController,
            moveToPassPage: controller.moveToNextPage,
          ),
          SignupPasswordPage(
            goToPreviousPage: controller.moveToPreviousPage,
            passKey: state.passKey,
            passwordController: state.passwordController,
            confirmPasswordController: state.confirmPasswordController,
            signup: controller.signUp,
            isLoading: state.isLoading,
          ),
          SignupVerificationPage(
            email: state.emailController.text,
          ),
        ],
      ),
    );
  }
}
