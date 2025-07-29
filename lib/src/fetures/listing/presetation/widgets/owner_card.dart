import 'package:bike_listing/src/fetures/authentication/data/user_meta_repository.dart';
import 'package:bike_listing/src/fetures/authentication/domain/user_meta.dart';
import 'package:bike_listing/src/fetures/listing/presetation/screens/owner_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class OwnerCard extends ConsumerWidget {
  final String userId;

  const OwnerCard(this.userId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMetaAsync = ref.watch(fetchUserMetaProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Section Title
        const Text('Seller Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // 2. Use AsyncValue.when to handle states
        userMetaAsync.when(
          // 2a. Data Loaded Successfully
          data: (userMeta) {
            // Check if userMeta is null (user ID not found in DB)
            if (userMeta == null) {
              return const Center(
                child: Text('Seller information not available.'),
              );
            }

            // Build the card content if userMeta exists
            return _buildSellerContent(context, userMeta);
          },
          // 2b. Loading State
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(),
            ),
          ),
          // 2c. Error State
          error: (error, stackTrace) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Error loading seller info: ${error.toString()}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper widget to build the content when data is available
  Widget _buildSellerContent(BuildContext context, UserMeta userMeta) {
    // Get the first initial, handle null or empty userName
    final String initial = (userMeta.userName?.isNotEmpty ?? false)
        ? userMeta.userName!.substring(0, 1).toUpperCase()
        : '?'; // Placeholder if no name

    // Format the join date, handle null joinDate
    final String joinDateString = userMeta.joinDate != null
        ? 'Member since ${DateFormat('yyyy-MM-dd').format(userMeta.joinDate!)}'
        : 'Join date unknown';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.black,
            child: Text(initial, style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userMeta.userName ?? 'Unknown Seller',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(joinDateString, style: TextStyle(color: Colors.grey)),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => OwnerDetailScreen(userId),
                  )),
                  child: Text(
                    'View Profile',
                    style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
