# High-Performance Object Detection Overlay Documentation

## 🎯 Overview

This module provides a production-ready, high-performance Flutter ObjectDetectorOverlay widget that:
- Renders AI detection bounding boxes at 60 FPS
- Supports dynamic coordinate scaling
- Includes color-coded component states
- Enables tap-to-analyze functionality
- Optimized for mid-range Android devices

---

## 📦 Components

### 1. **Detection Model** (`detection_model.dart`)
Represents a single AI detection result.

```dart
class Detection {
  final String label;           // Component name (e.g., "Motherboard")
  final double confidence;      // 0.0 to 1.0
  final Rect rect;              // Normalized coordinates (0.0 to 1.0)
  final String? description;    // Optional AI-generated description
}
```

**Normalized Coordinates:**
- `rect` values are 0.0 to 1.0 (relative to image size)
- Automatically scaled to pixel coordinates by `toPixelRect(Size)`

---

### 2. **Detection Painter** (`detection_painter.dart`)
Custom painter for rendering bounding boxes with optimizations.

**Features:**
- ✅ Efficient painting with minimal repaints
- ✅ Color-coded component states
- ✅ Corner markers for small boxes
- ✅ Label + confidence display
- ✅ Selection highlighting
- ✅ Dashed rectangle for selected items

**Color Mapping (Customizable):**
```dart
const Map<String, Color> defaultColorMap = {
  'working': Color(0xFF00FF00),      // Green
  'damaged': Color(0xFFFF0000),      // Red
  'unknown': Color(0xFF0000FF),      // Blue
  'admin_review': Color(0xFFFFFF00), // Yellow
  'burnt': Color(0xFFFF6600),        // Orange
  'new': Color(0xFF00CC00),          // Light Green
};
```

---

### 3. **ObjectDetectorOverlay Widget** (`object_detector_overlay.dart`)
Main widget that layers detection boxes over camera feed with tap support.

**Key Features:**
- 🎯 Tap detection with bottom sheet details
- 📊 Real-time detection updates
- 🎨 Customizable colors
- ♿ Accessible component details
- 📱 Touch-friendly UI

---

### 4. **Component Analysis Service** (`component_analysis_service.dart`)
Analyzes selected components using AI.

**Capabilities:**
- 📸 Crops detection regions
- 🤖 Sends crops to AI backend
- 📝 Generates descriptions
- 🔄 Batch analysis support

---

## 🚀 Usage Guide

### Basic Setup

**Step 1: Create Detections**
```dart
final detections = [
  Detection(
    label: 'Motherboard',
    confidence: 0.95,
    rect: Rect.fromLTWH(0.1, 0.1, 0.3, 0.4),
  ),
  Detection(
    label: 'RAM',
    confidence: 0.87,
    rect: Rect.fromLTWH(0.5, 0.15, 0.2, 0.15),
  ),
];
```

**Step 2: Add Overlay to CameraPreview**
```dart
Stack(
  children: [
    // Camera preview
    CameraPreview(_controller),
    
    // Detection overlay
    ObjectDetectorOverlay(
      detections: detections,
      previewSize: Size(640, 480),
      customColorMap: {
        'motherboard': Colors.red,
        'ram': Colors.green,
      },
      showConfidence: true,
      enableTapAnalysis: true,
      onDetectionTap: (detection) {
        print('Tapped: ${detection.label}');
      },
      onAnalyzeSelectedComponent: (rect) {
        print('Analyze region: $rect');
      },
    ),
  ],
)
```

---

### Advanced Integration

**With AI Description Integration:**
```dart
Future<void> _runDetectionWithAnalysis() async {
  // Get detections from YOLOv8
  final yoloDetections = await YoloService().detectComponents(imageFile);
  
  // Analyze each detection
  final detections = await ComponentAnalysisService.batchAnalyze(
    imageBytes,
    yoloDetections,
  );
  
  // Update UI
  setState(() {
    _detections = detections;
  });
}
```

**Color-Coded Component Conditions:**
```dart
const Map<String, Color> componentStatusMap = {
  'working': Color(0xFF10b981),      // Green
  'damaged': Color(0xFFef4444),      // Red
  'burnt': Color(0xFF7c2d12),        // Dark Red
  'unknown': Color(0xFF6b7280),      // Gray
};
```

---

## 🎨 Customization Examples

### Custom Color Scheme
```dart
ObjectDetectorOverlay(
  detections: detections,
  previewSize: size,
  customColorMap: {
    'high_priority': Colors.red,
    'medium_priority': Colors.orange,
    'low_priority': Colors.green,
  },
)
```

### Hide Confidence Scores
```dart
ObjectDetectorOverlay(
  detections: detections,
  previewSize: size,
  showConfidence: false,
)
```

