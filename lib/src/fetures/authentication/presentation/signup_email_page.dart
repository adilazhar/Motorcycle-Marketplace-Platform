import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

class SignupEmailPage extends StatelessWidget {
  const SignupEmailPage(
      {super.key,
      required this.emailKey,
      required this.emailController,
      required this.moveToPassPage});

  final GlobalKey<FormBuilderState> emailKey;
  final TextEditingController emailController;
  final void Function() moveToPassPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const Text(
              'Create Account with Email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            FormBuilder(
              key: emailKey,
              child: FormBuilderTextField(
                name: 'email',
                controller: emailController,
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
                onPressed: moveToPassPage,
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
    );
  }
}
