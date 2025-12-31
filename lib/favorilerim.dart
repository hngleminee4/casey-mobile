import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavorilerimEkran extends StatelessWidget {
  const FavorilerimEkran({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Giriş yapılmamış"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorilerim"),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC3A7F3), Color(0xFFE9D7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: StreamBuilder<QuerySnapshot>(//gercek zamanlı veri alıyorum
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .collection("favorites")
              .snapshots(),//firestoredaki her değişiklikte arayüzüm yenileniyo.cunku bu sayfada favoriye ekleyip cıkarıcam

          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  "Henüz favori eklemediniz",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: docs.length,

              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final productId = doc.id;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(//kalbi resmin üstüne koyacagımız icin
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                              child: Image.network(
                                data["imageUrl"],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),

                            Positioned(
                              right: 8,
                              top: 8,
                              child: GestureDetector(
                                onTap: () {
                                  FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(user.uid)
                                      .collection("favorites")
                                      .doc(productId)
                                      .delete();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Favorilerden kaldırıldı")),
                                  );
                                },
                                child: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white70,
                                  child: Icon(Icons.favorite, color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      ElevatedButton(
                        onPressed: () async {
                          final cartRef = FirebaseFirestore.instance
                              .collection("users")
                              .doc(user.uid)
                              .collection("cart")
                              .doc(productId);

                          final cartDoc = await cartRef.get();

                          if (cartDoc.exists) {
                            await cartRef.update({
                              "quantity": FieldValue.increment(1),//urun varsa adedini 1 arttır
                            });
                          } else {
                            await cartRef.set({
                              "name": data["name"],
                              "imageUrl": data["imageUrl"],
                              "price": (data["price"] as num),
                              "quantity": 1,
                            });
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Ürün sepete eklendi")),
                          );
                        },
                        child: const Text("Sepete Ekle"),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          data["name"],
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6B6FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          "${data["price"]} ₺",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A2EA6),
                            fontSize: 15,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
