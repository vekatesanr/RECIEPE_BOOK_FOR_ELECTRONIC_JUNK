import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SmartScanner extends StatefulWidget {
  final Function(File, String) onCapture; // Returns captured image and AI detected label
  final bool checkMismatch;
  final String? userDescription;

  const SmartScanner({
    super.key,
    required this.onCapture,
    this.checkMismatch = false,
    this.userDescription,
  });

  @override
  _SmartScannerState createState() => _SmartScannerState();
}

class _SmartScannerState extends State<SmartScanner> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No camera available')),
          );
        }
        return;
      }
      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );
      _initializeControllerFuture = _controller.initialize();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;
    
    try {
      setState(() => _isCapturing = true);
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final imageFile = File(image.path);

      if (mounted) {
        // Return to previous screen with captured image
        Navigator.pop(context, imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture error: $e')),
        );
      }
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Smart Scanner'),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                // Custom SVG bounding box overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: BoundingBoxPainter(),
                  ),
                ),
                // Bottom capture button
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isCapturing ? null : _captureImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: _isCapturing ? Colors.grey : Colors.white24,
                        ),
                        child: _isCapturing
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Icon(Icons.camera,
                                color: Colors.white, size: 40),
                      ),
                    ),
                  ),
                ),
                // Instructions
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Align component inside the box',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final boxWidth = width * 0.8;
    final boxHeight = height * 0.6;
    final left = (width - boxWidth) / 2;
    final top = (height - boxHeight) / 2;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw dashed rectangle
    _drawDashedRect(
      canvas,
      Rect.fromLTWH(left, top, boxWidth, boxHeight),
      dashPaint,
    );

    // Draw corner markers
    final cornerSize = 30.0;
    final cornerPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Top-left corner
    canvas.drawLine(Offset(left, top), Offset(left + cornerSize, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerSize), cornerPaint);

    // Top-right corner
    canvas.drawLine(
        Offset(left + boxWidth, top), Offset(left + boxWidth - cornerSize, top), cornerPaint);
    canvas.drawLine(
        Offset(left + boxWidth, top), Offset(left + boxWidth, top + cornerSize), cornerPaint);

    // Bottom-left corner
    canvas.drawLine(Offset(left, top + boxHeight),
        Offset(left + cornerSize, top + boxHeight), cornerPaint);
    canvas.drawLine(Offset(left, top + boxHeight),
        Offset(left, top + boxHeight - cornerSize), cornerPaint);

    // Bottom-right corner
    canvas.drawLine(Offset(left + boxWidth, top + boxHeight),
        Offset(left + boxWidth - cornerSize, top + boxHeight), cornerPaint);
    canvas.drawLine(Offset(left + boxWidth, top + boxHeight),
        Offset(left + boxWidth, top + boxHeight - cornerSize), cornerPaint);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 5.0;
    double currentX = rect.left;
    double currentY = rect.top;

    // Top line
    while (currentX < rect.right) {
      canvas.drawLine(Offset(currentX, currentY),
          Offset((currentX + dashWidth).clamp(0, rect.right), currentY), paint);
      currentX += dashWidth + dashSpace;
    }

    // Right line
    currentX = rect.right;
    currentY = rect.top;
    while (currentY < rect.bottom) {
      canvas.drawLine(Offset(currentX, currentY),
          Offset(currentX, (currentY + dashWidth).clamp(0, rect.bottom)), paint);
      currentY += dashWidth + dashSpace;
    }

    // Bottom line
    currentX = rect.right;
    currentY = rect.bottom;
    while (currentX > rect.left) {
      canvas.drawLine(Offset(currentX, currentY),
          Offset((currentX - dashWidth).clamp(rect.left, double.infinity), currentY), paint);
      currentX -= dashWidth + dashSpace;
    }

    // Left line
    currentX = rect.left;
    currentY = rect.bottom;
    while (currentY > rect.top) {
      canvas.drawLine(Offset(currentX, currentY),
          Offset(currentX, (currentY - dashWidth).clamp(rect.top, double.infinity)), paint);
      currentY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}