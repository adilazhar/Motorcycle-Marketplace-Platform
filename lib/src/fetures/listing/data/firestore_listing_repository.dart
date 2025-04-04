import 'package:bike_listing/src/fetures/listing/data/listing_repository.dart';
import 'package:bike_listing/src/providers/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bike_listing/src/fetures/listing/domain/listing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_listing_repository.g.dart';

// Todo: Add Security Roles
class FirestoreListingRepository implements ListingRepository {
  final FirebaseFirestore _firestore;

  FirestoreListingRepository(this._firestore);

  @override
  Query<Listing> getListingsQuery() {
    return _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .withConverter<Listing>(
          fromFirestore: (snapshot, _) =>
              Listing.fromMap(snapshot.id, snapshot.data()!),
          toFirestore: (listing, _) => listing.toMapForCreation(),
        );
  }

  @override
  Future<List<Listing>> fetchListings() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('listings')
          .orderBy('createdAt', descending: true)
          .get();
      List<Listing> listings = querySnapshot.docs
          .map((doc) =>
              Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      return listings;
    } catch (e) {
      debugPrint('Error fetching listings: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<Listing> getListingById(String id) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('listings').doc(id).get();
      if (docSnapshot.exists) {
        return Listing.fromMap(
            docSnapshot.id, docSnapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception('Listing not found');
      }
    } catch (e) {
      debugPrint('Error getting listing by ID: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<String> createListing(Listing listing) async {
    try {
      final docRef = await _firestore
          .collection('listings')
          .add(listing.toMapForCreation());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating listing: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> deleteListing(String id) async {
    try {
      await _firestore.collection('listings').doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting listing: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> updateListing(Listing listing) async {
    try {
      await _firestore
          .collection('listings')
          .doc(listing.id)
          .update(listing.toMapForUpdate());
    } catch (e) {
      debugPrint('Error updating listing: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Stream<List<Listing>> watchListings() {
    return _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map((doc) => Listing.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<Listing> watchListingById(String id) {
    return _firestore.collection('listings').doc(id).snapshots().map(
      (docSnapshot) {
        if (docSnapshot.exists) {
          return Listing.fromMap(
              docSnapshot.id, docSnapshot.data() as Map<String, dynamic>);
        } else {
          throw Exception('Listing not found');
        }
      },
    );
  }

  @override
  Future<List<Listing>> fetchListingsByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('listings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      List<Listing> listings = querySnapshot.docs
          .map((doc) =>
              Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      return listings;
    } catch (e) {
      debugPrint('Error fetching listings by user ID: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Stream<List<Listing>> watchListingsByUserId(String userId) {
    return _firestore
        .collection('listings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Listing.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Stream<List<Listing>> watchListingsById(List<String> wishListed) {
    if (wishListed.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('listings')
        .where(FieldPath.documentId, whereIn: wishListed)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      // final foundIds = querySnapshot.docs.map((doc) => doc.id).toSet();
      // final missingIds = wishListed.where((id) => !foundIds.contains(id));

      // if (missingIds.isNotEmpty) {
      //   debugPrint('Some wishlisted listings were not found: $missingIds');
      // }

      return querySnapshot.docs
          .map((doc) => Listing.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}

@Riverpod(keepAlive: true)
ListingRepository listingRepository(Ref ref) {
  final firestore = ref.read(firestoreProvider);
  return FirestoreListingRepository(firestore);
}
