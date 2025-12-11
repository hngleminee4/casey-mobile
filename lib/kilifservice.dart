import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Marka tespiti
  String detectBrand(String model) {
    final m = model.toLowerCase();

    if (m.contains("oppo")) return "oppo";
    if (m.contains("realme")) return "realme";
    if (m.contains("redmi") || m.contains("xiaomi")) return "xiaomi";
    if (m.contains("iphone")) return "apple";
    if (m.contains("tecno")) return "tecno";
    if (m.contains("samsung") || m.contains("galaxy") || m.contains("s")) {
      return "samsung";
    }
    if (m.contains("z serisi")) return "samsung";

    return "unknown";
  }

  // Ürün ekleme
  Future<void> addCaseProduct({
    required String model,
    required String name,
    required double price,
    required String imageUrl,
  }) async {
    final brand = detectBrand(model);

    await _db.collection("products").add({
      "brand": brand,
      "model": [model],  // arrayContains için
      "name": name,
      "price": price,
      "imageUrl": imageUrl,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCasesForModel(String model) {
    return _db
        .collection("products")
        .where("model", arrayContains: model)
        .snapshots();
  }
}
