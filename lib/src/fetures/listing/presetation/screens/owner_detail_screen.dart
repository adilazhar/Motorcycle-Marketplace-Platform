import 'package:bike_listing/src/fetures/authentication/data/user_meta_repository.dart';
import 'package:bike_listing/src/fetures/authentication/domain/user_meta.dart';
import 'package:bike_listing/src/fetures/listing/data/firestore_listing_repository.dart';
import 'package:bike_listing/src/fetures/listing/domain/listing.dart';
import 'package:bike_listing/src/fetures/listing/presetation/widgets/bike_list_card.dart';
import 'package:bike_listing/src/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OwnerDetailScreen extends ConsumerWidget {
  const OwnerDetailScreen(
    this.ownerId, {
    super.key,
  });

  final String ownerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMetaAsync = ref.watch(fetchUserMetaProvider(ownerId));
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: userMetaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading profile: $error'),
        ),
        data: (userMeta) {
          if (userMeta == null) {
            return const Center(child: Text('User not found.'));
          }
          // Once userMeta is loaded, build the rest of the profile
          return _buildOwnerContent(userMeta, ref, ownerId);
        },
      ),
    );
  }

  Widget _buildOwnerContent(UserMeta userMeta, WidgetRef ref, String uid) {
    final userListingsAsync = ref.watch(fetchListingsForUserProvider(uid));
    // Get the first initial, handle null or empty userName
    final String initial = (userMeta.userName?.isNotEmpty ?? false)
        ? userMeta.userName!.substring(0, 1).toUpperCase()
        : '?'; // Placeholder if no name

    List<String> replaceIpInImageUrls(List<String> imageUrls) {
      return imageUrls.map((url) {
        final uri = Uri.tryParse(url);
        if (uri == null || uri.host.isEmpty) return url;
        final newUri = uri.replace(host: AppConstants.ipAddress);
        return newUri.toString();
      }).toList();
    }

    Listing withUpdatedImageUrls(Listing listing) {
      final updatedUrls = replaceIpInImageUrls(listing.imageUrls);
      return listing.copyWith(imageUrls: updatedUrls);
    }

    // Format the join date, handle null joinDate
    final String joinDateString = userMeta.joinDate != null
        ? 'Member since ${DateFormat('yyyy-MM-dd').format(userMeta.joinDate!)}'
        : 'Join date unknown';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black,
                child: Text(initial,
                    style: TextStyle(color: Colors.white, fontSize: 30)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userMeta.userName ?? 'Unknown Seller',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(joinDateString, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(),
          const SizedBox(height: 16),
          userListingsAsync.when(
            data: (data) {
              if (data.isEmpty) {
                return Center(
                  child: Text('This user has no listings'),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Showing All Ads (${data.length})',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var listing = data[index];
                      listing = withUpdatedImageUrls(listing);
                      return BikeListCard(
                        listing: listing,
                        onTap: () {
                          context.push('/bike_detail', extra: listing);
                        },
                      );
                    },
                  )
                ],
              );
            },
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
            loading: () => Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
