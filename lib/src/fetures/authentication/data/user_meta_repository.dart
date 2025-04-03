import 'package:bike_listing/src/fetures/authentication/domain/user_meta.dart';
import 'package:bike_listing/src/providers/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_meta_repository.g.dart';

/// Repository for managing UserMeta data in Firestore.
class UserMetaRepository {
  UserMetaRepository(this._firestore);
  final FirebaseFirestore _firestore;

  /// Returns a stream of [UserMeta] for the given user ID.
  Stream<UserMeta?> watchUserMeta(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) =>
        snapshot.exists ? UserMeta.fromFirestore(snapshot) : null);
  }

  /// Fetches the [UserMeta] for the given user ID once.
  Future<UserMeta?> fetchUserMeta(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot.exists ? UserMeta.fromFirestore(snapshot) : null;
  }

  /// Creates a new [UserMeta] document in Firestore.
  Future<void> createUserMeta(UserMeta userMeta, String uid) async {
    await _firestore.collection('users').doc(uid).set(userMeta.toFirestore());
  }

  /// Updates the [UserMeta] document for the given user ID.
  Future<void> updateUserMeta(String uid, UserMeta userMeta) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update(userMeta.toFirestore());
  }

  Future<void> addToUserListing(String uid, String listingId) async {
    await _firestore.collection('users').doc(uid).update({
      'userListings': FieldValue.arrayUnion([listingId])
    });
  }

  Future<void> removeFromUserListing(String uid, String listingId) async {
    await _firestore.collection('users').doc(uid).update({
      'userListings': FieldValue.arrayRemove([listingId])
    });
  }

  /// Deletes the [UserMeta] document for the given user ID.
  Future<void> deleteUserMeta(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}

/// Provider for the [UserMetaRepository] instance.
@Riverpod(keepAlive: true)
UserMetaRepository userMetaRepository(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return UserMetaRepository(firestore);
}

/// Provider for the user meta stream.
@Riverpod(keepAlive: true)
Stream<UserMeta?> watchUserMeta(Ref ref, String uid) {
  final userMetaRepo = ref.watch(userMetaRepositoryProvider);
  return userMetaRepo.watchUserMeta(uid);
}
