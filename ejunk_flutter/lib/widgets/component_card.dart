import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/junk_component.dart';

class ComponentCard extends StatelessWidget {
  final JunkComponent component;
  final List<String> compatibleParts;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ComponentCard({
    super.key,
    required this.component,
    this.compatibleParts = const [],
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Integrated Description: AI Title + User context
    final String integratedTitle = "${component.aiLabel}: ${component.userDamageDesc}";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: component.isVerified
              ? const Color(0xFF10b981).withOpacity(0.5)
              : const Color(0xFF334155),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: _buildImage(component.imageUrl),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Integrated Heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            integratedTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (component.isVerified)
                          _Badge(label: 'VERIFIED', color: const Color(0xFF10b981)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // AI PROJECT SECTION
                    _InfoRow(
                      icon: Icons.auto_awesome,
                      label: 'INTEGRATED PROJECT',
                      value: component.aiSuggestedProject,
                      valueColor: const Color(0xFFfbbf24),
                    ),

                    // COMPATIBLE PARTS SECTION
                    if (compatibleParts.isNotEmpty)
                      _InfoRow(
                        icon: Icons.hub_outlined,
                        label: 'COMPATIBLE WITH',
                        value: compatibleParts.join(', '),
                        valueColor: const Color(0xFFa78bfa), // Purple for compatibility
                      ),

                    // DISMANTLE TIME SECTION
                    _InfoRow(
                      icon: Icons.timer_outlined,
                      label: 'PROCESS TIME',
                      value: component.dismantleTime,
                      valueColor: const Color(0xFF60a5fa),
                    ),

                    const Divider(color: Color(0xFF334155), height: 32),

                    // ACTIONS SECTION
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/dismantle'),
                            icon: const Icon(Icons.menu_book_rounded, size: 16),
                            label: const Text("VIEW RECIPE"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10b981).withOpacity(0.1),
                              foregroundColor: const Color(0xFF10b981),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFF10b981), width: 1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFf87171)),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFf87171).withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // High-performance image loader (Handles Base64 and Network)
  Widget _buildImage(String url) {
    if (url.isEmpty) return _errorPlaceholder();

    return url.startsWith('data:image')
        ? Image.memory(
            base64Decode(url.split(',').last),
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _errorPlaceholder(),
          )
        : Image.network(
            url,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _errorPlaceholder(),
          );
  }

  Widget _errorPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFF0f172a),
      child: const Icon(Icons.inventory_2_outlined, color: Colors.white24, size: 40),
    );
  }
}

// Sub-widget for Info Rows
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94a3b8)),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: valueColor ?? Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// Sub-widget for Badges
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}