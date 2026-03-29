  import 'package:flutter/material.dart';

class SidebarDrawer extends StatelessWidget {
  final String currentRoute;

  const SidebarDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1e293b),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF10b981).withOpacity(0.15),
                    const Color(0xFF065f46).withOpacity(0.1),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF10b981).withOpacity(0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10b981).withOpacity(0.15),
                      border: Border.all(
                        color: const Color(0xFF10b981).withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Text('⚡', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Electronic Junk',
                    style: TextStyle(
                      color: Color(0xFF10b981),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    'Recipe Book',
                    style: TextStyle(
                      color: Color(0xFF64748b),
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Nav items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                children: [
                  _NavItem(
                    emoji: '🏠',
                    label: 'Home',
                    route: '/home',
                    currentRoute: currentRoute,
                  ),
                  _NavItem(
                    emoji: '🔬',
                    label: 'Analysis',
                    route: '/analysis',
                    currentRoute: currentRoute,
                  ),
                  _NavItem(
                    emoji: '🔧',
                    label: 'Dismantle Guide',
                    route: '/dismantle',
                    currentRoute: currentRoute,
                  ),
                  _NavItem(
                    emoji: '🛡️',
                    label: 'Developer Panel',
                    route: '/developer',
                    currentRoute: currentRoute,
                  ),
                  _NavItem(
                    emoji: 'ℹ️',
                    label: 'About',
                    route: '/about',
                    currentRoute: currentRoute,
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFF334155), height: 1),
                  const SizedBox(height: 8),
                  _NavItem(
                    emoji: '🔥',
                    label: 'Firebase Test',
                    route: '/home',
                    currentRoute: currentRoute,
                    isSecondary: true,
                    onTapOverride: (ctx) async {
                      Navigator.pop(ctx);
                      // Navigate home and trigger test
                      Navigator.pushReplacementNamed(ctx, '/home');
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF334155)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF10b981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Firebase Connected',
                      style:
                          TextStyle(color: Color(0xFF64748b), fontSize: 12),
                    ),
                  ),
                  const Text(
                    'v1.0.0',
                    style: TextStyle(
                        color: Color(0xFF334155), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String route;
  final String currentRoute;
  final bool isSecondary;
  final void Function(BuildContext)? onTapOverride;

  const _NavItem({
    required this.emoji,
    required this.label,
    required this.route,
    required this.currentRoute,
    this.isSecondary = false,
    this.onTapOverride,
  });

  bool get _isActive => currentRoute == route && !isSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (onTapOverride != null) {
              onTapOverride!(context);
              return;
            }
            Navigator.pop(context);
            if (currentRoute != route) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _isActive
                  ? const Color(0xFF10b981).withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: _isActive
                  ? Border.all(
                      color: const Color(0xFF10b981).withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: _isActive
                        ? const Color(0xFF10b981)
                        : isSecondary
                            ? const Color(0xFF64748b)
                            : const Color(0xFFcbd5e1),
                    fontSize: 15,
                    fontWeight: _isActive
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (_isActive) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF10b981),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
