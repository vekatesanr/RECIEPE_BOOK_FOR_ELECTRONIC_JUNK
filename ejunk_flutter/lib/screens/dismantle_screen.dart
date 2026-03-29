import 'package:flutter/material.dart';
import '../widgets/sidebar_drawer.dart';

class DismantleScreen extends StatefulWidget {
  const DismantleScreen({super.key});

  @override
  State<DismantleScreen> createState() => _DismantleScreenState();
}

class _DismantleScreenState extends State<DismantleScreen> {
  final List<_DismantleGuide> _guides = [
    _DismantleGuide(
      componentName: 'Ceramic Capacitor',
      emoji: '🔋',
      tools: ['Soldering iron', 'Desoldering pump', 'Flux', 'Tweezers'],
      safetyWarning:
          'Discharge the capacitor before handling. High-voltage capacitors can store lethal charge even when unpowered.',
      steps: [
        'Identify the capacitor by its small cylindrical or disc shape.',
        'Set soldering iron to 350°C (SMD caps) or 380°C (through-hole).',
        'Apply flux to both solder joints to improve heat transfer.',
        'Heat one pad while gently lifting the component with tweezers.',
        'For through-hole: heat both leads simultaneously with desoldering pump.',
        'Remove excess solder from pads using wick or pump.',
        'Clean the area with isopropyl alcohol.',
        'Store salvaged capacitor in labelled anti-static bag.',
      ],
      difficulty: 'Easy',
      timeEstimate: '5–15 min',
      safetyLevel: SafetyLevel.low,
    ),
    _DismantleGuide(
      componentName: 'Microcontroller (MCU)',
      emoji: '🧠',
      tools: [
        'Hot air gun',
        'Flux',
        'IC chip puller',
        'Desoldering pump',
        'BGA reballing kit (optional)',
      ],
      safetyWarning:
          'MCUs can be ESD-sensitive. Use anti-static mat and wristband. Hot air gun reaches 400°C — avoid skin contact.',
      steps: [
        'Remove the PCB from its housing and place on heat-resistant mat.',
        'Apply generous flux around all IC pins.',
        'Set hot air gun to 320–370°C, airflow medium-low.',
        'Move hot air gun in circular motion over the chip for 30–60 seconds.',
        'When solder melts, lift chip gently with chip puller or tweezers.',
        'Clean PCB pads with solder wick to remove residual solder.',
        'Rinse pads with isopropyl alcohol and inspect under magnifier.',
        'Test MCU continuity and store in foam anti-static tray.',
      ],
      difficulty: 'Advanced',
      timeEstimate: '20–40 min',
      safetyLevel: SafetyLevel.high,
    ),
    _DismantleGuide(
      componentName: 'Resistor Pack',
      emoji: '🔴',
      tools: ['Soldering iron', 'Desoldering braid', 'Tweezers'],
      safetyWarning:
          'Check power rating before handling. Carbon film resistors can be fragile when heated excessively.',
      steps: [
        'Identify resistor value using color code or multimeter.',
        'Heat one end of the resistor lead with soldering iron.',
        'Pull lead out while solder is molten.',
        'Repeat for the other lead.',
        'Test resistance value with multimeter before storage.',
        'Label and store in component organizer box.',
      ],
      difficulty: 'Easy',
      timeEstimate: '2–5 min',
      safetyLevel: SafetyLevel.low,
    ),
    _DismantleGuide(
      componentName: 'LCD Display Module',
      emoji: '🖥️',
      tools: [
        'Screwdrivers',
        'Plastic pry tools',
        'Heat gun (gentle)',
        'Ribbon cable connector tool',
      ],
      safetyWarning:
          'LCD panels contain liquid crystal fluid — avoid cracking the glass. Ribbon cables tear easily.',
      steps: [
        'Remove all mounting screws from the display assembly.',
        'Use plastic pry tool to carefully separate bezel from frame.',
        'Disconnect ribbon cables by lifting the ZIF connector latch.',
        'Gently warm adhesive areas with heat gun at 60–80°C.',
        'Peel display from backlight assembly slowly and evenly.',
        'Store LCD panel flat in padded envelope to prevent cracking.',
        'Test backlight LEDs separately with 3V power source.',
      ],
      difficulty: 'Intermediate',
      timeEstimate: '15–25 min',
      safetyLevel: SafetyLevel.medium,
    ),
  ];

  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(title: const Text('🔧 Dismantle Guides')),
      drawer: const SidebarDrawer(currentRoute: '/dismantle'),
      body: Column(
        children: [
          // Header banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10b981).withOpacity(0.15),
                  const Color(0xFF065f46).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF10b981).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('🔧', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Step-by-Step Dismantling',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_guides.length} guides available • Always prioritize safety',
                        style: const TextStyle(
                            color: Color(0xFF64748b), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Guides list
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              itemCount: _guides.length,
              itemBuilder: (context, index) {
                final guide = _guides[index];
                final isExpanded = _expanded.contains(index);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isExpanded
                          ? const Color(0xFF10b981).withOpacity(0.4)
                          : const Color(0xFF334155),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expanded.remove(index);
                            } else {
                              _expanded.add(index);
                            }
                          });
                        },
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Text(guide.emoji,
                                  style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      guide.componentName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _Chip(guide.difficulty,
                                            guide._difficultyColor),
                                        const SizedBox(width: 6),
                                        _Chip('⏱ ${guide.timeEstimate}',
                                            const Color(0xFF6366f1)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: const Color(0xFF64748b),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Expanded content
                      if (isExpanded) ...[
                        const Divider(
                            color: Color(0xFF334155), height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Safety warning
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: guide._safetyColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: guide._safetyColor
                                        .withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color: guide._safetyColor,
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        guide.safetyWarning,
                                        style: TextStyle(
                                          color: guide._safetyColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Tools
                              const Text(
                                'Tools Required',
                                style: TextStyle(
                                  color: Color(0xFF10b981),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: guide.tools
                                    .map((t) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0f172a),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: const Color(
                                                    0xFF334155)),
                                          ),
                                          child: Text(
                                            '🔩 $t',
                                            style: const TextStyle(
                                              color: Color(0xFFcbd5e1),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 16),

                              // Steps
                              const Text(
                                'Step-by-Step Instructions',
                                style: TextStyle(
                                  color: Color(0xFF10b981),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...guide.steps
                                  .asMap()
                                  .entries
                                  .map((entry) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 10),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 26,
                                              height: 26,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF10b981)
                                                    .withOpacity(0.15),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(
                                                      0xFF10b981),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${entry.key + 1}',
                                                  style: const TextStyle(
                                                    color:
                                                        Color(0xFF10b981),
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                entry.value,
                                                style: const TextStyle(
                                                  color: Color(0xFFcbd5e1),
                                                  fontSize: 13,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum SafetyLevel { low, medium, high }

class _DismantleGuide {
  final String componentName;
  final String emoji;
  final List<String> tools;
  final String safetyWarning;
  final List<String> steps;
  final String difficulty;
  final String timeEstimate;
  final SafetyLevel safetyLevel;

  const _DismantleGuide({
    required this.componentName,
    required this.emoji,
    required this.tools,
    required this.safetyWarning,
    required this.steps,
    required this.difficulty,
    required this.timeEstimate,
    required this.safetyLevel,
  });

  Color get _difficultyColor {
    switch (difficulty) {
      case 'Easy':
        return const Color(0xFF10b981);
      case 'Intermediate':
        return const Color(0xFFf59e0b);
      case 'Advanced':
        return const Color(0xFFef4444);
      default:
        return const Color(0xFF64748b);
    }
  }

  Color get _safetyColor {
    switch (safetyLevel) {
      case SafetyLevel.low:
        return const Color(0xFF10b981);
      case SafetyLevel.medium:
        return const Color(0xFFf59e0b);
      case SafetyLevel.high:
        return const Color(0xFFef4444);
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
