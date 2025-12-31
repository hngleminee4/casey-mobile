import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'siparislerim.dart';

class AdresEkrani extends StatefulWidget {
  final double araToplam;
  final double kargoUcreti;
  final double genelToplam;

  const AdresEkrani({
    super.key,
    required this.araToplam,
    required this.kargoUcreti,
    required this.genelToplam,
  });

  @override
  State<AdresEkrani> createState() => _AdresEkraniState();
}

class _AdresEkraniState extends State<AdresEkrani> {
  final TextEditingController adresController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adres ve Ödeme"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Teslimat Adresi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: adresController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Açık adresinizi girin",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Ödeme Yöntemi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
                color: Colors.white,
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.radio_button_checked,
                    color: Colors.green,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kapıda Ödeme",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Ürün tesliminde ödeme yapılır",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (adresController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Adres giriniz")),
                    );
                    return;
                  }

                  await _siparisKaydet(adresController.text);

                  showDialog(
                    context: context,
                    barrierDismissible: false,//kullanıcı mutlaka butonu kullansın baska yere basınca cıkmasın
                    builder: (_) => AlertDialog(
                      title: const Text("Siparişiniz Alındı 🎉"),
                      content: const Text(
                        "Siparişiniz başarıyla oluşturuldu.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(//kullancı tekrar dönemesin stackten sil.
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SiparislerimEkran(),
                              ),
                                  (route) => false,
                            );
                          },
                          child: const Text("Siparişlerim"),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  "Siparişi Onayla",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _siparisKaydet(String adres) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final cartSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("cart")
        .get();

    final urunler = cartSnapshot.docs.map((doc) {//urunleri snapshottan okudu listeye cevirdi ve urunler dizisine kaydetti
      final d = doc.data();
      return {
        "name": d["name"],
        "price": d["price"],
        "quantity": d["quantity"],
        "imageUrl": d["imageUrl"],
      };
    }).toList();

    await FirebaseFirestore.instance.collection("siparisler").add({
      "userId": uid,
      "adres": adres,
      "urunler": urunler,
      "araToplam": widget.araToplam,
      "kargoUcreti": widget.kargoUcreti,
      "toplamTutar": widget.genelToplam,
      "odemeYontemi": "Kapıda Ödeme",
      "durum": "Hazırlanıyor",
      "tarih": FieldValue.serverTimestamp(),//kullanıcının cihazının saati farklı ya da yanlıs olursa diye
    });

    for (final doc in cartSnapshot.docs) {
      await doc.reference.delete();//siparisten sonra cart koleksiyonunu silip sepeti bosalttım
    }
  }
}
