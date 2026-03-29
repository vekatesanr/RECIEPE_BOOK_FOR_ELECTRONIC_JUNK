import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadService {
  static Future<void> processComponentUpload(String imageUri, Map<String, dynamic> specs) async {
    try {
      // Upload to Firebase Storage
      final file = File(imageUri);
      final storageRef = FirebaseStorage.instance.ref().child('junk_library/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Create Firestore document
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('components').add({
        'imageUrl': downloadUrl,
        'component_name': specs['component_name'] ?? '',
        'verification_status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'dismantle_difficulty': specs['dismantle_difficulty'] ?? '',
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission Denied: Unable to upload or save data.');
      } else if (e.code == 'unavailable') {
        throw Exception('Network Timeout: Please check your connection and try again.');
      } else {
        throw Exception('Firebase Error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }
}