import 'package:firebase_auth/firebase_auth.dart';

/// Wrapper for the [User] class from Firebase Auth.
class AuthUser {
  const AuthUser(this._user);
  final User _user;

  /// Returns the user's UID.
  String get uid => _user.uid;

  /// Returns the user's email.
  String? get email => _user.email;

  /// Returns whether the user's email is verified.
  bool get isEmailVerified => _user.emailVerified;

  /// Sends an email verification link to the user.
  Future<void> sendEmailVerification() => _user.sendEmailVerification();

  /// Checks if the user has admin privileges by fetching custom claims.
  Future<bool> isAdmin() async {
    final idTokenResult = await _user.getIdTokenResult();
    final claims = idTokenResult.claims;
    if (claims != null) {
      return claims['admin'] == true;
    }
    return false;
  }

  /// Creates a copy of the [AuthUser] object with updated attributes.
  AuthUser copyWith({User? user}) => AuthUser(user ?? _user);

  /// Overrides the equality operator to compare two [AuthUser] objects.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          _user == other._user;

  /// Overrides the [hashCode] method for consistency with [==].
  @override
  int get hashCode => _user.hashCode;

  /// Overrides the [toString] method for a readable representation of the object.
  @override
  String toString() => 'AuthUser(user: $_user)';
}
