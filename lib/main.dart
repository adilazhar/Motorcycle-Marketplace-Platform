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
  String host = '192.168.1.128';
  await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);

  runApp(ProviderScope(child: MyApp()));
}

// Todo: Delete All User Listings When A User Deletes his Account
// Todo: totalListings, how to increase and decrease the listings count on creating and deleting the listing
