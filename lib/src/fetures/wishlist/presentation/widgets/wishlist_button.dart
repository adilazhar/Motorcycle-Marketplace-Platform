import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_listing/src/fetures/wishlist/application/wishlist_service.dart';

class WishlistButton extends ConsumerWidget {
  final String listingId;

  const WishlistButton({
    super.key,
    required this.listingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(watchWishlistProvider);

    return wishlistAsync.when(
      loading: () => IconButton(
        icon: const Icon(
          Icons.favorite_border,
          color: Colors.grey,
        ),
        onPressed: null, // Disabled while loading
      ),
      error: (error, _) => IconButton(
        icon: const Icon(
          Icons.error_outline,
          color: Colors.red,
        ),
        onPressed: null, // Disabled on error
      ),
      data: (wishlist) {
        final isFavorited = wishlist.listingIds.contains(listingId);
        return IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : Colors.grey,
          ),
          onPressed: () {
            if (isFavorited) {
              ref.read(wishlistServiceProvider).removeFromWishlist(listingId);
            } else {
              ref.read(wishlistServiceProvider).addToWishlist(listingId);
            }
          },
        );
      },
    );
  }
}
