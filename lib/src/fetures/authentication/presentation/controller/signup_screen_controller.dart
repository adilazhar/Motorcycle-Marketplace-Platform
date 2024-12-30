import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:bike_listing/src/fetures/authentication/application/app_user_service.dart';
import 'package:bike_listing/src/fetures/authentication/data/auth_user_repository.dart';

part 'signup_screen_controller.g.dart';

@riverpod
class SignupScreenController extends _$SignupScreenController {
  Timer? _verificationTimer;

  @override
  SignupState build() {
    ref.onDispose(
      () => state.dispose(),
    );
    return SignupState();
  }

  void startEmailVerificationCheck() {
    ref.read(appUserServiceProvider).sendEmailVerification();
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) async {
        await ref.read(appUserServiceProvider).reloadUser();
        final user = ref.read(authUserRepositoryProvider).currentUser!;

        if (user.isEmailVerified) {
          state = state.copyWith(isEmailVerified: true);
          timer.cancel();
        }
      },
    );
  }

  Future<void> signUp() async {
    if (state.passKey.currentState!.saveAndValidate()) {
      try {
        state = state.copyWith(isLoading: true, errorMessage: '');

        await ref.read(appUserServiceProvider).createUserWithEmailAndPassword(
              state.emailController.text,
              state.passKey.currentState?.value['pass'],
            );

        state = state.copyWith(
          isLoading: false,
          email: state.emailController.text,
        );

        moveToNextPage();
        startEmailVerificationCheck();
      } on FirebaseAuthException catch (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.message ?? 'An error occurred',
        );
      }
    }
  }

  void moveToNextPage() {
    if (state.currentPage == 0 &&
        !state.emailKey.currentState!.saveAndValidate()) {
      return;
    }

    state.pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    state = state.copyWith(currentPage: state.currentPage + 1);
  }

  void moveToPreviousPage() {
    state.pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    state = state.copyWith(
      currentPage: state.currentPage - 1,
      errorMessage: '',
    );
  }
}

class SignupState extends Equatable {
  final bool isLoading;
  final bool isEmailVerified;
  final String email;
  final String errorMessage;
  final int currentPage;
  final PageController pageController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormBuilderState> emailKey;
  final GlobalKey<FormBuilderState> passKey;

  SignupState({
    PageController? pageController,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    GlobalKey<FormBuilderState>? emailKey,
    GlobalKey<FormBuilderState>? passKey,
    this.isLoading = false,
    this.isEmailVerified = false,
    this.email = '',
    this.errorMessage = '',
    this.currentPage = 0,
  })  : pageController = pageController ?? PageController(),
        emailController = emailController ?? TextEditingController(),
        passwordController = passwordController ?? TextEditingController(),
        confirmPasswordController =
            confirmPasswordController ?? TextEditingController(),
        emailKey = emailKey ?? GlobalKey<FormBuilderState>(),
        passKey = passKey ?? GlobalKey<FormBuilderState>();

  SignupState copyWith({
    bool? isLoading,
    bool? isEmailVerified,
    String? email,
    String? errorMessage,
    int? currentPage,
    PageController? pageController,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    GlobalKey<FormBuilderState>? emailKey,
    GlobalKey<FormBuilderState>? passKey,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      pageController: pageController ?? this.pageController,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      confirmPasswordController:
          confirmPasswordController ?? this.confirmPasswordController,
      emailKey: emailKey ?? this.emailKey,
      passKey: passKey ?? this.passKey,
    );
  }

  void dispose() {
    pageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  String toString() {
    return 'SignupState(isLoading: $isLoading, isEmailVerified: $isEmailVerified, email: $email, errorMessage: $errorMessage, currentPage: $currentPage, pageController: $pageController, emailController: $emailController, passwordController: $passwordController, confirmPasswordController: $confirmPasswordController, emailKey: $emailKey, passKey: $passKey)';
  }

  @override
  List<Object> get props {
    return [
      isLoading,
      isEmailVerified,
      email,
      errorMessage,
      currentPage,
      pageController,
      emailController,
      passwordController,
      confirmPasswordController,
      emailKey,
      passKey,
    ];
  }
}
