import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:caseymobile/adresekrani.dart';

class SepetimEkran extends StatelessWidget {
  const SepetimEkran({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final FirebaseAuth _auth = FirebaseAuth.instance;


    if (user == null) {
      return const Center(child: Text("Giriş yapılmamış"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sepetim"),
        centerTitle: true,
        backgroundColor: Colors.purple,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(_auth.currentUser!.uid)
                .collection("cart")
                .snapshots(),
            builder: (context, snapshot) {
              int itemCount = 0;

              if (snapshot.hasData) {
                for (final doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  itemCount += (data["quantity"] ?? 1) as int;
                }
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SepetimEkran()),
                      );
                    },
                  ),

                  if (itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          itemCount > 99 ? "99+" : itemCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],

      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("cart")
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Sepetiniz boş"));
          }

          double araToplam = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final price = (data["price"] as num).toDouble();
            final quantity = (data["quantity"] as num).toInt();

            araToplam += price * quantity;
          }

          const double normalKargo = 49.90;

          final bool ucretsizKargo = araToplam >= 999;
          final double kargoUcreti = ucretsizKargo ? 0 : normalKargo;

          final double genelToplam = araToplam + kargoUcreti;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return ListTile(
                      leading: Image.network(
                        data["imageUrl"],
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(data["name"]),
                      subtitle: Text(
                        "${data["price"]} ₺ x ${data["quantity"]}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          doc.reference.delete();
                        },
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Sipariş Özeti",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _ozetSatiri("Ara Toplam", "${araToplam.toStringAsFixed(2)} ₺"),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Kargo"),
                          ucretsizKargo
                              ? Row(
                            children: const [
                              Text(
                                "Ücretsiz Kargo",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "49.90 ₺",
                                style: TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          )
                              : Text("${normalKargo.toStringAsFixed(2)} ₺"),
                        ],
                      ),
                    ),


                    const Divider(height: 24),

                    _ozetSatiri(
                      "Toplam Tutar",
                      "${genelToplam.toStringAsFixed(2)} ₺",
                      isBold: true,
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdresEkrani(
                                araToplam: araToplam,
                                kargoUcreti: kargoUcreti,
                                genelToplam: genelToplam,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Sipariş Ver",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ozetSatiri(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
