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
