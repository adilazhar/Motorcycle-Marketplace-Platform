import 'package:bike_listing/src/fetures/authentication/application/app_user_service.dart';
import 'package:bike_listing/src/fetures/authentication/domain/user_meta.dart';
import 'package:bike_listing/src/routing/app_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'name_entry_screen_controller.g.dart';

@riverpod
class NameEntryScreenController extends _$NameEntryScreenController {
  @override
  FutureOr<void> build() {}

  void updateName(String name) async {
    final userMeta = UserMeta(userName: name);

    state = AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(appUserServiceProvider).updateUserMeta(userMeta),
    );

    if (!state.hasError) {
      ref.read(appRouterProvider).go('/account');
    }
  }
}
