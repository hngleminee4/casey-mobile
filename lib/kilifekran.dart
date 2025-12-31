import 'package:caseymobile/sepetim.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class KilifEkrani extends StatefulWidget {
  const KilifEkrani({super.key});

  @override
  State<KilifEkrani> createState() => _KilifEkraniState();
}

class _KilifEkraniState extends State<KilifEkrani> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Set<String> favoriteIds = {};

  @override
  void initState() {//favorileri basta cekmek icin
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favs = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("favorites")
        .get();

    setState(() {
      favoriteIds = favs.docs.map((e) => e.id).toSet();
    });
  }

  Future<void> toggleFavorite(String productId, Map<String, dynamic> productData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("favorites")
        .doc(productId);

    final docSnapshot = await favRef.get();

    if (docSnapshot.exists) {
      await favRef.delete();
    } else {
      await favRef.set(productData);
    }
  }
  Future<void> addToCart(String productId, Map<String, dynamic> productData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .doc(productId);

    final doc = await cartRef.get();

    if (doc.exists) {
      await cartRef.update({
        "quantity": (doc["quantity"] ?? 1) + 1,
      });
    } else {
      await cartRef.set({
        "productId": productId,
        "name": productData["name"],
        "price": productData["price"],
        "imageUrl": productData["imageUrl"],
        "quantity": 1,
        "addedAt": FieldValue.serverTimestamp(),
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final String model = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      extendBodyBehindAppBar: true,//transparanlık appbara kadar uzandı(estetik acıdan)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("$model için kılıflar"),
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

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC3A7F3), Color(0xFFE9D7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("products")
              .where("model", arrayContains: model)
              .snapshots(),

          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            return GridView.builder(
              padding: const EdgeInsets.only(top: 100, left: 12, right: 12, bottom: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: docs.length,

              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final id = doc.id;

                final bool isFavorite = favoriteIds.contains(id);

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
                        child: Stack(
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
                                onTap: () async {
                                  await toggleFavorite(id, data);

                                  setState(() {
                                    if (isFavorite) {
                                      favoriteIds.remove(id);
                                    } else {
                                      favoriteIds.add(id);
                                    }
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.purple.shade200,
                                  child: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: Colors.purple,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

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

                      const SizedBox(height: 8),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () async{
                              await addToCart(id, data);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Ürün sepete eklendi")),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB085F5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Sepete Ekle",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
