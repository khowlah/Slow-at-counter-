// ملف تلقائي التوليد — لا تعدّليه يدويًا.
//
// هذا ملف *مؤقت* بقيم وهمية. يجب استبداله بالملف الحقيقي الذي يولّده أمر:
//   flutterfire configure
// بعد ربط المشروع بحساب Firebase الخاص بك (راجعي README.md، القسم 2).
// إن شغّلتِ التطبيق بدون استبدال هذا الملف فلن يعمل الاتصال بـ Firestore.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions لم تُهيَّأ لهذه المنصة. '
          'شغّلي: flutterfire configure',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAjRofdbv5GEP1LYkBsS6e-lHOZPnGpx6c',
    appId: '1:1012915046548:web:4977ac45d21ebd2557cc81',
    messagingSenderId: '1012915046548',
    projectId: 'salawat-counter-app',
    authDomain: 'salawat-counter-app.firebaseapp.com',
    storageBucket: 'salawat-counter-app.firebasestorage.app',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'com.example.salawatCounter',
  );
}
