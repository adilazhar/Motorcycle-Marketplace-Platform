import 'package:bike_listing/src/fetures/authentication/application/app_user_service.dart';
import 'package:bike_listing/src/routing/app_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forgot_password_screen_controller.g.dart';

@riverpod
class ForgotPasswordScreenController extends _$ForgotPasswordScreenController {
  @override
  FutureOr<void> build() {}

  void sendResetPassEmail(String email) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(appUserServiceProvider).sendResetPasswordEmail(email),
    );

    if (!state.hasError) {
      final goRouter = ref.read(appRouterProvider);
      goRouter.go('/forgot_password/email_sent');
    }
  }
}
