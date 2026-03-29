import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String email;
  final String createdBy;
  final DateTime timestamp;

  AdminModel({
    required this.email,
    required this.createdBy,
    required this.timestamp,
  });

  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      email: data['email'] ?? '',
      createdBy: data['createdBy'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'createdBy': createdBy,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
