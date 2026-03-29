import 'package:cloud_firestore/cloud_firestore.dart';

class ComponentModel {
  final String id;
  final String componentName;
  final String originSource;
  final String intendedProject;
  final String dismantleTimeEstimate;
  final bool isDismantled;
  final bool adminVerified;
  final bool mismatchStatus;
  final String aiLabel;
  final String userDescription;
  final String? imageUrl;
  final DateTime timestamp;

  ComponentModel({
    required this.id,
    required this.componentName,
    required this.originSource,
    required this.intendedProject,
    required this.dismantleTimeEstimate,
    this.isDismantled = false,
    this.adminVerified = false,
    this.mismatchStatus = false,
    required this.aiLabel,
    required this.userDescription,
    this.imageUrl,
    required this.timestamp,
  });

  factory ComponentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ComponentModel(
      id: doc.id,
      componentName: data['componentName'] ?? '',
      originSource: data['originSource'] ?? '',
      intendedProject: data['intendedProject'] ?? '',
      dismantleTimeEstimate: data['dismantleTimeEstimate'] ?? '',
      isDismantled: data['isDismantled'] ?? false,
      adminVerified: data['adminVerified'] ?? false,
      mismatchStatus: data['mismatchStatus'] ?? false,
      aiLabel: data['aiLabel'] ?? '',
      userDescription: data['userDescription'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'componentName': componentName,
      'originSource': originSource,
      'intendedProject': intendedProject,
      'dismantleTimeEstimate': dismantleTimeEstimate,
      'isDismantled': isDismantled,
      'adminVerified': adminVerified,
      'mismatchStatus': mismatchStatus,
      'aiLabel': aiLabel,
      'userDescription': userDescription,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  ComponentModel copyWith({
    String? id,
    String? componentName,
    String? originSource,
    String? intendedProject,
    String? dismantleTimeEstimate,
    bool? isDismantled,
    bool? adminVerified,
    bool? mismatchStatus,
    String? aiLabel,
    String? userDescription,
    String? imageUrl,
    DateTime? timestamp,
  }) {
    return ComponentModel(
      id: id ?? this.id,
      componentName: componentName ?? this.componentName,
      originSource: originSource ?? this.originSource,
      intendedProject: intendedProject ?? this.intendedProject,
      dismantleTimeEstimate:
          dismantleTimeEstimate ?? this.dismantleTimeEstimate,
      isDismantled: isDismantled ?? this.isDismantled,
      adminVerified: adminVerified ?? this.adminVerified,
      mismatchStatus: mismatchStatus ?? this.mismatchStatus,
      aiLabel: aiLabel ?? this.aiLabel,
      userDescription: userDescription ?? this.userDescription,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
