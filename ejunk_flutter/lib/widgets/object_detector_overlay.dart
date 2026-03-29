import 'package:flutter/material.dart';
import '../models/detection_model.dart';
import 'detection_painter.dart';

/// High-performance ObjectDetectorOverlay widget
/// Layers detection bounding boxes over CameraPreview
/// Supports tap-to-analyze functionality
class ObjectDetectorOverlay extends StatefulWidget {
  final List<Detection> detections;
  final Size previewSize;
  final Function(Detection)? onDetectionTap;
  final Function(Rect)? onAnalyzeSelectedComponent;
  final Map<String, Color>? customColorMap;
  final bool showConfidence;
  final bool enableTapAnalysis;

  const ObjectDetectorOverlay({
    Key? key,
    required this.detections,
    required this.previewSize,
    this.onDetectionTap,
    this.onAnalyzeSelectedComponent,
    this.customColorMap,
    this.showConfidence = true,
    this.enableTapAnalysis = true,
  }) : super(key: key);

  @override
  State<ObjectDetectorOverlay> createState() => _ObjectDetectorOverlayState();
}

class _ObjectDetectorOverlayState extends State<ObjectDetectorOverlay> {
  Detection? _selectedDetection;
  late Map<String, Color> _colorMap;

  @override
  void initState() {
    super.initState();
    _colorMap = widget.customColorMap ?? DetectionPainter.defaultColorMap;
  }

  @override
  void didUpdateWidget(ObjectDetectorOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customColorMap != oldWidget.customColorMap) {
      _colorMap = widget.customColorMap ?? DetectionPainter.defaultColorMap;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTapDown: widget.enableTapAnalysis ? _handleTap : null,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: DetectionPainter(
              detections: widget.detections,
              colorMap: _colorMap,
              selectedDetection: _selectedDetection,
              showConfidence: widget.showConfidence,
            ),
            size: widget.previewSize,
          ),
        ),
      ),
    );
  }

  /// Handle tap on detection overlay
  void _handleTap(TapDownDetails details) {
    final tapPosition = details.globalPosition;

    // Find tapped detection
    Detection? tappedDetection;
    for (final detection in widget.detections) {
      final pixelRect = detection.toPixelRect(widget.previewSize);

      // Convert local coordinates to global
      final globalRect = _localToGlobalRect(pixelRect);

      if (globalRect.contains(tapPosition)) {
        tappedDetection = detection;
        break;
      }
    }

    if (tappedDetection != null) {
      setState(() {
        _selectedDetection = tappedDetection;
      });

      // Trigger callback
      widget.onDetectionTap?.call(tappedDetection);

      // Analyze selected component
      if (widget.onAnalyzeSelectedComponent != null) {
        _analyzeSelectedComponent(tappedDetection);
      }

      // Show bottom sheet with component details
      _showComponentDetailsSheet(context, tappedDetection);
    }
  }

  /// Convert local rect to global coordinates
  Rect _localToGlobalRect(Rect localRect) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return localRect;

    final globalOffset = renderBox.localToGlobal(Offset.zero);
    return localRect.shift(globalOffset);
  }

  /// Analyze selected component by sending crop to AI
  void _analyzeSelectedComponent(Detection detection) {
    final pixelRect = detection.toPixelRect(widget.previewSize);
    widget.onAnalyzeSelectedComponent?.call(pixelRect);
  }

  /// Show component details bottom sheet
  void _showComponentDetailsSheet(BuildContext context, Detection detection) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1e293b),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _colorMap[detection.label.toLowerCase()] ??
                        DetectionPainter.defaultColorMap['unknown'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detection.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confidence: ${(detection.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Color(0xFF94a3b8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (detection.description != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f172a),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  detection.description!,
                  style: const TextStyle(
                    color: Color(0xFFe2e8f0),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b981),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}