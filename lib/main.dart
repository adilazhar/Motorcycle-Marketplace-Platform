import 'package:bike_listing/firebase_options.dart';
import 'package:bike_listing/my_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // TODO: Set This IP Before running
  String host = '192.168.1.128';
  await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);

  runApp(ProviderScope(child: MyApp()));
}

/////Todo: Make the Homepage animate from left when signing in or after creating new account
// Todo: Create The Add Listing Page
// Todo: Implement Proper Validation
// Todo: Spacing Between the items
// Todo: Properly Format Enums
// Todo: Turn Off tick for chips
// Todo: Reordering of The pictures in the selected images
// Todo: Save Method
// Todo: Make the Auth Screens Scrollable to remove overflow error
// Todo: Delete All User Listings When A User Deletes his Account
// Todo: Add Search bar to search the Options in the enums selectors
// Todo: totalListings, how to increase and decrease the listings count on creating and deleting the listing
