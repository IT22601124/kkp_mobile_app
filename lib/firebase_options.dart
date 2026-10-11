import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// [DefaultFirebaseOptions] provides default [FirebaseOptions] for current platform.
class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
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
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQhqqkB_gsl7aJmPHrBygW7pS6Td_6Q6g',
    appId: '1:1089349882179:web:626127b77166d29d6bdff6',
    messagingSenderId: '1089349882179',
    projectId: 'sundarambrother-934fe',
    authDomain: 'sundarambrother-934fe.firebaseapp.com',
    storageBucket: 'sundarambrother-934fe.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDQhqqkB_gsl7aJmPHrBygW7pS6Td_6Q6g',
    appId: '1:1089349882179:android:626127b77166d29d6bdff6',
    messagingSenderId: '1089349882179',
    projectId: 'sundarambrother-934fe',
    storageBucket: 'sundarambrother-934fe.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDQhqqkB_gsl7aJmPHrBygW7pS6Td_6Q6g',
    appId: '1:1089349882179:ios:626127b77166d29d6bdff6',
    messagingSenderId: '1089349882179',
    projectId: 'sundarambrother-934fe',
    storageBucket: 'sundarambrother-934fe.firebasestorage.app',
    iosBundleId: 'com.kkp_mobile_app.kkp_rep_mobile_app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDQhqqkB_gsl7aJmPHrBygW7pS6Td_6Q6g',
    appId: '1:1089349882179:ios:626127b77166d29d6bdff6',
    messagingSenderId: '1089349882179',
    projectId: 'sundarambrother-934fe',
    storageBucket: 'sundarambrother-934fe.firebasestorage.app',
    iosBundleId: 'com.kkp_mobile_app.kkp_rep_mobile_app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDQhqqkB_gsl7aJmPHrBygW7pS6Td_6Q6g',
    appId: '1:1089349882179:web:626127b77166d29d6bdff6',
    messagingSenderId: '1089349882179',
    projectId: 'sundarambrother-934fe',
    authDomain: 'sundarambrother-934fe.firebaseapp.com',
    storageBucket: 'sundarambrother-934fe.firebasestorage.app',
  );
}
