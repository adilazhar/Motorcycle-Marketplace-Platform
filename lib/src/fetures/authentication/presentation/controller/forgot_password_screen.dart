import 'package:bike_listing/src/fetures/authentication/presentation/controller/forgot_password_screen_controller.dart';
import 'package:bike_listing/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormBuilderState> _emailKey = GlobalKey<FormBuilderState>();

  void sendResetPassEmail() async {
    if (_emailKey.currentState!.saveAndValidate()) {
      String email = _emailKey.currentState!.value['email'];
      ref
          .read(forgotPasswordScreenControllerProvider.notifier)
          .sendResetPassEmail(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      forgotPasswordScreenControllerProvider,
      (_, state) {
        state.showAlertDialogOnError(context);
      },
    );
    final state = ref.watch(forgotPasswordScreenControllerProvider);
    debugPrint(state.toString());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "We'll send a verification code to this email if it matches an existing account",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Email address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            FormBuilder(
              key: _emailKey,
              child: FormBuilderTextField(
                name: 'email',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
                decoration: const InputDecoration(
                  hintText: 'Enter email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sendResetPassEmail,
                child: const Text('Reset Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
