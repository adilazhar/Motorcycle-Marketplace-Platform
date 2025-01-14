import 'package:bike_listing/src/fetures/listing/domain/listing.dart';

abstract class ListingRepository {
  Future<List<Listing>> fetchListings();

  Future<Listing> getListingById(String id);

  Future<void> createListing(Listing listing);

  Future<void> deleteListing(String id);

  Future<void> updateListing(Listing listing);

  Stream<List<Listing>> watchListings();

  Stream<Listing> watchListingById(String id);

  // Todo: Fetch And Watch Listing For A User by id
  // Future<List<Listing>> fetchListingsForUser(String uid);
  // Stream<List<Listing>> watchListingsForUser(String uid);
}
