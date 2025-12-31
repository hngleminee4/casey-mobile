import 'package:caseymobile/firestorebaglan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// kullanıcı kayıt işlemleri için servisim
class UserService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> kullaniciEkleDb(UserModel user) async {
    try {
      await firestore.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "email": user.email,
        "fullname": user.fullname,
      });
    } catch (e) {
      debugPrint("kullanici olusturma hatasi: $e");
    }
  }

}

/// ürünler, sepet ve favoriler için servis
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ürünleri stream olarak çekmek için
  Stream<QuerySnapshot> getProducts() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addToCart({
    required String uid,
    required String productId,
    required int quantity,
    required double price,
    required String imageUrl,
    required String name,
  }) async {
    final cartRef = _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(productId);

    await cartRef.set({
      'productId': productId,
      'quantity': FieldValue.increment(quantity),
      'price': price,
      'imageUrl': imageUrl,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));//verileri birlestiriyo @override mantıgı
  }

  Stream<bool> isFavorite({
    required String uid,
    required String productId,
  }) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // favori butonunu aktifleşmesi ve pasifleşmesinde
  Future<void> toggleFavorite({
    required String uid,
    required String productId,
  }) async {
    final favRef = _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId);

    final doc = await favRef.get();

    if (doc.exists) {
      await favRef.delete(); // varsa siler favoriden çıkar
    } else {
      await favRef.set({
        'productId': productId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
