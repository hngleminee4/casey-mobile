import 'package:caseymobile/karsilamaekrani.dart';
import 'package:caseymobile/service/auth.dart';
import 'package:caseymobile/siparislerim.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:caseymobile/girisyap_uyeol.dart';
import 'package:camera/camera.dart';
import 'package:caseymobile/kullanicibilgiekrani.dart';
import 'package:caseymobile/deneme.dart';
import 'package:caseymobile/urunekle.dart';
import 'package:caseymobile/favorilerim.dart';
import 'kilifekran.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  printModelInfo();
  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Auth authService = Auth();

    return MaterialApp(
      title: 'Casey',
      debugShowCheckedModeBanner: false,

      routes: {
        '/UrunEkle': (context) => const UrunEkleEkrani(),
        '/FavorilerimEkran': (context) => const FavorilerimEkran(),
        '/GirisyapEkran': (context) => const Girisyapekran(),
        '/kiliflar': (context) => const KilifEkrani(),
        '/KarsilamaEkrani': (context) => const KarsilamaEkrani(),
        '/KullaniciBilgileri': (context) => const KullaniciBilgileri(),
        '/SiparislerimEkran': (context) => const SiparislerimEkran(),
      },

      home: StreamBuilder(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const KarsilamaEkrani();
          } else {
            return const Girisyapekran();
          }
        },
      ),
    );
  }
}
