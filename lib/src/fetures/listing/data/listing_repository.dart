import 'package:bike_listing/src/fetures/listing/domain/listing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ListingRepository {
  Future<List<Listing>> fetchListings();

  Future<Listing> getListingById(String id);

  Future<void> createListing(Listing listing);

  Future<void> deleteListing(String id);

  Future<void> updateListing(Listing listing);

  Stream<List<Listing>> watchListings();

  Stream<Listing> watchListingById(String id);

  Future<List<Listing>> fetchListingsByUserId(String userId);

  Stream<List<Listing>> watchListingsByUserId(String userId);

  Query<Listing> getListingsQuery();
}
