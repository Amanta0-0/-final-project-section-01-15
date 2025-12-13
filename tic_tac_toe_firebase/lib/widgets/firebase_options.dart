import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future<FirebaseOptions> get firebaseOptions async {
  if (kIsWeb) {
    return const FirebaseOptions(
      apiKey: "YOUR_WEB_API_KEY",
      authDomain: "YOUR_PROJECT.firebaseapp.com",
      projectId: "YOUR_PROJECT_ID",
      storageBucket: "YOUR_PROJECT.appspot.com",
      messagingSenderId: "YOUR_SENDER_ID",
      appId: "YOUR_APP_ID",
    );
  }

  // For mobile platforms, you'll need to configure separately
  // Follow Firebase setup instructions for Flutter
  throw UnsupportedError('Platform not supported');
}
