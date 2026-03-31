import 'package:cloud_firestore/cloud_firestore.dart';

class JunkComponent {
  final String id;
  final String aiLabel; // Restored for context tracking
  final String imageUrl;
  final String userDamageDesc;
  final String? origin;
  final String aiSuggestedProject; 
  final String dismantleTime;
  final bool isVerified;
  final bool adminVerified; // Sync with 5-key requirement
  final bool mismatch;      // Section B: AI Mismatch detection
  final String? mismatchExplanation; // Explanation of the mismatch
  final DateTime timestamp;

  JunkComponent({
    required this.id,
    required this.aiLabel,
    required this.imageUrl,
    required this.userDamageDesc,
    this.origin,
    required this.aiSuggestedProject,
    required this.dismantleTime,
    this.isVerified = false,
    this.adminVerified = false,
    this.mismatch = false,
    this.mismatchExplanation,
    required this.timestamp,
  });

  // This function converts Firebase data into this Dart object
  factory JunkComponent.fromMap(Map<String, dynamic> data, String id) {
    return JunkComponent(
      id: id,
      aiLabel: data['aiLabel'] ?? 'Unknown Component',
      imageUrl: data['imageUrl'] ?? '',
      userDamageDesc: data['userDamageDesc'] ?? 'No description',
      origin: data['origin'],
      aiSuggestedProject: data['aiSuggestedProject'] ?? 'AI Analysis Pending...',
      dismantleTime: data['dismantleTime'] ?? 'Calculating...',
      isVerified: data['isVerified'] ?? false,
      adminVerified: data['adminVerified'] ?? false,
      mismatch: data['mismatch'] ?? false,
      mismatchExplanation: data['mismatchExplanation'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Alias for Firestore withConverter compatibility
  factory JunkComponent.fromJson(Map<String, dynamic> data, String id) =>
      JunkComponent.fromMap(data, id);

  Map<String, dynamic> toJson() {
    return {
      'aiLabel': aiLabel,
      'imageUrl': imageUrl,
      'userDamageDesc': userDamageDesc,
      'origin': origin,
      'aiSuggestedProject': aiSuggestedProject,
      'dismantleTime': dismantleTime,
      'isVerified': isVerified,
      'adminVerified': adminVerified,
      'mismatch': mismatch,
      'mismatchExplanation': mismatchExplanation,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}