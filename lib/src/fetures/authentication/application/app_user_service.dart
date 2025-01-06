import 'package:bike_listing/src/fetures/authentication/data/auth_user_repository.dart';
import 'package:bike_listing/src/fetures/authentication/data/user_meta_repository.dart';
import 'package:bike_listing/src/fetures/authentication/domain/app_user.dart';
import 'package:bike_listing/src/fetures/authentication/domain/user_meta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

part 'app_user_service.g.dart';

/// Service class for managing user data by interacting with repositories.
class AppUserService {
  AppUserService(this.ref);
  final Ref ref;

  /// Returns a stream of [AppUser] by combining data from [AuthUserRepository] and [UserMetaRepository].
  Stream<AppUser?> watchAppUser() {
    final authUserStream =
        ref.read(authUserRepositoryProvider).authStateChanges();

    return authUserStream.switchMap((authUser) {
      if (authUser == null) return Stream.value(null);

      return ref
          .watch(userMetaRepositoryProvider)
          .watchUserMeta(authUser.uid)
          .where((userMeta) => userMeta != null)
          .map((userMeta) => AppUser(authUser, userMeta!));
    });
  }

  /// Fetches the [AppUser] once by combining data from [AuthUserRepository] and [UserMetaRepository].
  Future<AppUser?> fetchAppUser() async {
    final authUser = ref.read(authUserRepositoryProvider).currentUser;
    if (authUser == null) return null;
    final userMeta =
        await ref.read(userMetaRepositoryProvider).fetchUserMeta(authUser.uid);
    return AppUser(authUser, userMeta!);
  }

  /// Updates the user’s metadata using [UserMetaRepository].
  Future<void> updateUserMeta(UserMeta userMeta) async {
    final authUser = ref.read(authUserRepositoryProvider).currentUser;
    if (authUser == null) return;
    await ref
        .read(userMetaRepositoryProvider)
        .updateUserMeta(authUser.uid, userMeta);
  }

  /// Deletes the user’s account using [AuthUserRepository] and [UserMetaRepository].
  Future<void> deleteUser() async {
    final authUser = ref.read(authUserRepositoryProvider).currentUser;
    if (authUser == null) return;
    await ref.read(authUserRepositoryProvider).deleteUser();
    await ref.read(userMetaRepositoryProvider).deleteUserMeta(authUser.uid);
  }

  /// Signs in the user using [AuthUserRepository].
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await ref
        .read(authUserRepositoryProvider)
        .signInWithEmailAndPassword(email, password);
  }

  /// Creates a new user using [AuthUserRepository] and initializes their metadata using [UserMetaRepository].
  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    await ref
        .read(authUserRepositoryProvider)
        .createUserWithEmailAndPassword(email, password);

    final currentUser = ref.read(authUserRepositoryProvider).currentUser!;
    final name = 'User $dummyName';
    final userMeta = UserMeta.fromInput(name, currentUser.email!);
    await ref
        .read(userMetaRepositoryProvider)
        .createUserMeta(userMeta, currentUser.uid);
  }

  // Creates a random user name
  String get dummyName {
    final uuid = Uuid();
    return uuid.v4().substring(0, 4);
  }

  // Future<void> createUserMeta(String name) async {
  //   final currentUser = ref.read(authUserRepositoryProvider).currentUser!;
  //   final userMeta = UserMeta.fromInput(name, currentUser.email!);
  //   await ref
  //       .read(userMetaRepositoryProvider)
  //       .createUserMeta(userMeta, currentUser.uid);
  // }

  /// Signs out the user using [AuthUserRepository].
  Future<void> signOut() async {
    await ref.read(authUserRepositoryProvider).signOut();
  }

  /// Sends a password reset email using [AuthUserRepository].
  Future<void> sendResetPasswordEmail(String email) async {
    await ref.read(authUserRepositoryProvider).sendResetPasswordEmail(email);
  }

  /// Reloads the user’s data using [AuthUserRepository].
  Future<void> reloadUser() async {
    await ref.read(authUserRepositoryProvider).reloadUser();
  }

  /// Sends an email verification link using [AuthUserRepository].
  Future<void> sendEmailVerification() async {
    await ref
        .read(authUserRepositoryProvider)
        .currentUser
        ?.sendEmailVerification();
  }

  /// Checks if the user has admin privileges using [AuthUserRepository].
  Future<bool> isAdmin() async {
    return await ref.read(authUserRepositoryProvider).currentUser?.isAdmin() ??
        false;
  }
}

/// Provider for the [AppUserService] instance.
@Riverpod(keepAlive: true)
AppUserService appUserService(Ref ref) {
  return AppUserService(ref);
}

/// Provider for watching the [AppUser] throughout the app
@Riverpod(keepAlive: true)
Stream<AppUser?> watchAppUser(Ref ref) {
  final appUserService = ref.watch(appUserServiceProvider);
  return appUserService.watchAppUser();
}
