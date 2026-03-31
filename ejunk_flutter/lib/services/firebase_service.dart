import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/component_model.dart';
import '../models/admin_model.dart';
import '../models/junk_component.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // New Smart Data Model (JunkComponent) Collection Reference
  CollectionReference<JunkComponent> get _junkCollection =>
      _firestore.collection('junk_components').withConverter<JunkComponent>(
            fromFirestore: (snapshot, _) => JunkComponent.fromJson(snapshot.data()!, snapshot.id),
            toFirestore: (component, _) => component.toJson(),
          );

  // ─── Save Component ──────────────────────────────────────────────────────


  // ─── Save Component ──────────────────────────────────────────────────────
// ─── Save Component (Updated with AI Placeholders) ────────────────────────
  Future<String> saveComponent(ComponentModel component) async {
    try {
      final Map<String, dynamic> data = component.toMap();
      
      // ADD THESE 5 KEYS HERE:
      data['adminVerified'] = false; 
      data['aiSuggestedProject'] = "AI Analysis Pending..."; // Placeholder for Gemini
      data['dismantleTime'] = "Calculating...";              // Placeholder for Gemini
      data['isVerified'] = false;                             // Double check for UI
      data['timestamp'] = FieldValue.serverTimestamp();       // Ensure timing is synced
      
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

  // ─── JunkComponent (New AI Engine) ──────────────────────────────────────────

  Future<String> saveJunkComponent(JunkComponent junk) async {
    try {
      final docRef = await _junkCollection.add(junk);
      return docRef.id;
    } catch (e) {
      throw Exception('Save JunkComponent failed: $e');
    }
  }

  Stream<List<JunkComponent>> getJunkComponents() {
    return _junkCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<List<String>> getRecentComponentNames(int limit) async {
    try {
      final query = await _firestore
          .collection('junk_components')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      return query.docs.map((doc) => doc.data()['aiLabel'] as String).toList();
    } catch (e) {
      return [];
    }
  }
}