### Disable Tap Analysis
```dart
ObjectDetectorOverlay(
  detections: detections,
  previewSize: size,
  enableTapAnalysis: false,
)
```

---

## 📊 Performance Optimization

### Why 60 FPS on Mid-Range Devices?

1. **RepaintBoundary Widget**
   - Isolates CustomPaint from parent rebuilds
   - Only repaints when detections change

2. **Efficient shouldRepaint()**
   ```dart
   @override
   bool shouldRepaint(DetectionPainter oldDelegate) {
     return oldDelegate.detections != detections ||
            oldDelegate.selectedDetection != selectedDetection;
   }
   ```

3. **No Unnecessary State Updates**
   - Selection state managed locally
   - Parent widget not rebuilt on tap

4. **Optimized Painting**
   - Single paint pass per frame
   - Minimal memory allocation
   - Direct canvas drawing (no intermediate surfaces)

---

## 🔄 Coordinate Scaling

**Normalized → Pixel Coordinates:**
```dart
// AI model returns normalized (0.0-1.0) coordinates
final normalizedRect = Rect.fromLTWH(0.1, 0.1, 0.3, 0.4);

// Convert to pixel coordinates
final pixelRect = normalizedRect * Size(640, 480);
// Result: Rect.fromLTWH(64, 48, 192, 192)
```

**Example:**
```dart
Detection(
  rect: Rect.fromLTWH(0.1, 0.1, 0.3, 0.4),  // 10% left, 10% top, 30% width, 40% height
)
.toPixelRect(Size(640, 480))                  // 64, 48, 192, 192 pixels
```

---

## 🎯 Integration with SmartScanner

```dart
class SmartScanner extends StatefulWidget {
  // ... camera setup
}

class _SmartScannerState extends State<SmartScanner> {
  List<Detection> _detections = [];
  
  Future<void> _captureAndDetect() async {
    final image = await _controller.takePicture();
    
    // Run YOLO detection
    final detections = await YoloService().analyzeImage(File(image.path));
    
    setState(() {
      _detections = detections;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraPreview(_controller),
        ObjectDetectorOverlay(
          detections: _detections,
          previewSize: _controller.value.previewSize,
        ),
      ],
    );
  }
}
```

---

## 📱 UI/UX Features

### Bottom Sheet Component Details
When user taps a detection:
- Shows component label with color indicator
- Displays confidence percentage
- Shows AI-generated description
- Provides close button

### Stats Overlay
Real-time statistics:
- Total detections count
- Individual detection labels + confidence
- FPS indicator

### Action Buttons
- 🔄 Refresh detections
- 🗑️ Clear all detections
- 📷 Capture screenshot

---

## 🧪 Testing

### Mock Detections
```dart
List<Detection> generateMockDetections() {
  return [
    Detection(
      label: 'Motherboard',
      confidence: 0.95,
      rect: Rect.fromLTWH(0.1, 0.1, 0.3, 0.4),
      description: 'Motherboard with burn marks detected',
    ),
    // ... more detections
  ];
}
```

### View Demo Screen
```dart
// Navigate to example screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => SmartScannerWithDetections()),
);
```

---

## 🔧 API Reference

### ObjectDetectorOverlay

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `detections` | `List<Detection>` | - | AI detection results |
| `previewSize` | `Size` | - | Camera preview dimensions |
| `onDetectionTap` | `Function?` | null | Callback when detection tapped |
| `onAnalyzeSelectedComponent` | `Function?` | null | Callback for AI analysis |
| `customColorMap` | `Map?` | default | Custom color scheme |
| `showConfidence` | `bool` | true | Show confidence % |
| `enableTapAnalysis` | `bool` | true | Enable tap detection |

---

## 📚 Example Workflows

### Workflow 1: Scan → Detect → Analyze
1. User opens SmartScanner
2. Camera runs in real-time
3. YOLO detects components
4. Overlay shows bounding boxes
5. User taps component
6. AI generates description
7. Details shown in bottom sheet

### Workflow 2: Batch Analysis
1. Capture image
2. Run YOLO detection
3. Send all detections to AI
4. Batch analyze components
5. Update overlay with descriptions
6. User can tap any component

---

## ⚠️ Known Limitations

- Tap detection works best when overlay directly over camera
- Coordinate scaling depends on accurate `previewSize`
- Color map lookup is case-insensitive (label is lowercased)

---

## 🚀 Future Enhancements

- [ ] Real-time object tracking (persistence across frames)
- [ ] Gesture support (pinch-to-zoom on detections)
- [ ] Recording detection heatmaps
- [ ] ML model confidence filtering
- [ ] Multi-language label support

---

**Version:** 1.0.0  
**Last Updated:** March 29, 2026  
**Status:** Production Ready
