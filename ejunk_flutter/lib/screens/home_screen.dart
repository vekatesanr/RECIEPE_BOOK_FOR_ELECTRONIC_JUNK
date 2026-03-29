import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/component_model.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/component_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _service = FirebaseService();
  String _testResult = '';
  bool _testRunning = false;

  Future<void> _runFirebaseTest() async {
    setState(() {
      _testRunning = true;
      _testResult = '';
    });
    try {
      final String docId = await _service.testFirebaseConnection();
      setState(() {
        _testResult = '✅ Connected! Doc ID: $docId';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Error: $e';
      });
    } finally {
      setState(() => _testRunning = false);
    }
  }

  Future<void> _deleteComponent(
      BuildContext context, ComponentModel comp) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('Delete Component',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${comp.componentName}"? This cannot be undone.',
          style: const TextStyle(color: Color(0xFF94a3b8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF64748b))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFef4444)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteComponent(comp.id, comp.imageUrl);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Component deleted successfully'),
              backgroundColor: Color(0xFF10b981),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: const Color(0xFFef4444),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        title: const Text('⚡ E-Junk Recipe Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_tethering_rounded),
            tooltip: 'Test Firebase',
            onPressed: _runFirebaseTest,
          ),
        ],
      ),
      drawer: const SidebarDrawer(currentRoute: '/home'),
      body: StreamBuilder<List<ComponentModel>>(
        stream: _service.getVerifiedComponents(),
        builder: (context, snapshot) {
          final components = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              // Stats header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verified components ready for salvage',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      const SizedBox(height: 16),

                      // Stats row
                      Row(
                        children: [
                          _StatCard(
                            icon: Icons.memory_rounded,
                            label: 'Total Parts',
                            value: components.length.toString(),
                            color: const Color(0xFF10b981),
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.verified_user_rounded,
                            label: 'Verified',
                            value: components
                                .where((c) => c.adminVerified)
                                .length
                                .toString(),
                            color: const Color(0xFF6366f1),
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.warning_amber_rounded,
                            label: 'Mismatches',
                            value: components
                                .where((c) => c.mismatchStatus)
                                .length
                                .toString(),
                            color: const Color(0xFFf59e0b),
                          ),
                        ],
                      ),

                      // Firebase test result
                      if (_testResult.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1e293b),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _testResult.startsWith('✅')
                                  ? const Color(0xFF10b981)
                                  : const Color(0xFFef4444),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (_testRunning)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF10b981),
                                  ),
                                ),
                              if (!_testRunning)
                                const SizedBox(width: 0),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _testRunning
                                      ? 'Testing connection...'
                                      : _testResult,
                                  style: const TextStyle(
                                    color: Color(0xFFe2e8f0),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFF1e293b)),
                      const SizedBox(height: 8),
                      const Text(
                        'Verified Components',
                        style: TextStyle(
                          color: Color(0xFF94a3b8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Components list
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF10b981),
                    ),
                  ),
                )
              else if (components.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        Text(
                          'No verified components yet',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan a component to get started',
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, index) {
                        final comp = components[index];
                        return ComponentCard(
                          component: comp,
                          onDelete: () => _deleteComponent(context, comp),
                        );
                      },
                      childCount: components.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/analysis'),
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Scan New Component'),
        backgroundColor: const Color(0xFF10b981),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748b),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
