import 'package:bike_listing/src/fetures/authentication/application/app_user_service.dart';
import 'package:bike_listing/src/routing/app_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_screen_controller.g.dart';

@riverpod
class LoginScreenController extends _$LoginScreenController {
  @override
  FutureOr<void> build() {}

  void login(String email, String password) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(appUserServiceProvider)
          .signInWithEmailAndPassword(email, password),
    );

    if (!state.hasError) {
      final goRouter = ref.read(appRouterProvider);
      goRouter.go('/account');
    }
  }
}
