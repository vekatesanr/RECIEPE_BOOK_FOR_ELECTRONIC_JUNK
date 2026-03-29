import 'package:flutter/material.dart';
import '../models/component_model.dart';
import 'package:intl/intl.dart';

class ComponentCard extends StatelessWidget {
  final ComponentModel component;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ComponentCard({
    super.key,
    required this.component,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: component.mismatchStatus
              ? const Color(0xFFf59e0b).withOpacity(0.4)
              : const Color(0xFF334155),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              if (component.imageUrl != null && component.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: Image.network(
                    component.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, _) => Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0f172a),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded,
                            color: Color(0xFF334155), size: 30),
                      ),
                    ),
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 160,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0f172a),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                            color: const Color(0xFF10b981),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            component.componentName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Status badges
                        if (component.adminVerified)
                          _Badge('✅ Verified', const Color(0xFF10b981)),
                        if (component.mismatchStatus) ...[
                          const SizedBox(width: 6),
                          _Badge('⚠️ Mismatch', const Color(0xFFf59e0b)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Info rows
                    _InfoRow(
                      icon: Icons.psychology_rounded,
                      label: 'AI Label',
                      value: component.aiLabel,
                      valueColor: const Color(0xFF10b981),
                    ),
                    _InfoRow(
                      icon: Icons.device_hub_rounded,
                      label: 'From',
                      value: component.originSource,
                    ),
                    _InfoRow(
                      icon: Icons.build_circle_rounded,
                      label: 'Project',
                      value: component.intendedProject,
                    ),
                    _InfoRow(
                      icon: Icons.timer_outlined,
                      label: 'Dismantle',
                      value: component.dismantleTimeEstimate,
                    ),

                    const SizedBox(height: 12),

                    // Footer
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm')
                              .format(component.timestamp),
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 11),
                        ),
                        const Spacer(),
                        if (onDelete != null)
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFef4444).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      const Color(0xFFef4444).withOpacity(0.3),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete_outline_rounded,
                                      size: 14, color: Color(0xFFef4444)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Color(0xFFef4444),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
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
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

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
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF64748b)),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style:
                const TextStyle(color: Color(0xFF64748b), fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? const Color(0xFFcbd5e1),
                fontSize: 12,
                fontWeight: valueColor != null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
