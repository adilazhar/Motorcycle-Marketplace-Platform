import 'package:bike_listing/src/fetures/wishlist/domain/wishlist.dart';

abstract class WishlistRepository {
  Future<Wishlist> getWishlistforUserid(String uid);
  Stream<Wishlist> watchWishlistforUserid(String uid);
  Future<void> addToWishlist(String uid, String listingId);
  Future<void> removeFromWishlist(String uid, String listingId);
  Future<void> clearWishlist(String uid);
}
