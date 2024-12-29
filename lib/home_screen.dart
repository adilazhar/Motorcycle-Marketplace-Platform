import 'package:bike_listing/src/fetures/authentication/application/app_user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Adil'),
            ElevatedButton(
                onPressed: () {
                  ref.read(appUserServiceProvider).signOut();
                  context.go('/login');
                },
                child: Text('Logout')),
          ],
        ),
      ),
    );
  }
}
