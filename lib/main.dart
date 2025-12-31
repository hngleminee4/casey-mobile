import 'package:caseymobile/karsilamaekrani.dart';
import 'package:caseymobile/service/auth.dart';
import 'package:caseymobile/siparislerim.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:caseymobile/girisyap_uyeol.dart';
import 'package:camera/camera.dart';
import 'package:caseymobile/kullanicibilgiekrani.dart';
import 'package:caseymobile/urunekle.dart';
import 'package:caseymobile/favorilerim.dart';
import 'package:caseymobile/sepetim.dart';
import 'kilifekran.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();//firebase baslatma vb icin

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        '/SepetimEkran': (context) => const SepetimEkran(),

      },

      home: StreamBuilder(
        stream: authService.authStateChanges,//giris cıkıs durumu takip
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),//yükleniyo
            );
          }

          if (snapshot.hasData) {//giris varsa
            return const KarsilamaEkrani();
          } else {
            return const Girisyapekran();
          }
        },
      ),
    );
  }
}
