import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SignupVerificationPage extends StatelessWidget {
  const SignupVerificationPage({
    super.key,
    required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              email,
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
    );
  }
}
