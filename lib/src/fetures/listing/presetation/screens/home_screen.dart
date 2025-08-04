import 'package:bike_listing/src/fetures/listing/data/firestore_listing_repository.dart';
import 'package:bike_listing/src/fetures/listing/domain/listing.dart';
import 'package:bike_listing/src/fetures/listing/presetation/widgets/bike_grid_card.dart';
import 'package:bike_listing/src/fetures/listing/presetation/widgets/bike_list_card.dart';
import 'package:bike_listing/src/fetures/wishlist/application/wishlist_service.dart';
import 'package:bike_listing/src/utils/constant.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// TODO: Optimize the code for less rerenders

enum ViewType { grid, list }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ViewType _viewType = ViewType.list;

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
  Widget build(BuildContext context) {
    ref.watch(watchWishlistProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BX',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
          IconButton(
            icon:
                Icon(_viewType == ViewType.grid ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _viewType =
                    _viewType == ViewType.grid ? ViewType.list : ViewType.grid;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.0),
        child: FirestoreQueryBuilder<Listing>(
          query: ref.read(listingRepositoryProvider).getListingsQuery(),
          builder: (context, snapshot, _) {
            if (snapshot.isFetching) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return _viewType == ViewType.grid
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 9 / 16,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: snapshot.docs.length,
                    itemBuilder: (context, index) {
                      Listing listing = snapshot.docs[index].data();
                      listing = _withUpdatedImageUrls(listing);
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        snapshot.fetchMore();
                      }
                      return BikeGridCard(
                        listing: listing,
                        onTap: () {
                          context.push('/bike_detail', extra: listing);
                        },
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: snapshot.docs.length,
                    itemBuilder: (context, index) {
                      Listing listing = snapshot.docs[index].data();
                      listing = _withUpdatedImageUrls(listing);
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        snapshot.fetchMore();
                      }
                      return BikeListCard(
                        listing: listing,
                        onTap: () {
                          context.push('/bike_detail', extra: listing);
                        },
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}
