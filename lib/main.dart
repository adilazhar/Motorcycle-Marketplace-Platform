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

  // Todo: Set This IP Before running
  // Todo: Start The Local Emualators
  // firebase emulators:start --import=./seed --export-on-exit

  String host = '192.168.1.108';
  await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);

  runApp(ProviderScope(child: MyApp()));
}

/////Todo: Fix the form not showing the validation error (All the FormBuilderField custom field)
// Todo: Refactor the widgets to decrease the rebuilds
// Todo: Delete All User Listings When A User Deletes his Account
// Todo: totalListings, how to increase and decrease the listings count on creating and deleting the listing
// Todo: Add the editing page , user listing page
// TODO: The images are not being loaded bcz it adds the current ip address when uploaded to the storage and it can change so replace ip with 127.0.0.1

// TODO: Add Security Rules to Firestore
// TODO: When a User deletes its account delete all the ads and also clear his data from the firestore
// TODO: Learn How to Create A Kanban Board By Learning to create a ReorderableListView


// TODO: Optimize the WishList Icon Button For the Bike Detail Screen