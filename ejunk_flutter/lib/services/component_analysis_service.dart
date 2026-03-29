import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/detection_model.dart';

/// Service for analyzing selected components with AI
class ComponentAnalysisService {
  /// Generate AI description for a cropped component image
  /// Takes a Rect in normalized coordinates and generates description
  static Future<String> analyzeSelectedComponent(
    Uint8List imageBytes,
    Rect normalizedRect,
    String componentLabel,
  ) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Crop to detection area
      final croppedImage = _cropImage(image, normalizedRect);

      // Send to AI backend for description
      final description = await _sendToAI(croppedImage, componentLabel);

      return description;
    } catch (e) {
      return 'Error analyzing component: $e';
    }
  }

  /// Crop image based on normalized rect
  static img.Image _cropImage(img.Image image, Rect normalizedRect) {
    final x = (normalizedRect.left * image.width).toInt();
    final y = (normalizedRect.top * image.height).toInt();
    final width = (normalizedRect.width * image.width).toInt();
    final height = (normalizedRect.height * image.height).toInt();

    return img.copyCrop(
      image,
      x: x.clamp(0, image.width - 1),
      y: y.clamp(0, image.height - 1),
      width: width.clamp(1, image.width - x),
      height: height.clamp(1, image.height - y),
    );
  }

  /// Send cropped image to AI backend
  static Future<String> _sendToAI(
    img.Image croppedImage,
    String componentLabel,
  ) async {
    // This would integrate with your backend API
    // For now, return mock descriptions based on component type
    return _getMockDescription(componentLabel);
  }

  /// Get mock AI descriptions for testing
  static String _getMockDescription(String label) {
    final descriptions = {
      'motherboard': 'Motherboard with visible heat damage. CPU socket appears intact. Contains gold contact pins.',
      'ram': 'RAM module in good condition. No physical damage detected. Compatible with DDR4 slots.',
      'ssd': 'Solid State Drive with wear marks. SATA connector functional. Data recovery possible.',
      'gpu': 'Graphics Processing Unit with dust accumulation. Heatsink not damaged. Core likely functional.',
      'psu': 'Power Supply Unit with corrosion signs. Capacitors may need replacement. Energy efficiency unknown.',
      'battery': 'Lithium battery with swelling detected. High risk of failure. Safe disposal recommended.',
      'screen': 'LCD screen with minor cracks on edge. Display functionality compromised. Parts salvageable.',
      'keyboard': 'Mechanical keyboard. Keys functioning normally. Minor cosmetic damage on case.',
      'network_card': 'Ethernet adapter. All connectors intact. Drivers readily available.',
    };

    final lowerLabel = label.toLowerCase();
    return descriptions[lowerLabel] ??
        'Unknown component detected. Label: $lowerLabel. Manual inspection recommended.';
  }

  /// Batch analyze multiple detections
  static Future<List<Detection>> batchAnalyze(
    Uint8List imageBytes,
    List<Detection> detections,
  ) async {
    final analyzedDetections = <Detection>[];

    for (final detection in detections) {
      final description = await analyzeSelectedComponent(
        imageBytes,
        detection.rect,
        detection.label,
      );

      analyzedDetections.add(
        Detection(
          label: detection.label,
          confidence: detection.confidence,
          rect: detection.rect,
          description: description,
        ),
      );
    }

    return analyzedDetections;
  }
}