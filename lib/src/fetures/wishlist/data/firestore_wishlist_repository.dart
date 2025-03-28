import 'package:bike_listing/src/fetures/wishlist/data/wishlist_repository.dart';
import 'package:bike_listing/src/fetures/wishlist/domain/wishlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreWishlistRepository implements WishlistRepository {
  final FirebaseFirestore _firestore;

  FirestoreWishlistRepository(this._firestore);

  @override
  Future<void> addToWishlist(String uid, String listingId) async {
    try {
      final wishListRef = _firestore.collection('wishlist').doc(uid);

      await wishListRef.set({
        'listingIds': FieldValue.arrayUnion([listingId])
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add listing to wishlist $e');
    }
  }

  @override
  Future<void> clearWishlist(String uid) async {
    try {
      await _firestore.collection('wishlist').doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to clear wishlist: $e');
    }
  }

  @override
  Future<Wishlist> getWishlistforUserid(String uid) async {
    try {
      final docSnapshot =
          await _firestore.collection('wishlist').doc(uid).get();

      if (!docSnapshot.exists) {
        return Wishlist.empty();
      }

      return Wishlist.fromMap(docSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get wishlist: $e');
    }
  }

  @override
  Future<void> removeFromWishlist(String uid, String listingId) async {
    try {
      final wishListRef = _firestore.collection('wishlist').doc(uid);

      await wishListRef.update({
        'listingIds': FieldValue.arrayRemove([listingId])
      });
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  @override
  Stream<Wishlist> watchWishlistforUserid(String uid) {
    return _firestore
        .collection('wishlist')
        .doc(uid)
        .snapshots()
        .map((docSnapshot) {
      if (!docSnapshot.exists) {
        return Wishlist.empty();
      }
      return Wishlist.fromMap(docSnapshot.data() as Map<String, dynamic>);
    });
  }
}
