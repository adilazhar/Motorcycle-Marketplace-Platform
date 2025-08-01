import 'package:bike_listing/src/fetures/listing/application/listing_service.dart';
import 'package:bike_listing/src/fetures/listing/domain/listing.dart';
import 'package:bike_listing/src/fetures/listing/presetation/widgets/bike_list_card.dart';
import 'package:bike_listing/src/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyAdsScreen extends ConsumerWidget {
  const MyAdsScreen({
    super.key,
  });

  List<String> _replaceIpInImageUrls(List<String> imageUrls) {
    return imageUrls.map((url) {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.host.isEmpty) return url;
      final newUri = uri.replace(host: AppConstants.ipAddress);
      return newUri.toString();
    }).toList();
  }

  Listing _withUpdatedImageUrls(Listing listing) {
    final updatedUrls = _replaceIpInImageUrls(listing.imageUrls);
    return listing.copyWith(imageUrls: updatedUrls);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsFromUser = ref.watch(watchListingsFromCurrentUserProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Ads',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(8),
          child: listingsFromUser.when(
            data: (data) {
              if (data.isEmpty) {
                return Center(
                  child: Text('You havent Posted Any Ads'),
                );
              }
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  var listing = data[index];
                  listing = _withUpdatedImageUrls(listing);
                  return BikeListCard(
                    listing: listing,
                    onTap: () {
                      context.push(
                          '/bike_detail?toShowUserCard=false&toShowWishlistIcon=false',
                          extra: listing);
                    },
                    showEllipsis: true,
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
