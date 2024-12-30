// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

class SignupPasswordPage extends StatefulWidget {
  const SignupPasswordPage({
    super.key,
    required this.goToPreviousPage,
    required this.passKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.signup,
    required this.isLoading,
  });

  final void Function() goToPreviousPage;
  final GlobalKey<FormBuilderState> passKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final void Function() signup;
  final bool isLoading;

  @override
  State<SignupPasswordPage> createState() => SignupPasswordPageState();
}

class SignupPasswordPageState extends State<SignupPasswordPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: widget.isLoading ? Colors.grey : Colors.black),
          onPressed: widget.isLoading ? null : widget.goToPreviousPage,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: widget.passKey,
          enabled: !widget.isLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: kToolbarHeight + 20),
              const Text(
                'Create a Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FormBuilderTextField(
                name: 'pass',
                controller: widget.passwordController,
                obscureText: _obscurePassword,
                autovalidateMode: AutovalidateMode.onUnfocus,
                onChanged: (value) {
                  setState(() {});
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.password(),
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
                controller: widget.confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.equal(
                    widget.passwordController.text,
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
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.signup,
                  child: const Text('Agree and Create Account'),
                ),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: widget.isLoading
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
    );
  }
}
