import 'package:caseymobile/kameraekrani.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class KarsilamaEkrani extends StatefulWidget {
  const KarsilamaEkrani({super.key});

  @override
  State<KarsilamaEkrani> createState() => _KarsilamaEkraniState();
}

class _KarsilamaEkraniState extends State<KarsilamaEkrani> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _showMessage(String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final newPassController = TextEditingController();
    final repeatPassController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Şifre Değiştir"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Yeni Şifre"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repeatPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Yeni Şifre (Tekrar)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () async {
                final newPass = newPassController.text.trim();
                final repeatPass = repeatPassController.text.trim();

                if (newPass.isEmpty || repeatPass.isEmpty) {
                  _showMessage("Lütfen tüm alanları doldurun.", true);
                  return;
                }

                if (newPass != repeatPass) {
                  _showMessage("Şifreler uyuşmuyor.", true);
                  return;
                }

                try {
                  final user = _auth.currentUser;
                  if (user == null) {
                    _showMessage("Oturum bulunamadı.", true);
                    return;
                  }

                  await user.updatePassword(newPass);//hata olursa exception gelir
                  if (context.mounted) Navigator.pop(context);

                  _showMessage("Şifre başarıyla güncellendi.", false);
                } on FirebaseAuthException catch (e) {
                  _showMessage(e.message ?? "Şifre güncellenemedi.", true);
                }
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = _auth.currentUser?.email;
    final bool isAdmin = currentUserEmail == "casey@gmail.com";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Casey"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, size: 30),
            onSelected: (value) async {
              if (value == "uekle" && isAdmin) {
                Navigator.pushNamed(context, '/UrunEkle');
              } else if (value == "favs") {
                Navigator.pushNamed(context, '/FavorilerimEkran');
              } else if (value == "sepets") {
                Navigator.pushNamed(context, "/SepetimEkran");
              } else if (value == "orders") {
                Navigator.pushNamed(context, "/SiparislerimEkran");
              }else if (value == "info") {
                Navigator.pushNamed(context, "/KullaniciBilgileri");
              } else if (value == "password") {
                _showChangePasswordDialog();
              } else if (value == "cikis") {
                await _auth.signOut();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/GirisyapEkran');
              }
            },

            itemBuilder: (context) {
              List<PopupMenuEntry<String>> items = [];

              if (isAdmin) {
                items.add(
                  const PopupMenuItem(
                    value: "uekle",
                    child: ListTile(
                      leading: Icon(Icons.add_box),
                      title: Text("Ürün Ekle (Admin)"),
                    ),
                  ),
                );
              }
              items.addAll([
                const PopupMenuItem(
                  value: "favs",
                  child: ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text("Favorilerim"),
                  ),
                ),
                const PopupMenuItem(
                  value: "sepets",
                  child: ListTile(
                    leading: Icon(Icons.shopping_bag),
                    title: Text("Sepetim"),
                  ),
                ),
                const PopupMenuItem(
                  value: "orders",
                  child: ListTile(
                    leading: Icon(Icons.check_box),
                    title: Text("Siparişlerim"),
                  ),
                ),
                const PopupMenuItem(
                  value: "info",
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Kullanıcı Bilgileri"),
                  ),
                ),
                const PopupMenuItem(
                  value: "password",
                  child: ListTile(
                    leading: Icon(Icons.lock),
                    title: Text("Şifre Değiştir"),
                  ),
                ),
                const PopupMenuItem(
                  value: "cikis",
                  child: ListTile(
                    leading: Icon(Icons.output),
                    title: Text("Çıkış yap"),
                  ),
                ),
              ]);
              return items;
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      backgroundColor: const Color.fromARGB(255, 243, 219, 251),

      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Kameraekran()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8A2BE2), Color(0xFF710D9F)],
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
            child: const Text(
              "Kılıfımı bul",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
