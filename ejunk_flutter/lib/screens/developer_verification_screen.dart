import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/component_model.dart';

class DeveloperVerificationScreen extends StatelessWidget {
  const DeveloperVerificationScreen({super.key});

  static const String adminEmail = 'admin@ejunk.app';

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user?.email != adminEmail) {
      return Scaffold(
        backgroundColor: const Color(0xFF0f172a),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings_outlined, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              const Text('Admin Access Required', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Logged in as: ${user?.email ?? "No user"}', style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.logout),
                label: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        title: const Text('Verification Dashboard'),
        backgroundColor: const Color(0xFF1e293b),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('components')
            .where('verification_status', isEqualTo: 'pending')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Color(0xFF10b981)),
                  SizedBox(height: 16),
                  Text('No pending components', style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text('All items verified!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final components = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ComponentModel(
              id: doc.id,
              imageUrl: data['imageUrl'] ?? '',
              componentName: data['component_name'] ?? '',
              aiLabel: data['ai_label'] ?? '',
              userDescription: data['user_description'] ?? '',
              verificationStatus: data['verification_status'] ?? '',
              dismantleDifficulty: data['dismantle_difficulty'] ?? '',
              originSource: data['origin'] ?? '',
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: components.length,
            itemBuilder: (context, index) {
              final component = components[index];
              return Card(
                color: const Color(0xFF1e293b),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          component.imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 160,
                            color: Colors.grey[800],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Component: ${component.componentName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text('Difficulty: ${component.dismantleDifficulty}', style: TextStyle(color: Colors.grey[400])),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('AI Label', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10b981))),
                                Text(component.aiLabel.isEmpty ? 'N/A' : component.aiLabel, style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('User Description', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFef4444))),
                                Text(component.userDescription, style: const TextStyle(color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance.collection('components').doc(component.id).update({
                                    'verification_status': 'verified',
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Approved')));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF10b981)),
                              icon: const Icon(Icons.check_circle, color: Colors.white),
                              label: const Text('Approve', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Reject?'),
                                    content: const Text('Delete component and image?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reject')),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  try {
                                    await FirebaseFirestore.instance.collection('components').doc(component.id).delete();
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Rejected & deleted')));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFef4444)),
                              icon: const Icon(Icons.delete_forever, color: Colors.white),
                              label: const Text('Reject', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

