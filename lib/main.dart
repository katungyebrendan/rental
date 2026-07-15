import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/property_store.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (error) {
    debugPrint('Firebase initialization skipped: $error');
  }

  await PropertyStore.instance.initialize();
  runApp(const MyApp());
}
