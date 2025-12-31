import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
//uygulamanın calıstıgı platforma göre ayar dosyası.platforma göre baslamak için
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
        throw UnsupportedError(//linux için config olmadıgından hata
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
    apiKey: 'AIzaSyCF0TzJrFtcq5iIg7r-5DJb0ifoaqM6rEo',//Firebase erişim anahtarı
    appId: '1:299868857742:web:31689c2e35a324fcbd70df',//uygulamanın ozgunlugu id
    messagingSenderId: '299868857742',//firebasenin bildirim gönderme yetkisini gösterir
    projectId: 'kilifirebase-b54f1',//projenin adı
    authDomain: 'kilifirebase-b54f1.firebaseapp.com',
    storageBucket: 'kilifirebase-b54f1.firebasestorage.app',//storage bilgileri
    measurementId: 'G-TXYZBWRSV8',//kullanıcı etkilesimlerinin google analytics tarafından ölcülmesi
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDnOATpRQQM2TVVtXouyeVT_tVWGtNjdFU',
    appId: '1:299868857742:android:cb83bacf6021e953bd70df',
    messagingSenderId: '299868857742',
    projectId: 'kilifirebase-b54f1',
    storageBucket: 'kilifirebase-b54f1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC-DxYlVvlMYm9YLzt0OrmZCrN6sBA0Kuk',
    appId: '1:299868857742:ios:1f87f1bd729136febd70df',
    messagingSenderId: '299868857742',
    projectId: 'kilifirebase-b54f1',
    storageBucket: 'kilifirebase-b54f1.firebasestorage.app',
    iosBundleId: 'com.casey.caseymobile',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC-DxYlVvlMYm9YLzt0OrmZCrN6sBA0Kuk',
    appId: '1:299868857742:ios:1f87f1bd729136febd70df',
    messagingSenderId: '299868857742',
    projectId: 'kilifirebase-b54f1',
    storageBucket: 'kilifirebase-b54f1.firebasestorage.app',
    iosBundleId: 'com.casey.caseymobile',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCF0TzJrFtcq5iIg7r-5DJb0ifoaqM6rEo',
    appId: '1:299868857742:web:c76e6925f9f9e706bd70df',
    messagingSenderId: '299868857742',
    projectId: 'kilifirebase-b54f1',
    authDomain: 'kilifirebase-b54f1.firebaseapp.com',
    storageBucket: 'kilifirebase-b54f1.firebasestorage.app',
    measurementId: 'G-48QGCYYB31',
  );

}