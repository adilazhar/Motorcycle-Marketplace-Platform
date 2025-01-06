import 'package:bike_listing/src/fetures/authentication/application/app_user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileUpdateDialog extends ConsumerWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  ProfileUpdateDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Profile'),
      content: FormBuilder(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBuilderTextField(
              name: 'bio',
              initialValue: ref.read(watchAppUserProvider).requireValue!.bio,
              decoration: InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final bio = _formKey.currentState?.value['bio'] as String?;

              if (bio != null && bio.trim().isNotEmpty) {
                final trimmedBio = bio.trim();
                final currentUserMeta =
                    ref.read(watchAppUserProvider).requireValue!.userMeta;
                final updatedUserMeta =
                    currentUserMeta.copyWith(bio: trimmedBio);

                ref
                    .read(appUserServiceProvider)
                    .updateUserMeta(updatedUserMeta);
              }
            }
            Navigator.of(context).pop();
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}
