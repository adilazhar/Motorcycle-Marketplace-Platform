import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents user metadata stored in Firestore.
class UserMeta {
  final String userName;
  final String? bio;
  final DateTime? joinDate;
  final String email;

  UserMeta({
    required this.userName,
    this.bio,
    this.joinDate,
    required this.email,
  });

  /// factory method for creating usermeta from user input
  factory UserMeta.fromInput(String userName, String email) {
    return UserMeta(
      userName: userName,
      email: email,
    );
  }

  /// Converts the object to a `Map<String, dynamic>`.
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'bio': bio,
      'joinDate': FieldValue.serverTimestamp(),
      'email': email,
    };
  }

  /// Creates an instance from a `Map<String, dynamic>`.
  factory UserMeta.fromMap(Map<String, dynamic> map) {
    return UserMeta(
      userName: map['userName'] as String? ?? '', // Default to empty string
      bio: map['bio'] as String?,
      joinDate: map['joinDate'] != null
          ? (map['joinDate'] as Timestamp).toDate()
          : null,
      email: map['email'] as String? ?? '', // Default to empty string
    );
  }

  /// Converts the object to a JSON string.
  String toJson() => jsonEncode(toMap());

  /// Creates an instance from a JSON string.
  factory UserMeta.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return UserMeta.fromMap(map);
  }

  /// Converts the object to a Firestore-compatible `Map<String, dynamic>`.
  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  /// Creates an instance from a Firestore document snapshot.
  factory UserMeta.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return UserMeta.fromMap(data);
  }

  /// Creates a copy of the object with updated attributes.
  UserMeta copyWith({
    String? userName,
    String? bio,
    DateTime? joinDate,
    String? email,
  }) {
    return UserMeta(
      userName: userName ?? this.userName,
      bio: bio ?? this.bio,
      joinDate: joinDate ?? this.joinDate,
      email: email ?? this.email,
    );
  }

  /// Overrides the equality operator to compare two [UserMeta] objects.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserMeta &&
        userName == other.userName &&
        bio == other.bio &&
        joinDate == other.joinDate &&
        email == other.email;
  }

  /// Overrides the [hashCode] method for consistency with [==].
  @override
  int get hashCode =>
      userName.hashCode ^ bio.hashCode ^ joinDate.hashCode ^ email.hashCode;

  /// Overrides the [toString] method for a readable representation of the object.
  @override
  String toString() {
    return 'UserMeta(userName: $userName, bio: $bio, joinDate: $joinDate, email: $email)';
  }
}
