import 'package:caseymobile/firestorebaglan.dart';
import 'package:caseymobile/firestoreservice.dart';
import 'package:caseymobile/service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Girisyapekran extends StatefulWidget {
  const Girisyapekran({super.key});

  @override
  State<Girisyapekran> createState() => _GirisyapekranState();
}

class _GirisyapekranState extends State<Girisyapekran> {
  final formKey = GlobalKey<FormState>();
  final UserService userService = UserService();//firestore yazma

  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordRepeatController = TextEditingController();

  bool isLogin = true;
  String? errorMessage;

  final auth = Auth();//firebase auth işlemleri için

  void showMessage(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> kullaniciEkle() async {
    if (fullnameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordRepeatController.text.isEmpty) {
      showMessage("Lütfen tüm alanları doldurun!", true);
      return;
    }

    if (passwordController.text != passwordRepeatController.text) {
      showMessage("Şifreler uyuşmuyor!", true);
      return;
    }

    try {
      UserCredential credential = await auth.kullaniciEkle(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = credential.user!.uid;

      UserModel newUser = UserModel(
        uid: uid,
        fullname: fullnameController.text.trim(),
        email: emailController.text.trim(),
      );

      await userService.kullaniciEkleDb(newUser);

      if (!mounted) return;
      setState(() => isLogin = true);

      showMessage("Kayıt Başarılı!", false);
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? "Kayıt Başarısız!", true);
    }
  }

  Future<void> girisYap() async {
    try {
      await auth.girisYap(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;//kullanıcı sayfadan ayrılırsa hata gelmesin diye

      showMessage("Giriş Başarılı!", false);

      Navigator.pushReplacementNamed(context, "/KarsilamaEkrani");//geri basınca logine gitmemek icin stackten login sayfasını cıkarttık

    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
      showMessage("Giriş Başarısız", true);
    }
  }

  InputDecoration customInputDecoration(String hint) {//tekrar olmasın diye inputdecoration
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 219, 251),
      body: SafeArea(//tasmayı engelledim
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset('assets/images/caseylogo.png', height: 40),
                ),

                const SizedBox(height: 120),

                Text(
                  isLogin ? "Casey'e Hoş Geldin" : "Hesap Oluştur",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 106, 13, 173),
                  ),
                ),

                const SizedBox(height: 40),

                if (!isLogin) ...[
                  TextField(
                    controller: fullnameController,
                    decoration: customInputDecoration("Ad & Soyad"),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: emailController,
                  decoration: customInputDecoration("E-mail"),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: customInputDecoration("Şifre"),
                ),
                const SizedBox(height: 16),

                if (!isLogin) ...[
                  TextField(
                    controller: passwordRepeatController,
                    obscureText: true,
                    decoration: customInputDecoration("Şifre Tekrarı"),
                  ),
                  const SizedBox(height: 12),
                ],

                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () {
                    if (isLogin) {
                      girisYap();
                    } else {
                      kullaniciEkle();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8A2BE2),
                          Color.fromARGB(255, 113, 13, 159),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.purple,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isLogin ? "Giriş Yap" : "Kayıt Ol",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                GestureDetector(//tıklanabilir hale geldi
                  onTap: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? "Hesabın yok mu? Kayıt ol."
                        : "Zaten hesabın var mı? Giriş Yap.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6A0DAD),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
