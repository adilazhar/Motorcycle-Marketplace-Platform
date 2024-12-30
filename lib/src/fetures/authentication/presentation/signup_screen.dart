import 'package:bike_listing/src/fetures/authentication/presentation/controller/signup_screen_controller.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/signup_email_page.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/signup_password_page.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/signup_verification_page.dart';
import 'package:bike_listing/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(signupScreenControllerProvider,
        (_, state) => state.showAlertDialogOnError(context));
    final state = ref.watch(signupScreenControllerProvider);
    final controller = ref.read(signupScreenControllerProvider.notifier);

    return Scaffold(
      body: PageView(
        controller: state.value!.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SignupEmailPage(
            emailKey: state.value!.emailKey,
            emailController: state.value!.emailController,
            moveToPassPage: controller.moveToNextPage,
          ),
          SignupPasswordPage(
            goToPreviousPage: controller.moveToPreviousPage,
            passKey: state.value!.passKey,
            passwordController: state.value!.passwordController,
            confirmPasswordController: state.value!.confirmPasswordController,
            signup: controller.signUp,
            isLoading: state.isLoading,
          ),
          SignupVerificationPage(
            email: state.value!.emailController.text,
          ),
        ],
      ),
    );
  }
}
