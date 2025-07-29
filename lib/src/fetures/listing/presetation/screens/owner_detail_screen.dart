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
          const Text('Showing All Ads',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          userListingsAsync.when(
            data: (data) {
              if (data.isEmpty) {
                return Center(
                  child: Text('Try Adding Something To Wishlist'),
                );
              }
              return ListView.builder(
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

// class UserProfileScreen extends ConsumerWidget {
//   final String userId;

//   const UserProfileScreen({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Fetch UserMeta data
//     final userMetaAsync = ref.watch(fetchUserMetaProvider(userId));

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white, // Match image background
//         elevation: 0, // No shadow
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_vert, color: Colors.black),
//             onPressed: () {
//               // TODO: Implement options menu
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Colors.white, // Match image background
      // body: userMetaAsync.when(
      //   loading: () => const Center(child: CircularProgressIndicator()),
      //   error: (error, stack) => Center(
      //     child: Text('Error loading profile: $error'),
      //   ),
      //   data: (userMeta) {
      //     if (userMeta == null) {
      //       return const Center(child: Text('User not found.'));
      //     }
      //     // Once userMeta is loaded, build the rest of the profile
      //     return _buildProfileContent(context, ref, userMeta);
      //   },
      // ),
  //   );
  // }

//   Widget _buildProfileContent(
//       BuildContext context, WidgetRef ref, UserMeta userMeta) {
//     // Fetch the user's ads using the second provider
//     final userAdsAsync = ref.watch(fetchUserAdsProvider(userId));

//     final String initials = (userMeta.userName?.isNotEmpty ?? false)
//         ? userMeta.userName!
//             .trim()
//             .split(' ')
//             .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
//             .take(2) // Take max 2 initials
//             .join()
//         : '?';

//     // Determine ad count - use the fetched ads list length for accuracy
//     // We show loading/error state for ads separately below
//     final adCount = userAdsAsync.maybeWhen(
//       data: (ads) => ads.length,
//       orElse: () =>
//           userMeta.userListings?.length ??
//           0, // Fallback to count from UserMeta if ads not loaded yet
//     );
//     final String adCountText =
//         adCount == 1 ? '1 published ad' : '$adCount published ads';

//     return RefreshIndicator(
//       // Optional: Add pull-to-refresh
//       onRefresh: () async {
//         // Invalidate providers to trigger a refetch
//         ref.invalidate(fetchUserMetaProvider(userId));
//         ref.invalidate(fetchUserAdsProvider(userId));
//         // Ensure the futures complete before ending refresh
//         await Future.wait([
//           ref.read(fetchUserMetaProvider(userId).future),
//           ref.read(fetchUserAdsProvider(userId).future),
//         ]);
//       },
//       child: ListView(
//         // Use ListView for scrollable content
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           // --- Profile Header ---
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 35,
//                 backgroundColor:
//                     const Color(0xFF1BAE9F), // Teal color from image
//                 child: Text(
//                   initials,
//                   style: const TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     userMeta.userName ?? 'Unknown User',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   // Make ad count text tappable (optional)
//                   InkWell(
//                     onTap: () {
//                       // Optional: Action when tapping ad count
//                       print("Ad count tapped");
//                     },
//                     child: Text(
//                       adCountText, // Use the dynamically calculated text
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF1BAE9F), // Teal color
//                         decoration:
//                             TextDecoration.underline, // Underline as in image
//                         decorationColor: Color(0xFF1BAE9F),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 24), // Space before "Showing X ad(s)"

//           // --- Skipped Share Button and Filter Section ---

//           // --- Ads List Section ---
//           userAdsAsync.when(
//             loading: () => const Padding(
//               padding: EdgeInsets.symmetric(vertical: 30.0),
//               child: Center(child: CircularProgressIndicator()),
//             ),
//             error: (error, stack) => Padding(
//               padding: const EdgeInsets.symmetric(vertical: 30.0),
//               child: Center(child: Text('Error loading ads: $error')),
//             ),
//             data: (ads) {
//               // Show "Showing X ad" only when ads are loaded
//               final String showingText = ads.length == 1
//                   ? 'Showing 1 ad'
//                   : 'Showing ${ads.length} ads';
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     showingText,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   if (ads.isEmpty)
//                     const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 30.0),
//                       child:
//                           Center(child: Text('This user has no active ads.')),
//                     )
//                   else
//                     // Build the list of Ad Cards
//                     ListView.builder(
//                       shrinkWrap: true, // Important inside another ListView
//                       physics:
//                           const NeverScrollableScrollPhysics(), // Disable scrolling for inner list
//                       itemCount: ads.length,
//                       itemBuilder: (context, index) {
//                         return AdCard(ad: ads[index]);
//                       },
//                     ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
