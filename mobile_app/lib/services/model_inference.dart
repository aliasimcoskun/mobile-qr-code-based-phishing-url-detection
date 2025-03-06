// lib/services/model_inference.dart

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

/*
 * ModelInference class
 * 
 * This class is used to load a TFLite model and perform inference on it.
 * The model is loaded from the assets folder and stored in memory.
 * The class provides a method to perform inference on a set of features.
 * 
 * Example usage:
 * await ModelInference.instance.loadModel();
 * final prediction = await ModelInference.instance.predictUrlFeatures(features);
 * print(prediction);
 * 
 */
class ModelInference {
  // Singleton Pattern
  ModelInference._privateConstructor();
  static final ModelInference instance = ModelInference._privateConstructor();

  Interpreter? _interpreter;

  /*
   * loadModel method
   * 
   * This method loads the TFLite model from the assets folder.
   * The model is stored in memory and can be used for inference.
   * 
   * Example usage:
   * await ModelInference.instance.loadModel();
   * 
   */
  Future<void> loadModel() async {
    if (_interpreter != null) {
      // Model already loaded
      return;
    }
    try {
      // 1) Read model.tflite as ByteData
      ByteData rawModelData = await rootBundle.load('assets/model.tflite');

      // 2) Convert ByteData to Uint8List
      final Uint8List modelBytes = rawModelData.buffer.asUint8List(
        rawModelData.offsetInBytes,
        rawModelData.lengthInBytes,
      );

      // 3) Load model from buffer
      _interpreter = await Interpreter.fromBuffer(modelBytes);
      print("[INFO] Model loaded from buffer successfully!");
    } catch (e) {
      print("[ERROR] Failed to load model: $e");
    }
  }

  bool get isModelReady => _interpreter != null;

  /*
   * predictUrlFeatures method
   * 
   * This method takes a list of features and performs inference on the model.
   * The model predicts the probability of a URL being malicious based on the features.
   * 
   * Parameters:
   * - features: A list of 9 features extracted from the URL
   * 
   * Returns:
   * - The predicted probability of the URL being malicious
   * 
   * Example usage:
   * final prediction = await ModelInference.instance.predictUrlFeatures(features);
   * print(prediction);
   * 
   */
  Future<double> predictUrlFeatures(List<double> features) async {
    await loadModel();
    if (_interpreter == null) {
      return -1.0; // Error case
    }

    // Input shape: [1, 9]
    var input = [features];
    var output = List.generate(1, (_) => List.filled(1, 0.0));

    try {
      _interpreter!.run(input, output);
      double prob = output[0][0];
      return prob;
    } catch (e) {
      print("[ERROR] Inference failed: $e");
      return -1.0;
    }
  }
}
