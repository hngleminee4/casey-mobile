import 'package:flutter/material.dart';
import 'package:caseymobile/kilifservice.dart';

class UrunEkleEkrani extends StatefulWidget {
  const UrunEkleEkrani({super.key});

  @override
  State<UrunEkleEkrani> createState() => _UrunEkleEkraniState();
}

class _UrunEkleEkraniState extends State<UrunEkleEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _modelCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  final _productService = ProductService();

  @override
  void dispose() {
    _modelCtrl.dispose();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final model = _modelCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final imageUrl = _imageUrlCtrl.text.trim();

    await _productService.addCaseProduct(
      model: model,
      name: name,
      price: price,
      imageUrl: imageUrl,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Kılıf kaydedildi")),
    );

    _nameCtrl.clear();
    _priceCtrl.clear();
    _imageUrlCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Kılıf Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _modelCtrl,
                decoration: const InputDecoration(
                  labelText: "Model (Örn: Oppo A60)",
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? "Model gerekli" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Kılıf adı",
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? "Kılıf adı gerekli" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: "Fiyat (örn: 139.9)",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(
                  labelText: "Resim URL (Firebase Storage linki)",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text("Kaydet"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
