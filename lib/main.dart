import 'package:bike_listing/firebase_options.dart';
import 'package:bike_listing/my_app.dart';
import 'package:bike_listing/src/utils/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // * Set The IP in AppConstants class Before running the app
  // * Start The Local Emualators Using :
  //  firebase emulators:start --import=./seed --export-on-exit

  String host = AppConstants.ipAddress;
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);

  runApp(ProviderScope(child: MyApp()));
}

// TODO: Hide the Wishlist icon in the My Ads Screen and the Bike Detail Screen
// TODO: Make the Bike Detail Screen configurable to show or hide the user account card
// Todo: Add the editing page , user listing page
// TODO: Add Security Rules to Firestore

/* 
Here is the firestore collections for my app :

1.listings Collection:
listings/
    {document_id}/
        imageUrls: string[]
        title: string
        description: string
        price: number
        year: number
        mileage: number
        brand: string
        model: string
        engineCapacity: string
        registrationCity: string
        isSelfStart: boolean
        isNew: boolean
        coordinates: GeoPoint
        location: string
        createdAt: timestamp
        updatedAt: timestamp
        userId: string

2.users Collection:
users/
    {uid}/  # User's Firebase Auth UID
        userName: string
        bio: string
        joinDate: timestamp
        email: string

3.wishlist Collection:
wishlist/
    {uid}/  # User's Firebase Auth UID
        listingIds: string[]  # Array of favorited listing IDs


####
And here is the storage structure for images:

Storage Structure:
firebase-storage/
    listings/
        {uuid}.jpg // Compressed images with metadata


When a user deletes their account, need to:
- Delete user's auth account
- Delete user document from users collection
- Delete all listings where userId matches
- Delete All images in firebase-storage/listings/{uuid}.jpg for each listing
- Remove user's listings from other users' wishlists
- Delete user's wishlist document

When a user deletes a listing, need to:
- Delete listing document from listings collection
- Delete all images in firebase-storage/listings/{uuid}.jpg for the listing
- Remove listing from all users' wishlists
*/
