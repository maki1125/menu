// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCsca43zV6iL4mNoBYY6iD2TCDZfcNkgVE',
    appId: '1:652180432500:web:42394eae0e51554af39321',
    messagingSenderId: '652180432500',
    projectId: 'menu-82775',
    authDomain: 'menu-82775.firebaseapp.com',
    storageBucket: 'menu-82775.firebasestorage.app',
    measurementId: 'G-F5E1Q58DME',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBFwN_as_Z6hnrg_zfRWGNXQ2CNVYIIjlc',
    appId: '1:652180432500:android:fb0dedfa03e27714f39321',
    messagingSenderId: '652180432500',
    projectId: 'menu-82775',
    storageBucket: 'menu-82775.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIK4o7ZoxFFgNrGGq6japCDdlqCSkEzOo',
    appId: '1:652180432500:ios:fbc798048ed4bc17f39321',
    messagingSenderId: '652180432500',
    projectId: 'menu-82775',
    storageBucket: 'menu-82775.firebasestorage.app',
    androidClientId: '652180432500-fvugu23p2s2843rm86ib5ndl160ce8bf.apps.googleusercontent.com',
    iosClientId: '652180432500-f56bd47gpfkkaofk298oentn3lu40n5d.apps.googleusercontent.com',
    iosBundleId: 'com.kudomaki.menu3',
  );
}
