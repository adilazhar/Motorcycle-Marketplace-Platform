import 'package:bike_listing/src/fetures/authentication/presentation/controller/login_screen_controller.dart';
import 'package:bike_listing/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  bool _obscurePassword = true;

  void _login() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      ref.read(loginScreenControllerProvider.notifier).login(
            values['email'],
            values['pass'],
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      loginScreenControllerProvider,
      (_, state) {
        state.showAlertDialogOnError(context);
      },
    );
    final state = ref.watch(loginScreenControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: state.isLoading ? Colors.grey : Colors.black),
          onPressed: state.isLoading
              ? null
              : () {
                  context.go('/');
                },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          enabled: !state.isLoading,
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight + 20),
              Align(
                alignment: Alignment.center,
                child: const Text(
                  'BX',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Login to your BX account',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              FormBuilderTextField(
                name: 'email',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FormBuilderTextField(
                name: 'pass',
                obscureText: _obscurePassword,
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
                    )),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: state.isLoading
                    ? null
                    : () => context.go('/forgot_password'),
                child: const Text('Forgot your password?'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _login,
                  child: const Text('Log In'),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          context.go('/signup');
                        },
                  child: const Text('New to BX? Create an account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
