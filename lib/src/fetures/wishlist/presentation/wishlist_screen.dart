import 'package:bike_listing/src/fetures/listing/application/listing_service.dart';
import 'package:bike_listing/src/fetures/listing/presetation/widgets/bike_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishListedListings = ref.watch(watchUserWishlistedListingsProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Wishlist',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(8),
          child: wishListedListings.when(
            data: (data) {
              if (data.isEmpty) {
                return Center(
                  child: Text('Try Adding Something To Wishlist'),
                );
              }
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final listing = data[index];
                  return BikeListCard(
                    listing: listing,
                    onTap: () {
                      context.push('/bike_detail', extra: listing);
                    },
                  );
                },
              );
            },
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
            loading: () => Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ));
  }
}
