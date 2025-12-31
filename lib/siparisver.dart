import 'package:caseymobile/siparislerim.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SiparisVerEkran extends StatelessWidget {
  final List<Map<String, dynamic>> sepetUrunleri;
  final double toplamTutar;

  const SiparisVerEkran({
    super.key,
    required this.sepetUrunleri,
    required this.toplamTutar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sipariş Ver")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ödeme Yöntemi",//ödeme yöntemini kredi kartı vb ugrasmamak için sadece kapıda ödeme aldım
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    "Kapıda Ödeme",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _siparisKaydet();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SiparislerimEkran(),
                    ),
                  );
                },
                child: const Text("Siparişi Onayla"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _siparisKaydet() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("siparisler")
        .add({
      "userId": uid,
      "urunler": sepetUrunleri,
      "toplamTutar": toplamTutar,
      "odemeYontemi": "Kapıda Ödeme",
      "durum": "Hazırlanıyor",
      "tarih": FieldValue.serverTimestamp(),
    });
  }
}
