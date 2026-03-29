import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';

class YoloService {
  static final YoloService _instance = YoloService._internal();
  factory YoloService() => _instance;
  YoloService._internal();

  FlutterVision? _vision;
  bool _isModelLoaded = false;

  Future<void> initialize() async {
    try {
      _vision = FlutterVision();
      await _loadModel();
    } catch (e) {
      debugPrint("Warning: YOLO Model failed to load. Did you add yolov8.tflite to assets/models? Error: $e");
    }
  }

  Future<void> _loadModel() async {
    if (_vision == null) return;
    try {
      await _vision!.loadYoloModel(
        labels: 'assets/models/labels.txt',
        modelPath: 'assets/models/yolov8.tflite',
        modelVersion: "yolov8",
        numThreads: 2,
        useGpu: false,
      );
      _isModelLoaded = true;
      debugPrint("✅ YOLOv8 Model Loaded successfully!");
    } catch (e) {
      // Catch missing file intentionally
      debugPrint('Model load exception: $e');
      rethrow;
    }
  }

  Future<String> analyzeImage(File file) async {
    if (!_isModelLoaded || _vision == null) {
      // Fallback message to guide the user since it's their first time!
      return "⚠️ YOLO Model Missing (Please add yolov8.tflite to assets/models/)";
    }

    try {
      final bytes = await file.readAsBytes();
      
      // Decode image dimensions precisely for YOLO input mapping
      final decodedImage = await decodeImageFromList(bytes);
      
      final results = await _vision!.yoloOnImage(
        bytesList: bytes,
        imageHeight: decodedImage.height,
        imageWidth: decodedImage.width,
        iouThreshold: 0.4,
        confThreshold: 0.4,
        classThreshold: 0.5,
      );

      if (results.isEmpty) {
        return "Unknown Element";
      }

      // flutter_vision typically sorts results by highest confidence automatically.
      // We grab the highest confidence tag.
      String bestLabel = "Unknown Element";
      for (var result in results) {
        if (result['tag'] != null) {
          bestLabel = result['tag'];
          break; 
        }
      }
      return bestLabel;

    } catch (e) {
      debugPrint('YOLO inference failed: $e');
      return "AI Processing Error";
    }
  }

  Future<void> dispose() async {
    if (_vision != null && _isModelLoaded) {
      await _vision!.closeYoloModel();
    }
  }
}
