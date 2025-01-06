import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:bike_listing/src/fetures/authentication/application/app_user_service.dart';
import 'package:bike_listing/src/fetures/authentication/data/auth_user_repository.dart';
import 'package:bike_listing/src/routing/app_router.dart';

part 'signup_screen_controller.g.dart';

@riverpod
class SignupScreenController extends _$SignupScreenController {
  Timer? _verificationTimer;

  @override
  FutureOr<SignupState> build() {
    ref.onDispose(
      () {
        _verificationTimer?.cancel();
        state.whenData((state) => state.dispose());
      },
    );
    return SignupState();
  }

  void startEmailVerificationCheck() {
    final currentState = state.value!;
    ref.read(appUserServiceProvider).sendEmailVerification();
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        await ref.read(appUserServiceProvider).reloadUser();
        final user = ref.read(authUserRepositoryProvider).currentUser!;

        if (user.isEmailVerified) {
          state = AsyncData(currentState.copyWith(isEmailVerified: true));
          timer.cancel();

          ref.read(appRouterProvider).go('/name_entry');
        }
      },
    );
  }

  Future<void> signUp() async {
    final currentState = state.valueOrNull;
    if (currentState == null ||
        !currentState.passKey.currentState!.saveAndValidate()) {
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(appUserServiceProvider).createUserWithEmailAndPassword(
            currentState.emailController.text,
            currentState.passKey.currentState?.value['pass'],
          );

      final newState = currentState.copyWith(
        email: currentState.emailController.text,
      );

      // Initializing the watchAppUser Provider So that i don't have to see the loading screen in the name setup screen
      ref.read(watchAppUserProvider);

      moveToNextPage();
      startEmailVerificationCheck();

      return newState;
    });
  }

  void moveToNextPage() {
    if (state.value!.currentPage == 0 &&
        !state.value!.emailKey.currentState!.saveAndValidate()) {
      return;
    }

    state.value!.pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    state = AsyncData(
        state.value!.copyWith(currentPage: state.value!.currentPage + 1));
  }

  void moveToPreviousPage() {
    state.value!.pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    state = AsyncData(
        state.value!.copyWith(currentPage: state.value!.currentPage - 1));
  }
}

class SignupState extends Equatable {
  final bool isEmailVerified;
  final String email;
  final int currentPage;
  final PageController pageController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormBuilderState> emailKey;
  final GlobalKey<FormBuilderState> passKey;

  SignupState({
    this.isEmailVerified = false,
    this.email = '',
    this.currentPage = 0,
    PageController? pageController,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    GlobalKey<FormBuilderState>? emailKey,
    GlobalKey<FormBuilderState>? passKey,
  })  : pageController = pageController ?? PageController(),
        emailController = emailController ?? TextEditingController(),
        passwordController = passwordController ?? TextEditingController(),
        confirmPasswordController =
            confirmPasswordController ?? TextEditingController(),
        emailKey = emailKey ?? GlobalKey<FormBuilderState>(),
        passKey = passKey ?? GlobalKey<FormBuilderState>();

  SignupState copyWith({
    bool? isEmailVerified,
    String? email,
    int? currentPage,
  }) {
    return SignupState(
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      email: email ?? this.email,
      currentPage: currentPage ?? this.currentPage,
      pageController: pageController,
      emailController: emailController,
      passwordController: passwordController,
      confirmPasswordController: confirmPasswordController,
      emailKey: emailKey,
      passKey: passKey,
    );
  }

  void dispose() {
    pageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  List<Object> get props {
    return [
      isEmailVerified,
      email,
      currentPage,
      pageController,
      emailController,
      passwordController,
      confirmPasswordController,
      emailKey,
      passKey,
    ];
  }

  @override
  String toString() {
    return 'SignupState(isEmailVerified: $isEmailVerified, email: $email, currentPage: $currentPage)';
  }
}
