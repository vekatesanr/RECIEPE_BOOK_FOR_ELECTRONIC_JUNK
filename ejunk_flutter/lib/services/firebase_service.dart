import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/component_model.dart';
import '../models/admin_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Save Component ──────────────────────────────────────────────────────


  // ─── Save Component ──────────────────────────────────────────────────────
  Future<String> saveComponent(ComponentModel component) async {
    try {
      final Map<String, dynamic> data = component.toMap();
      data['adminVerified'] = false; // enforce default
      final DocumentReference ref =
          await _firestore.collection('components').add(data);
      return ref.id;
    } catch (e) {
      throw Exception('Save component failed: $e');
    }
  }

  // ─── Delete Component ────────────────────────────────────────────────────
  Future<void> deleteComponent(String docId) async {
    try {
      await _firestore.collection('components').doc(docId).delete();
    } catch (e) {
      throw Exception('Delete component failed: $e');
    }
  }

  // ─── Verify Component ────────────────────────────────────────────────────
  Future<void> verifyComponent(String docId) async {
    try {
      await _firestore.collection('components').doc(docId).update({
        'adminVerified': true,
      });
    } catch (e) {
      throw Exception('Verify component failed: $e');
    }
  }

  // ─── Get Verified Components (real-time) ────────────────────────────────
  Stream<List<ComponentModel>> getVerifiedComponents() {
    return _firestore
        .collection('components')
        .where('adminVerified', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComponentModel.fromFirestore(doc))
            .toList());
  }

  // ─── Get All Components (admin) ──────────────────────────────────────────
  Stream<List<ComponentModel>> getAllComponents() {
    return _firestore
        .collection('components')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComponentModel.fromFirestore(doc))
            .toList());
  }

  // ─── Get Pending Components ──────────────────────────────────────────────
  Stream<List<ComponentModel>> getPendingComponents() {
    return _firestore
        .collection('components')
        .where('adminVerified', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComponentModel.fromFirestore(doc))
            .toList());
  }

  // ─── Test Firebase Connection ─────────────────────────────────────────────
  Future<String> testFirebaseConnection() async {
    try {
      final DocumentReference ref =
          await _firestore.collection('electronics_test').add({
        'status': 'Connected',
        'location': 'Mumbai',
        'student': 'Thomas',
        'timestamp': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      throw Exception('Firebase test failed: $e');
    }
  }

  // ─── Get All Admins ────────────────────────────────────────────────────────
  Stream<List<AdminModel>> getAllAdmins() {
    return _firestore
        .collection('admins')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AdminModel.fromFirestore(doc))
            .toList());
  }
}
