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
  final UserService userService = UserService();

  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordRepeatController = TextEditingController();

  bool isLogin = true;
  String? errorMessage;

  final auth = Auth();

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
      showMessage("Please fill all fields!", true);
      return;
    }

    if (passwordController.text != passwordRepeatController.text) {
      showMessage("Passwords do not match!", true);
      return;
    }

    try {
      /// Firebase Authentication'da kullanıcı oluştur
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

      /// Firestore’a tek seferde yazıyoruz (çift yazma yok!)
      await userService.kullaniciEkleDb(newUser);

      if (!mounted) return;
      setState(() => isLogin = true);

      showMessage("Sign up successful!", false);
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? "Sign up failed!", true);
    }
  }

  Future<void> girisYap() async {
    try {
      await auth.girisYap(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      showMessage("Sign in successful!", false);

      Navigator.pushReplacementNamed(context, "/KarsilamaEkrani"); // ⭐⭐
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
      showMessage("Sign in failed", true);
    }
  }

  InputDecoration customInputDecoration(String hint) {
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
      body: SafeArea(
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
                  isLogin ? "Welcome To Casey" : "Create Account",
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
                    decoration: customInputDecoration("Name & Surname"),
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
                  decoration: customInputDecoration("Password"),
                ),
                const SizedBox(height: 16),

                if (!isLogin) ...[
                  TextField(
                    controller: passwordRepeatController,
                    obscureText: true,
                    decoration: customInputDecoration("Repeat Password"),
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
                        isLogin ? "Sign In" : "Sign Up",
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

                GestureDetector(
                  onTap: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? "Don't have an account? Sign Up."
                        : "Already have an account? Sign In.",
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
