import 'package:bike_listing/src/fetures/authentication/data/auth_user_repository.dart';
import 'package:bike_listing/src/fetures/wishlist/data/firestore_wishlist_repository.dart';
import 'package:bike_listing/src/fetures/wishlist/data/wishlist_repository.dart';
import 'package:bike_listing/src/fetures/wishlist/domain/wishlist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wishlist_service.g.dart';

class WishlistService {
  final Ref _ref;

  WishlistService(this._ref);

  AuthUserRepository get _authRepository =>
      _ref.read(authUserRepositoryProvider);
  WishlistRepository get _wishlistRepository =>
      _ref.read(wishlistRepositoryProvider);

  String? get uid => _authRepository.currentUser?.uid;

  Future<void> addToWishlist(String listingId) async {
    final userId = uid;
    if (userId == null) {
      throw Exception('No authenticated user found');
    }
    return _wishlistRepository.addToWishlist(userId, listingId);
  }

  Future<void> clearWishlist() async {
    final userId = uid;
    if (userId == null) {
      throw Exception('No authenticated user found');
    }
    return _wishlistRepository.clearWishlist(userId);
  }

  Future<void> removeFromWishlist(String listingId) async {
    final userId = uid;
    if (userId == null) {
      throw Exception('No authenticated user found');
    }
    return _wishlistRepository.removeFromWishlist(userId, listingId);
  }

  Stream<Wishlist> watchWishlist() {
    final userId = uid;
    if (userId == null) {
      throw Exception('No authenticated user found');
    }
    return _wishlistRepository.watchWishlistforUserid(userId);
  }

  Future<Wishlist> getWishlist() async {
    final userId = uid;
    if (userId == null) {
      throw Exception('No authenticated user found');
    }
    return _wishlistRepository.getWishlistforUserid(userId);
  }
}

@Riverpod(keepAlive: true)
WishlistService wishlistService(Ref ref) {
  return WishlistService(ref);
}

@Riverpod(keepAlive: true)
Stream<Wishlist> watchWishlist(Ref ref) {
  final wishlistService = ref.read(wishlistServiceProvider);
  return wishlistService.watchWishlist();
}
