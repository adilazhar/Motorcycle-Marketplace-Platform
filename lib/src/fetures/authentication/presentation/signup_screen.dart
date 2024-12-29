// ignore_for_file: use_build_context_synchronously, unused_field, prefer_final_fields

import 'dart:async';

import 'package:bike_listing/src/fetures/authentication/application/app_user_service.dart';
import 'package:bike_listing/src/fetures/authentication/data/auth_user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

// TODO : Set it To Open The Verification Page directly
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailKey = GlobalKey<FormBuilderState>();
  final _passKey = GlobalKey<FormBuilderState>();

  bool _isLoading = false;

  bool _isUserEmailVerified = false;
  late Timer _timer;

  late final PageController _pageController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void isUserEmailVerified() {
    Future(() async {
      _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
        await ref.read(appUserServiceProvider).reloadUser();
        final user = ref.read(authUserRepositoryProvider).currentUser!;
        if (user.isEmailVerified) {
          setState(() {
            _isUserEmailVerified = true;
          });
          timer.cancel();
        }
      });
    });
  }

  void _signUp() async {
    if (_passKey.currentState!.saveAndValidate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        await ref.read(appUserServiceProvider).createUserWithEmailAndPassword(
            _emailController.text, _passKey.currentState?.value['pass']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
        _animateToNextPage();
        setState(() {
          _isLoading = false;
        });
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred')),
        );
      }
    }
  }

  void previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _animateToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _moveToPassPage() {
    if (_emailKey.currentState!.saveAndValidate()) {
      _animateToNextPage();
    }
  }

  @override
  void initState() {
    _pageController = PageController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Page 1: Email
          Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  context.go('/');
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: kToolbarHeight + 20),
                  const Text(
                    'Create Account with Email',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  FormBuilder(
                    key: _emailKey,
                    child: FormBuilderTextField(
                      name: 'email',
                      controller: _emailController,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                      decoration: InputDecoration(
                        labelText: 'Enter Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _moveToPassPage,
                      child: const Text('Next'),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text('Already have an account? Log in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Page 2: Password
          Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: _isLoading ? Colors.grey : Colors.black),
                onPressed: _isLoading
                    ? null
                    : () {
                        previousPage();
                      },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FormBuilder(
                key: _passKey,
                enabled: !_isLoading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: kToolbarHeight + 20),
                    const Text(
                      'Create a Password',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    FormBuilderTextField(
                      name: 'pass',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autovalidateMode: AutovalidateMode.onUnfocus,
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.hasLowercaseChars(),
                        FormBuilderValidators.hasNumericChars(),
                        FormBuilderValidators.hasSpecialChars(),
                        FormBuilderValidators.hasUppercaseChars(),
                        FormBuilderValidators.minLength(8),
                      ]),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FormBuilderTextField(
                      name: 'confirm_pass',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.equal(
                          _passwordController.text,
                          errorText: 'Passwords do not match',
                        ),
                      ]),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        child: const Text('Agree and Create Account'),
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                context.go('/login');
                              },
                        child: const Text('Already have an account? Log in'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Page 3: Confirmation
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verify Email',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Gap(20),
                  Text(
                    'Click on the link we sent to',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    _emailController.text,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator()),
                  SizedBox(height: 16),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'If you can\'t see the email in your inbox, check your spam folder. If it\'s not there, the email address may not be confirmed or it may not match an existing BX account.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
