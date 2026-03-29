import 'package:flutter/material.dart';
import '../models/detection_model.dart';

/// High-performance painter for drawing detection bounding boxes
/// Optimized for 60FPS rendering on mid-range Android devices
class DetectionPainter extends CustomPainter {
  final List<Detection> detections;
  final Map<String, Color> colorMap;
  final Detection? selectedDetection;
  final bool showConfidence;

  DetectionPainter({
    required this.detections,
    required this.colorMap,
    this.selectedDetection,
    this.showConfidence = true,
  });

  /// Color mapping for component states
  static const Map<String, Color> defaultColorMap = {
    'working': Color(0xFF00FF00),      // Green
    'damaged': Color(0xFFFF0000),      // Red
    'unknown': Color(0xFF0000FF),      // Blue
    'admin_review': Color(0xFFFFFF00), // Yellow
    'burnt': Color(0xFFFF6600),        // Orange
    'new': Color(0xFF00CC00),          // Light Green
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;

    // Draw all detections
    for (final detection in detections) {
      _drawBoundingBox(canvas, size, detection);
    }

    // Highlight selected detection
    if (selectedDetection != null) {
      _drawSelectedHighlight(canvas, size, selectedDetection!);
    }
  }

  /// Draw individual bounding box with label and confidence
  void _drawBoundingBox(Canvas canvas, Size size, Detection detection) {
    final pixelRect = detection.toPixelRect(size);
    final color = _getColorForLabel(detection.label);

    // Main bounding box outline
    final boxPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawRect(pixelRect, boxPaint);

    // Draw corner markers (more visible on small boxes)
    _drawCornerMarkers(canvas, pixelRect, color);

    // Draw label and confidence background
    _drawLabelBackground(canvas, pixelRect, detection, color);
  }

  /// Get color based on component label
  Color _getColorForLabel(String label) {
    final lowerLabel = label.toLowerCase();

    // Check custom color map
    if (colorMap.containsKey(lowerLabel)) {
      return colorMap[lowerLabel]!;
    }

    // Fallback to default map
    if (defaultColorMap.containsKey(lowerLabel)) {
      return defaultColorMap[lowerLabel]!;
    }

    // Default to blue for unknown
    return defaultColorMap['unknown']!;
  }

  /// Draw corner markers for better visibility on small boxes
  void _drawCornerMarkers(Canvas canvas, Rect rect, Color color) {
    final cornerSize = 8.0;
    final cornerPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Top-left
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerSize, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + cornerSize),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - cornerSize, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerSize),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerSize, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - cornerSize),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - cornerSize, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerSize),
      cornerPaint,
    );
  }

  /// Draw label and confidence text with background
  void _drawLabelBackground(
    Canvas canvas,
    Rect rect,
    Detection detection,
    Color color,
  ) {
    final text =
        '${detection.label}${showConfidence ? ' ${(detection.confidence * 100).toStringAsFixed(0)}%' : ''}';

    // Text painter for label
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black54,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Background for text
    final textBgRect = Rect.fromLTWH(
      rect.left,
      rect.top - textPainter.height - 4,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    final bgPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawRect(textBgRect, bgPaint);

    // Draw text
    textPainter.paint(canvas, Offset(rect.left + 4, rect.top - textPainter.height - 2));
  }

  /// Draw highlight for selected detection
  void _drawSelectedHighlight(Canvas canvas, Size size, Detection detection) {
    final pixelRect = detection.toPixelRect(size);
    final highlightPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.5)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw dashed rectangle
    _drawDashedRect(canvas, pixelRect.inflate(5), highlightPaint);
  }

  /// Draw dashed rectangle
  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 5.0;

    // Top line
    for (double x = rect.left; x < rect.right; x += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(x, rect.top),
        Offset((x + dashWidth).clamp(rect.left, rect.right), rect.top),
        paint,
      );
    }

    // Right line
    for (double y = rect.top; y < rect.bottom; y += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(rect.right, y),
        Offset(rect.right, (y + dashWidth).clamp(rect.top, rect.bottom)),
        paint,
      );
    }

    // Bottom line
    for (double x = rect.right; x > rect.left; x -= dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(x, rect.bottom),
        Offset((x - dashWidth).clamp(rect.left, rect.right), rect.bottom),
        paint,
      );
    }

    // Left line
    for (double y = rect.bottom; y > rect.top; y -= dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.left, (y - dashWidth).clamp(rect.top, rect.bottom)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DetectionPainter oldDelegate) {
    // Repaint only if detections or selection changed
    return oldDelegate.detections != detections ||
        oldDelegate.selectedDetection != selectedDetection;
  }

  @override
  bool shouldRebuildSemantics(DetectionPainter oldDelegate) => false;
}