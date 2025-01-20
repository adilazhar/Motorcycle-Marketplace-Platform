import 'package:bike_listing/src/fetures/listing/data/firestore_listing_repository.dart';
import 'package:bike_listing/src/fetures/listing/domain/listing.dart';
import 'package:bike_listing/src/fetures/listing/presetation/screens/bike_detail_screen.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum ViewType { grid, list }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ViewType _viewType = ViewType.list;

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(8.0),
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
                      childAspectRatio: 0.74,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: snapshot.docs.length,
                    itemBuilder: (context, index) {
                      final listing = snapshot.docs[index].data();
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        snapshot.fetchMore();
                      }
                      return BikeGridCard(
                        listing: listing,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => BikeDetailScreen(listing),
                          ));
                        },
                        formatter: formatter,
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: snapshot.docs.length,
                    itemBuilder: (context, index) {
                      final listing = snapshot.docs[index].data();
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        snapshot.fetchMore();
                      }
                      return BikeListCard(
                        listing: listing,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => BikeDetailScreen(listing),
                          ));
                        },
                        formatter: formatter,
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}

class BikeGridCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final NumberFormat formatter;

  const BikeGridCard({
    super.key,
    required this.listing,
    required this.onTap,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          side: BorderSide(), borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 205,
              height: 120,
              child: Image.network(
                listing.imageUrls[0],
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(08.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            listing.formattedPrice,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                            size: 20,
                          ),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      listing.cardYearAndMileage,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      listing.location,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.timeAgo(),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BikeListCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final NumberFormat formatter;

  const BikeListCard({
    super.key,
    required this.listing,
    required this.onTap,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          side: BorderSide(), borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 160,
              height: 200,
              child: Image.network(
                listing.imageUrls[0],
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            listing.formattedPrice,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.favorite_outline,
                            size: 20,
                          ),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.location,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.cardYearAndMileage,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      listing.timeAgo(),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
