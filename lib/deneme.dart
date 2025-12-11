import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void printModelInfo() async {
  final interpreter = await Interpreter.fromAsset(
    'assets/model/best_int8.tflite',
  );

  var input = interpreter.getInputTensor(0);
  debugPrint("INPUT SHAPE: ${input.shape}");

  var output = interpreter.getOutputTensor(0);
  debugPrint("OUTPUT SHAPE: ${output.shape}");
}
