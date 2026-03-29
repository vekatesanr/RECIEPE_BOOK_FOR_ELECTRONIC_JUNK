import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firebase_service.dart';
import '../models/component_model.dart';
import '../widgets/sidebar_drawer.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _service = FirebaseService();
  final ImagePicker _picker = ImagePicker();

  final _descController = TextEditingController();
  final _originController = TextEditingController();
  final _projectController = TextEditingController();
  final _timeController = TextEditingController();

  File? _selectedImage;
  bool _isAnalyzing = false;
  String _aiResult = '';
  bool _mismatch = false;

  @override
  void dispose() {
    _descController.dispose();
    _originController.dispose();
    _projectController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (xFile != null) {
        setState(() => _selectedImage = File(xFile.path));
      }
    } catch (e) {
      _showSnack('Could not pick image: $e', isError: true);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1e293b),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const Text(
              'Select Image Source',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ImageSourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ImageSourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _runAnalysis() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      _showSnack('Please select a component image first', isError: true);
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _aiResult = '';
      _mismatch = false;
    });

    try {
      // Step 1: Upload image
      final String imageUrl =
          await _service.uploadComponentImage(_selectedImage!);

      // Step 2: Mock AI analysis (YOLOv8 placeholder)
      await Future.delayed(const Duration(seconds: 2));
      const String mockAiLabel = 'ceramic capacitor';
      final String userDesc = _descController.text.trim().toLowerCase();
      final bool hasMismatch = !userDesc.contains(mockAiLabel.split(' ').last);

      setState(() {
        _aiResult = mockAiLabel;
        _mismatch = hasMismatch;
      });

      // Step 3: Save to Firestore
      final component = ComponentModel(
        id: '',
        componentName: _descController.text.trim(),
        originSource: _originController.text.trim(),
        intendedProject: _projectController.text.trim(),
        dismantleTimeEstimate: _timeController.text.trim(),
        aiLabel: mockAiLabel,
        userDescription: _descController.text.trim(),
        imageUrl: imageUrl,
        mismatchStatus: hasMismatch,
        timestamp: DateTime.now(),
        isDismantled: false,
        adminVerified: false,
      );

      final String docId = await _service.saveComponent(component);

      if (!mounted) return;

      if (hasMismatch) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '⚠️ AI says "$mockAiLabel" but you described "${_descController.text.trim()}"',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFf59e0b),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Step 4: Success dialog
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1e293b),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10b981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10b981)),
              ),
              const SizedBox(width: 12),
              const Text('Analysis Complete',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultRow('Doc ID', docId.substring(0, 8) + '...'),
              _ResultRow('AI Label', mockAiLabel),
              _ResultRow('Status',
                  hasMismatch ? '⚠️ Mismatch' : '✅ Match'),
              _ResultRow('Saved to', 'Firestore (pending review)'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close',
                  style: TextStyle(color: Color(0xFF64748b))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/dismantle');
              },
              child: const Text('View Dismantle Guide'),
            ),
          ],
        ),
      );

      // Reset form
      _descController.clear();
      _originController.clear();
      _projectController.clear();
      _timeController.clear();
      setState(() => _selectedImage = null);
    } catch (e) {
      _showSnack('Analysis failed: $e', isError: true);
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? const Color(0xFFef4444) : const Color(0xFF10b981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(title: const Text('🔬 Component Analysis')),
      drawer: const SidebarDrawer(currentRoute: '/analysis'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedImage != null
                          ? const Color(0xFF10b981).withOpacity(0.6)
                          : const Color(0xFF334155),
                      width: 2,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined,
                                size: 48, color: Colors.grey[600]),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to capture or upload image',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Camera or Gallery',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 12),
                            ),
                          ],
                        ),
                ),
              ),

              if (_selectedImage != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.refresh_rounded,
                          size: 16, color: Color(0xFF10b981)),
                      label: const Text('Change Image',
                          style: TextStyle(
                              color: Color(0xFF10b981), fontSize: 13)),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // AI result banner
              if (_aiResult.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _mismatch
                        ? const Color(0xFFf59e0b).withOpacity(0.1)
                        : const Color(0xFF10b981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _mismatch
                          ? const Color(0xFFf59e0b).withOpacity(0.4)
                          : const Color(0xFF10b981).withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _mismatch
                            ? Icons.warning_amber_rounded
                            : Icons.psychology_rounded,
                        color: _mismatch
                            ? const Color(0xFFf59e0b)
                            : const Color(0xFF10b981),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Detection: $_aiResult',
                              style: TextStyle(
                                color: _mismatch
                                    ? const Color(0xFFf59e0b)
                                    : const Color(0xFF10b981),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_mismatch)
                              const Text(
                                'Mismatch detected between AI and your description',
                                style: TextStyle(
                                    color: Color(0xFF94a3b8), fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Form fields
              _buildField(
                controller: _descController,
                label: 'Component Description',
                hint: 'e.g. ceramic capacitor, resistor...',
                icon: Icons.edit_note_rounded,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _originController,
                label: 'Origin Source',
                hint: 'e.g. old TV motherboard, laptop...',
                icon: Icons.device_hub_rounded,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _projectController,
                label: 'Intended Project',
                hint: 'e.g. Arduino breadboard, LED circuit...',
                icon: Icons.build_circle_rounded,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _timeController,
                label: 'Dismantle Time Estimate',
                hint: 'e.g. 10 minutes, 1 hour...',
                icon: Icons.timer_outlined,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 28),

              // Submit button
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _runAnalysis,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    _isAnalyzing ? 'Running Analysis...' : 'Run AI Analysis',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10b981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF10b981), size: 20),
      ),
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0f172a),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF10b981), size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  const _ResultRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                  color: Color(0xFF64748b),
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(color: Color(0xFFe2e8f0), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
