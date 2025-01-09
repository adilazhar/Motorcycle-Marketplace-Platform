import 'package:bike_listing/src/fetures/authentication/application/app_user_service.dart';
import 'package:bike_listing/src/fetures/authentication/presentation/profile_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(watchAppUserProvider);
    return user.when(
      data: (user) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Account'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {},
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                child: Text(
                  user?.userName.substring(0, 1).toUpperCase() ?? 'A',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Text(
                user?.userName ?? 'Name',
                style: TextStyle(fontSize: 18),
              ),
              TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ProfileUpdateDialog(),
                    );
                  },
                  child: Text(
                    'View Profile',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  )),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Account'),
                onTap: () async {
                  // Show a dialog to prompt for email and password
                  final emailController = TextEditingController();
                  final passwordController = TextEditingController();

                  await showDialog(
                    context: context,
                    builder: (context) {
                      return ReauthenticationDialog(
                          emailController: emailController,
                          passwordController: passwordController);
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () async {
                  await ref.read(appUserServiceProvider).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
      error: (Object error, StackTrace stackTrace) => Center(
        child: Text(error.toString()),
      ),
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ReauthenticationDialog extends ConsumerWidget {
  const ReauthenticationDialog({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Re-authenticate'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final email = emailController.text.trim();
            final password = passwordController.text.trim();

            if (email.isNotEmpty && password.isNotEmpty) {
              await ref
                  .read(appUserServiceProvider)
                  .deleteUser(email, password);
              if (context.mounted) {
                context.go('/login');
              }
            }
          },
          child: Text('Delete'),
        ),
      ],
    );
  }
}
