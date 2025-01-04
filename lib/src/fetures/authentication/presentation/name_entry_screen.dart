import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import 'package:bike_listing/src/fetures/authentication/presentation/controller/name_entry_screen_controller.dart';
import 'package:bike_listing/src/utils/async_value_ui.dart';

class NameEntryScreen extends ConsumerStatefulWidget {
  const NameEntryScreen({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NameEntryScreenState();
}

class _NameEntryScreenState extends ConsumerState<NameEntryScreen> {
  final GlobalKey<FormBuilderState> _nameKey = GlobalKey<FormBuilderState>();

  void updateName() {
    if (_nameKey.currentState!.saveAndValidate()) {
      String name = _nameKey.currentState!.value['name'];
      ref.read(nameEntryScreenControllerProvider.notifier).updateName(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      nameEntryScreenControllerProvider,
      (_, state) {
        state.showAlertDialogOnError(context);
      },
    );
    final state = ref.watch(nameEntryScreenControllerProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: state.isLoading ? null : () => context.go('/'),
            child: Text(
              'Skip',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Almost there...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Your name is set to: ${widget.userName}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Add your real name to build credibility and connect better with other people on BX',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            FormBuilder(
              key: _nameKey,
              enabled: !state.isLoading,
              child: FormBuilderTextField(
                name: 'name',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(5),
                ]),
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : updateName,
                child: Text('Finish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
