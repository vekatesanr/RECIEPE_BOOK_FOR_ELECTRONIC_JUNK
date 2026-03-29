import 'package:flutter/material.dart';
import '../models/detection_model.dart';
import '../widgets/object_detector_overlay.dart';
import '../widgets/detection_painter.dart';

/// Example: ObjectDetectorOverlay Integration with SmartScanner
/// 
/// This demonstrates how to use the overlay in your camera feed
class SmartScannerWithDetections extends StatefulWidget {
  const SmartScannerWithDetections({Key? key}) : super(key: key);

  @override
  State<SmartScannerWithDetections> createState() =>
      _SmartScannerWithDetectionsState();
}

class _SmartScannerWithDetectionsState extends State<SmartScannerWithDetections> {
  List<Detection> _detections = [];
  Size _previewSize = const Size(640, 480);

  @override
  void initState() {
    super.initState();
    // Simulate AI detection results
    _initializeMockDetections();
  }

  /// Initialize mock detections for testing
  void _initializeMockDetections() {
    _detections = [
      Detection(
        label: 'Motherboard',
        confidence: 0.95,
        rect: Rect.fromLTWH(0.1, 0.1, 0.3, 0.4),
        description: 'Motherboard with visible burn marks. CPU socket intact.',
      ),
      Detection(
        label: 'RAM',
        confidence: 0.87,
        rect: Rect.fromLTWH(0.5, 0.15, 0.2, 0.15),
        description: 'RAM module in good condition. DDR4 compatible.',
      ),
      Detection(
        label: 'SSD',
        confidence: 0.92,
        rect: Rect.fromLTWH(0.65, 0.5, 0.25, 0.2),
        description: 'SSD with minor scratches. Connector functional.',
      ),
    ];
  }

  /// Color map for different component conditions
  static const Map<String, Color> componentColorMap = {
    'motherboard': Color(0xFFFF6B6B),  // Red for damaged
    'ram': Color(0xFF4ECDC4),          // Teal for working
    'ssd': Color(0xFFFFE66D),          // Yellow for caution
    'gpu': Color(0xFF95E1D3),          // Mint
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Scanner with AI Detection'),
        backgroundColor: const Color(0xFF1e293b),
      ),
      body: Stack(
        children: [
          // Camera preview placeholder
          Container(
            color: Colors.black,
            child: Center(
              child: Text(
                'Camera Feed: ${_previewSize.width.toInt()}x${_previewSize.height.toInt()}',
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ),

          // AI Detection Overlay
          ObjectDetectorOverlay(
            detections: _detections,
            previewSize: _previewSize,
            customColorMap: componentColorMap,
            showConfidence: true,
            enableTapAnalysis: true,
            onDetectionTap: (detection) {
              debugPrint('📌 Tapped: ${detection.label} (${(detection.confidence * 100).toStringAsFixed(1)}%)');
              _showDetectionInfo(detection);
            },
            onAnalyzeSelectedComponent: (rect) {
              debugPrint('🔍 Analyzing component at: $rect');
              // Send to AI backend for detailed analysis
            },
          ),

          // Stats overlay (bottom-left)
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detections: ${_detections.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ..._detections.take(3).map((d) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '• ${d.label}: ${(d.confidence * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  )),
                ],
              ),
            ),
          ),

          // FPS and performance indicator (top-right)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '60 FPS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Action buttons (bottom-right)
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'clear',
                  onPressed: _clearDetections,
                  backgroundColor: Colors.red.withOpacity(0.7),
                  child: const Icon(Icons.clear),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'refresh',
                  onPressed: _refreshDetections,
                  backgroundColor: Colors.blue.withOpacity(0.7),
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Clear all detections
  void _clearDetections() {
    setState(() {
      _detections.clear();
    });
  }

  /// Refresh/re-run detections
  void _refreshDetections() {
    setState(() {
      _initializeMockDetections();
    });
  }

  /// Show detection details
  void _showDetectionInfo(Detection detection) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: componentColorMap[detection.label.toLowerCase()] ??
                    Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              detection.label,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confidence: ${(detection.confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Color(0xFF94a3b8)),
            ),
            const SizedBox(height: 12),
            if (detection.description != null) ...[
              const Text(
                'AI Description:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detection.description!,
                style: const TextStyle(
                  color: Color(0xFFe2e8f0),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}