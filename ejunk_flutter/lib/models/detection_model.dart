import 'package:flutter/painting.dart';

/// Detection model to hold AI inference results
class Detection {
  final String label;
  final double confidence;
  final Rect rect; // Normalized coordinates (0.0 to 1.0)
  final String? description;

  Detection({
    required this.label,
    required this.confidence,
    required this.rect,
    this.description,
  });

  /// Convert normalized rect to pixel coordinates
  Rect toPixelRect(Size canvasSize) {
    return Rect.fromLTWH(
      rect.left * canvasSize.width,
      rect.top * canvasSize.height,
      rect.width * canvasSize.width,
      rect.height * canvasSize.height,
    );
  }
}