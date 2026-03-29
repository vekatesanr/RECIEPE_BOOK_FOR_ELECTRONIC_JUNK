// File generated based on provided Firebase project configuration.
// For full setup, download google-services.json from Firebase Console
// and place it in android/app/ directory.

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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCQbU6Hygkvbf1TF_Phn9OtKArHsAwltdY',
    appId: '1:147862152856:web:8b5ca625f2ad12058252ed',
    messagingSenderId: '147862152856',
    projectId: 'electronic-junk',
    storageBucket: 'electronic-junk.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDwpf3ZGw_r7rEX5wxrFKvofM2grj9K2AQ',
    appId: '1:147862152856:android:85121f7eb30158d88252ed',
    messagingSenderId: '147862152856',
    projectId: 'electronic-junk',
    storageBucket: 'electronic-junk.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQbU6Hygkvbf1TF_Phn9OtKArHsAwltdY',
    appId: '1:147862152856:ios:8b5ca625f2ad12058252ed',
    messagingSenderId: '147862152856',
    projectId: 'electronic-junk',
    storageBucket: 'electronic-junk.firebasestorage.app',
    iosBundleId: 'com.example.ejunkFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCQbU6Hygkvbf1TF_Phn9OtKArHsAwltdY',
    appId: '1:147862152856:ios:8b5ca625f2ad12058252ed',
    messagingSenderId: '147862152856',
    projectId: 'electronic-junk',
    storageBucket: 'electronic-junk.firebasestorage.app',
    iosBundleId: 'com.example.ejunkFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCQbU6Hygkvbf1TF_Phn9OtKArHsAwltdY',
    appId: '1:147862152856:web:8b5ca625f2ad12058252ed',
    messagingSenderId: '147862152856',
    projectId: 'electronic-junk',
    storageBucket: 'electronic-junk.firebasestorage.app',
  );
}
