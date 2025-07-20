import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

class Classifier {
  late Interpreter _interpreter;
  late List<String> _labels;

  static const int _inputSize = 224;
  static const int _numChannels = 3;
  static const int _numClasses = 6; // 5 genus + 1 non-anggrek

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      _labels = await _loadLabels('assets/labels.txt');
    } catch (e) {
      debugPrint('Gagal memuat model: \$e');
    }
  }

  Future<List<String>> _loadLabels(String path) async {
    try {
      String data = await rootBundle.loadString(path);
      // Pastikan labels.txt memiliki 6 baris (5 genus + 1 non-anggrek)
      return data.split('\n').where((line) => line.trim().isNotEmpty).toList();
    } catch (e) {
      debugPrint('Gagal memuat labels: \$e');
      return [];
    }
  }

  Future<Map<String, dynamic>> classifyImage(File image) async {
    final bytes = await image.readAsBytes();
    final imageInput = img.decodeImage(bytes)!;
    final resized = img.copyResize(imageInput, width: _inputSize, height: _inputSize);

    // Normalisasi piksel ke rentang [0,1]
    final inputBytes = Float32List(_inputSize * _inputSize * _numChannels);
    int idx = 0;
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        inputBytes[idx++] = img.getRed(pixel) / 255.0;
        inputBytes[idx++] = img.getGreen(pixel) / 255.0;
        inputBytes[idx++] = img.getBlue(pixel) / 255.0;
      }
    }

    // Bentuk ulang ke bentuk [1, 224, 224, 3]
    final input = inputBytes.reshape([1, _inputSize, _inputSize, _numChannels]);

    // Ubah output buffer jadi 6 kelas
    final output = List.filled(_numClasses, 0.0).reshape([1, _numClasses]);

    _interpreter.run(input, output);
    final probs = List<double>.from(output[0]);
    double maxProb = probs.reduce((a, b) => a > b ? a : b);
    int predIndex = probs.indexOf(maxProb);
    String label = (_labels.isNotEmpty && predIndex < _labels.length)
        ? _labels[predIndex]
        : 'Unknown';

    return {
      'label': label,
      'index': predIndex,
      'probs': probs,
      'maxProb': maxProb,
    };
  }
}
