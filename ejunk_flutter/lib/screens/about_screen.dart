import 'package:flutter/material.dart';
import '../widgets/sidebar_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(title: const Text('ℹ️ About')),
      drawer: const SidebarDrawer(currentRoute: '/about'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App hero banner
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1e293b),
                    const Color(0xFF10b981).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF10b981).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10b981).withOpacity(0.1),
                      border: Border.all(
                        color: const Color(0xFF10b981).withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                        child:
                            Text('⚡', style: TextStyle(fontSize: 38))),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Electronic Junk Recipe Book',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Version 1.0.0',
                    style:
                        TextStyle(color: Color(0xFF10b981), fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: const Color(0xFF334155),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'An AI-powered mobile application that helps makers, hobbyists, and students identify, catalog, and safely dismantle electronic components recovered from e-waste.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF94a3b8),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Mission statement
            _SectionCard(
              icon: '🎯',
              title: 'Our Mission',
              child: const Text(
                'Reduce electronic waste by empowering users to salvage and repurpose components. Every circuit board has a second life — we help you find it.\n\nThrough AI-assisted identification and community-verified dismantling guides, we make e-waste recycling accessible, safe, and educational.',
                style: TextStyle(
                    color: Color(0xFF94a3b8), fontSize: 13, height: 1.6),
              ),
            ),

            const SizedBox(height: 14),

            // Tech stack
            _SectionCard(
              icon: '🛠️',
              title: 'Technology Stack',
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.5),
                  1: FlexColumnWidth(2),
                },
                children: [
                  _tableHeader(),
                  _tableRow('Flutter', 'Cross-platform UI framework'),
                  _tableRow('Dart', 'Programming language'),
                  _tableRow('Firebase', 'Auth, Firestore, Storage'),
                  _tableRow('Cloud Firestore', 'Real-time NoSQL database'),
                  _tableRow('Firebase Storage', 'Image hosting & CDN'),
                  _tableRow('YOLOv8', 'AI component detection (planned)'),
                  _tableRow('GetX', 'State management library'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Firestore schema
            _SectionCard(
              icon: '🗄️',
              title: 'Firestore Schema',
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f172a),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: const Text(
                  'Collection: components\n'
                  '─────────────────────────\n'
                  'id                 String\n'
                  'componentName      String\n'
                  'originSource       String\n'
                  'intendedProject    String\n'
                  'dismantleTime      String\n'
                  'isDismantled       Boolean\n'
                  'adminVerified      Boolean\n'
                  'mismatchStatus     Boolean\n'
                  'aiLabel            String\n'
                  'userDescription    String\n'
                  'imageUrl           String?\n'
                  'timestamp          Timestamp\n\n'
                  'Collection: electronics_test\n'
                  '─────────────────────────\n'
                  'status             String\n'
                  'location           String\n'
                  'student            String\n'
                  'timestamp          Timestamp',
                  style: TextStyle(
                    color: Color(0xFF10b981),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    height: 1.7,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Firebase config
            _SectionCard(
              icon: '🔥',
              title: 'Firebase Project',
              child: Column(
                children: [
                  _ConfigRow('Project ID', 'electronic-junk'),
                  _ConfigRow('Sender ID', '147862152856'),
                  _ConfigRow('Storage', 'electronic-junk.firebasestorage.app'),
                  _ConfigRow('Region', 'us-central1'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Credits
            _SectionCard(
              icon: '👨‍💻',
              title: 'Credits',
              child: Column(
                children: [
                  _CreditsRow('Developer', 'Thomas'),
                  _CreditsRow('Location', 'Mumbai, India'),
                  _CreditsRow('Institution', 'Engineering Project'),
                  _CreditsRow('AI Model', 'YOLOv8 (Ultralytics)'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer
            Center(
              child: Column(
                children: [
                  const Text(
                    'Made with ⚡ and recycled components',
                    style: TextStyle(
                        color: Color(0xFF334155), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© ${DateTime.now().year} Electronic Junk Recipe Book',
                    style: const TextStyle(
                        color: Color(0xFF1e293b), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  TableRow _tableHeader() {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF334155))),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Technology',
              style: const TextStyle(
                  color: Color(0xFF10b981),
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Purpose',
              style: const TextStyle(
                  color: Color(0xFF10b981),
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      ],
    );
  }

  TableRow _tableRow(String tech, String purpose) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(tech,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(purpose,
              style: const TextStyle(
                  color: Color(0xFF94a3b8), fontSize: 13)),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final String fieldKey;
  final String value;
  const _ConfigRow(this.fieldKey, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(fieldKey,
                style: const TextStyle(
                    color: Color(0xFF64748b), fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Color(0xFFe2e8f0), fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _CreditsRow extends StatelessWidget {
  final String rowLabel;
  final String value;
  const _CreditsRow(this.rowLabel, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(rowLabel,
                style: const TextStyle(
                    color: Color(0xFF64748b), fontSize: 13)),
          ),
          Text(value,
              style:
                  const TextStyle(color: Color(0xFFe2e8f0), fontSize: 13)),
        ],
      ),
    );
  }
}
