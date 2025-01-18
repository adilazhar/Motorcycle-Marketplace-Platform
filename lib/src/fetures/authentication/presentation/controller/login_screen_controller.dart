import 'package:bike_listing/src/fetures/authentication/application/app_user_service.dart';
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

    // Todo: Need To Test If There is No Error Will The App Route To Home Scree
    // if (!state.hasError) {
    //   final goRouter = ref.read(appRouterProvider);
    //   goRouter.go('/');
    // }
  }
}
