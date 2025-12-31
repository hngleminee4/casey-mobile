import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
const List<String> yoloClasses = [
  'Oppo A60',
  'Oppo Reno 11F',
  'Realme C61',
  'Realme C65',
  'Realme GT6',
  'Redmi 13',
  'Redmi 13C',
  'Redmi 14C',
  'Redmi Note 13',
  'Redmi Note 14',
  'Redmi Note 14 Pro 5G',
  'Tecno Spark 20 Pro Plus',
  'Tecno Spark 30C',
  'iphone 11-12',
  'iphone 13-14-15',
  'iphone 16',
  'iphone pro',
  'redmi note 10',
  'redmi note 10 pro',
  'redmi note 10 pro 5G',
  's21 serisi',
  's25 edge',
  'samsung A12-A22-M12-M32',
  'samsung S24-M14 5g',
  'samsung galaxy A02-A20-A30',
  'samsung galaxy A02s-M21',
  'samsung galaxy A04-A05',
  'samsung galaxy A11',
  'samsung galaxy A13',
  'samsung galaxy A17-A26-A36-A56',
  'samsung galaxy A20s-A50-A70',
  'samsung galaxy A21',
  'samsung galaxy A23-A32-A33-A52-A53-A72-A73',
  'samsung galaxy A31',
  'samsung galaxy A51-A71',
  'samsung galaxy A7',
  'samsung galaxy A9',
  'samsung galaxy S10',
  'samsung galaxy S20',
  'samsung galaxy S8',
  'samsung galaxy S9',
  'samsung m13-m23',
  'samsung m31',
  'samsung m51',
  'tecno camon 20 pro',
  'uyumlular',
  'xiaomi mi 15',
  'xiaomi mi 15t',
  'xiaomi mi 15t pro',
  'z serisi',
];

List<double> _toCorners(List<double> box, int inputW, int inputH) {
  final cx = box[0] * inputW;
  final cy = box[1] * inputH;
  final w = box[2] * inputW;
  final h = box[3] * inputH;

  return [
    cx - w / 2,
    cy - h / 2,
    cx + w / 2,
    cy + h / 2,
    box[4],
    box[5],
  ];
}

double _iou(List<double> a, List<double> b) {
  final interX1 = max(a[0], b[0]);
  final interY1 = max(a[1], b[1]);
  final interX2 = min(a[2], b[2]);
  final interY2 = min(a[3], b[3]);

  final interArea = max(0, interX2 - interX1) * max(0, interY2 - interY1);

  final areaA = (a[2] - a[0]) * (a[3] - a[1]);
  final areaB = (b[2] - b[0]) * (b[3] - b[1]);


  return interArea / (areaA + areaB - interArea + 1e-6);
}

List<List<double>> _nonMaxSuppression(List<List<double>> boxes, double iouThreshold) {
  boxes.sort((a, b) => b[4].compareTo(a[4]));
  List<List<double>> selected = [];

  while (boxes.isNotEmpty) {
    final current = boxes.removeAt(0);
    selected.add(current);
    boxes.removeWhere((b) => _iou(current, b) > iouThreshold);
  }

  return selected;
}

class YoloService {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/model/best_int8.tflite',
      options: InterpreterOptions()
        ..threads = 4,
    );

    debugPrint("YOLO Model Yüklendi");
    debugPrint("INPUT SHAPE : ${_interpreter
        .getInputTensor(0)
        .shape}");
    debugPrint("OUTPUT SHAPE: ${_interpreter
        .getOutputTensor(0)
        .shape}");
  }
  List<List<double>> runDirect(
      Float32List input,
      int inputH,
      int inputW,
      ) {
    final inputTensor = input.reshape([1, inputH, inputW, 3]);

    final outputShape = _interpreter.getOutputTensor(0).shape;
    final int c = outputShape[1];
    final int n = outputShape[2];

    final output = List.generate(
      1,
          (_) => List.generate(c, (_) => List.filled(n, 0.0)),
    );

    _interpreter.run(inputTensor, output);

    final rawDetections = List.generate(
      n,
          (i) => List.generate(c, (j) => output[0][j][i]),
    );

    List<List<double>> boxes = [];

    for (var d in rawDetections) {
      double bestScore = 0;
      int bestClass = -1;

      for (int i = 4; i < c; i++) {
        if (d[i] > bestScore) {
          bestScore = d[i];
          bestClass = i - 4;
        }
      }

      if (bestScore < 0.55) continue;

      boxes.add([d[0], d[1], d[2], d[3], bestScore, bestClass.toDouble()]);
    }

    final cornerBoxes =
    boxes.map((box) => _toCorners(box, inputW, inputH)).toList();

    return _nonMaxSuppression(cornerBoxes, 0.45);
  }

  Future<List<List<double>>> runOnIsolate(Float32List input,
      int inputH,
      int inputW,) async {
    final response = await compute(_yoloIsolate, {
      "address": _interpreter.address,
      "input": input,
      "inputH": inputH,
      "inputW": inputW,
      "conf_threshold": 0.45, // güven eşiği
      "iou_threshold": 0.45,//iki kutunun kesisim oranı.bu eşikten büyükse algılananı atıyo
    });

    return response;
  }
  void close() {
    _interpreter.close();
  }

  static List<List<double>> _yoloIsolate(Map<String, dynamic> data) {
    final Interpreter interpreter = Interpreter.fromAddress(data["address"]);

    final Float32List input = data["input"];
    final int inputH = data["inputH"];
    final int inputW = data["inputW"];
    final double confThreshold = data["conf_threshold"];
    final double iouThreshold = data["iou_threshold"];

    final inputTensor = input.reshape([1, inputH, inputW, 3]);

    final outputShape = interpreter.getOutputTensor(0).shape;
    final int c = outputShape[1];
    final int n = outputShape[2];

    final output = List.generate(
      1,
          (_) => List.generate(c, (_) => List.filled(n, 0.0)),
    );

    interpreter.run(inputTensor, output);

    final rawDetections = List.generate(
      n,
          (i) => List.generate(c, (j) => output[0][j][i]),
    );

    List<List<double>> boxes = [];

    for (var d in rawDetections) {
      final double cx = d[0];
      final double cy = d[1];
      final double w  = d[2];
      final double h  = d[3];

      double bestScore = 0;
      int bestClass = -1;

      for (int i = 4; i < c; i++) {
        if (d[i] > bestScore) {
          bestScore = d[i];
          bestClass = i - 4;
        }
      }

      if (bestScore < confThreshold) continue;

      final String label = yoloClasses[bestClass];

      if (!label.toLowerCase().contains("iphone") &&
          !label.toLowerCase().contains("samsung") &&
          !label.toLowerCase().contains("redmi") &&
          !label.toLowerCase().contains("xiaomi") &&
          !label.toLowerCase().contains("oppo") &&
          !label.toLowerCase().contains("realme") &&
          !label.toLowerCase().contains("tecno")) {
        continue;
      }

      boxes.add([cx, cy, w, h, bestScore, bestClass.toDouble()]);
    }

    final cornerBoxes =
    boxes.map((box) => _toCorners(box, inputW, inputH)).toList();

    final finalBoxes = _nonMaxSuppression(cornerBoxes, iouThreshold);

    return finalBoxes;
  }

}