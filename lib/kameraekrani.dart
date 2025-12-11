import 'dart:typed_data';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'main.dart';
import 'yolo.dart';

class Kameraekran extends StatefulWidget {
  const Kameraekran({super.key});

  @override
  State<Kameraekran> createState() => _KameraekranState();
}

class _KameraekranState extends State<Kameraekran> {
  CameraController? _controller;
  String? detectedModel;
  final YoloService _yoloService = YoloService();

  bool _isReady = false;
  bool _isDetecting = false;

  final int _inputW = 640;
  final int _inputH = 640;

  List<List<double>> detections = [];
  List<List<double>> _smoothDetections = [];

  @override
  void initState() {
    super.initState();
    _loadModelAndCamera();
  }

  Future<void> _loadModelAndCamera() async {
    await _yoloService.loadModel();
    await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.low,
        enableAudio: false,
      );

      await _controller!.initialize();

      _controller!.startImageStream((CameraImage image) async {
        if (_isDetecting) return;

        _isDetecting = true;
        await _processFrame(image);
        _isDetecting = false;
      });

      if (!mounted) return;
      setState(() => _isReady = true);
    } catch (e) {
      debugPrint("❌ KAMERA HATASI: $e");
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      final Float32List input = _convertImage(image);

      final rawDetections = _yoloService.runDirect(
        input,
        _inputH,
        _inputW,
      );

      if (!mounted) return;

      setState(() {
        detections = rawDetections;

        if (detections.isNotEmpty) {
          // En yüksek güven skorlu olanı seç
          detections.sort((a, b) => b[4].compareTo(a[4]));
          final best = detections.first;

          final classIndex = best[5].toInt();
          detectedModel = yoloClasses[classIndex];


          debugPrint("📱 ALGILANAN MODEL: $detectedModel");
        }
      });
      bool _navigated = false;
      if (detectedModel != null && !_navigated) {
        _navigated = true;

        _controller?.stopImageStream(); // Kamera akışını durdur
        _controller?.dispose();

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/kiliflar',
            arguments: detectedModel,
          );
        }
      }


      debugPrint("✅ CANLI DETECTION: ${detections.length}");
    } catch (e) {
      debugPrint("❌ YOLO FRAME HATASI: $e");
    }
  }


  Float32List _convertImage(CameraImage image) {
    final img.Image rgb = img.Image(
      width: image.width,
      height: image.height,
    );

    final Plane yPlane = image.planes[0];
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final int yp =
        yPlane.bytes[y * yPlane.bytesPerRow + x * yPlane.bytesPerPixel!];

        final int uvIndex =
            (y ~/ 2) * uPlane.bytesPerRow + (x ~/ 2) * uPlane.bytesPerPixel!;

        final int up = uPlane.bytes[uvIndex];
        final int vp = vPlane.bytes[uvIndex];

        int r = (yp + 1.402 * (vp - 128)).round().clamp(0, 255);
        int g = (yp - 0.34414 * (up - 128) - 0.71414 * (vp - 128))
            .round()
            .clamp(0, 255);
        int b = (yp + 1.772 * (up - 128)).round().clamp(0, 255);

        rgb.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    // ✅ ANDROID 90 DERECE DÖNÜK GELİR → DÜZELT
    final img.Image rotated = img.copyRotate(rgb, angle: 90);

    // ✅ MODELE UYUMLU 640x640
    final img.Image resized =
    img.copyResize(rotated, width: _inputW, height: _inputH);

    final Uint8List bytes =
    Uint8List.fromList(resized.getBytes(order: img.ChannelOrder.rgb));

    final Float32List input = Float32List(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      input[i] = bytes[i] / 255.0;
    }

    return input;
  }


  @override
  void dispose() {
    _controller?.dispose();
    _yoloService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/GirisyapEkran');
            },
            child: const Text("Çıkış Yap"),
          ),
        ],
      ),
      body: _isReady && _controller != null
          ? Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          Positioned.fill(
            child: CustomPaint(
              painter: YoloPainter(detections, _inputW, _inputH),
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

// ---------------------------------------------------
// ✅ YoloPainter SINIFI – BUNU KESİNLİKLE TUTMAN LAZIM
class YoloPainter extends CustomPainter {
  final List<List<double>> detections;
  final int inputW;
  final int inputH;

  YoloPainter(this.detections, this.inputW, this.inputH);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    final double scaleX = size.width / inputW;
    final double scaleY = size.height / inputH;

    for (var d in detections) {
      final x1 = d[0] * scaleX;
      final y1 = d[1] * scaleY;
      final x2 = d[2] * scaleX;
      final y2 = d[3] * scaleY;

      final confidence = d[4];
      final classIndex = d[5].toInt();
      final className = yoloClasses[classIndex];

      canvas.drawRect(Rect.fromLTRB(x1, y1, x2, y2), paint);

      textPainter.text = TextSpan(
        text: "$className ${(confidence * 100).toStringAsFixed(1)}%",
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(x1, y1 - 18));
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
