import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  late final PageController _pageController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  // ignore: prefer_final_fields
  int _currentPage = 0;

  void _signUp() async {
    _nextPage();
    // if (_passwordController.text != _confirmPasswordController.text) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Passwords do not match')),
    //   );
    //   return;
    // }

    // try {
    //   await FirebaseAuth.instance.createUserWithEmailAndPassword(
    //     email: _emailController.text,
    //     password: _passwordController.text,
    //   );
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Account created successfully')),
    //   );
    //   // Navigate to the home screen or next step
    // } on FirebaseAuthException catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(e.message ?? 'An error occurred')),
    //   );
    // }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage--;
    });
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage++;
    });
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
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
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
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  _previousPage();
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
                    'Create a Password',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
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
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
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
                      onPressed: _signUp,
                      child: const Text('Agree and Create Account'),
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
