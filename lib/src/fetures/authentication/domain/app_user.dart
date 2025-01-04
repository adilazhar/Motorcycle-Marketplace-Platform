import 'package:bike_listing/src/fetures/authentication/domain/auth_user.dart';
import 'package:bike_listing/src/fetures/authentication/domain/user_meta.dart';

/// Encapsulates [AuthUser] and [UserMeta] to provide a unified interface for user data.
class AppUser {
  AppUser(
    this._authUser,
    this._userMeta,
  );

  final AuthUser _authUser;
  final UserMeta _userMeta;

  /// Returns the user's UID.
  String get uid => _authUser.uid;

  /// Returns the user's email.
  String? get email => _authUser.email;

  /// Returns whether the user's email is verified.
  bool get isEmailVerified => _authUser.isEmailVerified;

  /// Returns the user's display name.
  String? get userName => _userMeta.userName;

  /// Returns the user's bio.
  String? get bio => _userMeta.bio;

  /// Returns the user's join date.
  DateTime? get joinDate => _userMeta.joinDate;

  /// Sends an email verification link to the user.
  Future<void> sendEmailVerification() => _authUser.sendEmailVerification();

  /// Checks if the user has admin privileges.
  Future<bool> isAdmin() => _authUser.isAdmin();

  /// Creates a copy of the [AppUser] object with updated attributes.
  AppUser copyWith({
    AuthUser? authUser,
    UserMeta? userMeta,
  }) {
    return AppUser(
      authUser ?? _authUser,
      userMeta ?? _userMeta,
    );
  }

  /// Overrides the equality operator to compare two [AppUser] objects.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        _authUser == other._authUser &&
        _userMeta == other._userMeta;
  }

  /// Overrides the [hashCode] method for consistency with [==].
  @override
  int get hashCode => _authUser.hashCode ^ _userMeta.hashCode;

  /// Overrides the [toString] method for a readable representation of the object.
  @override
  String toString() {
    return 'AppUser(authUser: $_authUser, userMeta: $_userMeta)';
  }
}
