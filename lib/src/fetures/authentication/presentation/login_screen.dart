import 'package:bike_listing/src/fetures/authentication/application/app_user_service.dart';
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
  bool _isLoading = false;

  final _formKey = GlobalKey<FormBuilderState>();

  bool _obscurePassword = true;

  void _login() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      try {
        setState(() {
          _isLoading = true;
        });
        final values = _formKey.currentState!.value;
        await ref.read(appUserServiceProvider).signInWithEmailAndPassword(
              values['email'],
              values['pass'],
            );
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.close, color: _isLoading ? Colors.grey : Colors.black),
          onPressed: _isLoading
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
          enabled: !_isLoading,
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
                onPressed: _isLoading ? null : () {},
                child: const Text('Forgot your password?'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: const Text('Log In'),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoading
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
