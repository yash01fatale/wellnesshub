// lib/firebase_options.dart
// GENERATED MANUALLY - Replace placeholders with your Firebase project values.
//
// Recommended: run `flutterfire configure` to generate this automatically.
// If you choose to fill this manually, open Firebase Console -> Project Settings
// -> Your apps -> SDK setup and config and copy the values.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Replace the strings below with values from your Firebase console.
/// You must provide the correct values for each platform you plan to use.
///
/// NOTE: These values are not secret (they are used by the client SDK),
/// but still keep them in your project and do not expose service account keys.

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return android; // fallback — change if you have desktop-specific options
    }
  }

  // ---------- Web ----------
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyC2Si5g2j7Iy8IX9hJUbaUX1GqXdWXxcgk",
    authDomain: "wellnesshub-6bf0b.firebaseapp.com",
    projectId: "wellnesshub-6bf0b",
    storageBucket: "wellnesshub-6bf0b.firebasestorage.app",
    messagingSenderId: "644773851267",
    appId: "1:644773851267:web:a0f872738a7ced6bcdebb6",
    measurementId: "G-Y1B7C272DH"
  );

  // ---------- Android ----------
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEHsRGz8E39vTnTDiwOKTk-EGeTUMP8JY',
    appId: '1:644773851267:android:194909340675d203cdebb6', // e.g. 1:123456789:android:abcdef
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'wellnesshub-6bf0b',
    storageBucket: 'wellnesshub-6bf0b.firebasestorage.app',
  );

  // ---------- iOS / macOS ----------
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQHvZkLq2559GVEcIDtN9S3L5-Pz-XsEo',
    appId: '1:644773851267:ios:48399ec9265ed17ccdebb6', // e.g. 1:123456789:ios:abcdef
    messagingSenderId: '644773851267',
    projectId: 'wellnesshub-6bf0b',
    storageBucket: 'wellnesshub-6bf0b.firebasestorage.app',
    iosClientId: '644773851267-t3h0kbfhlpd6hsv2ho7p6vsfm3kqd63c.apps.googleusercontent.com', // optional
    androidClientId: '194909340675d203cdebb6', // optional
  );
}
