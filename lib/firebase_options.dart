import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
// import 'package:flutter/foundation.dart'
//     show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyDeA98QSV8GfqfNIqmB1PEVuIuUAxgV7LA",
      authDomain: "pal-journal.firebaseapp.com",
      projectId: "pal-journal",
      storageBucket: "pal-journal.firebasestorage.app",
      messagingSenderId: "579107211170",
      appId: "1:579107211170:web:d4510d0e1cc0759f0914fb",
    );
  }
}
