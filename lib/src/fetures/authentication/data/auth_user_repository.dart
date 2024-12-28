import 'package:bike_listing/src/fetures/authentication/domain/auth_user.dart';
import 'package:bike_listing/src/providers/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_user_repository.g.dart';

/// Repository for managing authentication operations using Firebase Auth.
class AuthUserRepository {
  AuthUserRepository(this._auth);
  final FirebaseAuth _auth;

  /// Signs in a user with email and password.
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Creates a new user with email and password.
  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns a stream of authentication state changes (e.g., sign-in, sign-out).
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(_convertUser);
  }

  /// Returns the current authenticated user.
  AuthUser? get currentUser => _convertUser(_auth.currentUser);

  /// Helper method to convert a [User] to an [AppUser]
  AuthUser? _convertUser(User? user) => user != null ? AuthUser(user) : null;

  /// Sends a password reset email to the user.
  Future<void> sendResetPasswordEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Deletes the current user’s account.
  Future<void> deleteUser() async {
    await _auth.currentUser?.delete();
  }

  /// Reloads the current user’s account.
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
}

/// Provider for the [AuthUserRepository] instance.
@Riverpod(keepAlive: true)
AuthUserRepository authUserRepository(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthUserRepository(auth);
}

/// Provider for the authentication state changes stream.
@Riverpod(keepAlive: true)
Stream<AuthUser?> authStateChanges(Ref ref) {
  final authRepository = ref.watch(authUserRepositoryProvider);
  return authRepository.authStateChanges();
}
