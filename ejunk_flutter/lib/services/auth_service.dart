import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String masterEmail = 'venkatesanr9042@gmail.com';

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  /// Auto-create the Master Admin if it doesn't already exist
  Future<void> _ensureMasterAdminExists() async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: masterEmail,
        password: 'venkat@8981',
      );
      
      // Save it explicitly to Firestore too
      await _firestore.collection('admins').doc(masterEmail).set({
        'email': masterEmail,
        'createdBy': 'system_auto_generate',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Auto-created users get automatically signed in, so we sign out immediately 
      // since the outer signInWithEmail func is about to be called.
      await _auth.signOut();
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Master admin already exists! This is normal, do nothing.
      } else {
        throw Exception(e.message);
      }
    }
  }

  /// Official Sign In Routine
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final sanitizedEmail = email.trim().toLowerCase();
      
      // Extremely quick check: If it's the master admin, ensure the account exists first!
      if (sanitizedEmail == masterEmail) {
        await _ensureMasterAdminExists();
      }

      final cred = await _auth.signInWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );

      // Security check: Verify they are an actual Admin in the database.
      if (cred.user != null && cred.user!.email != masterEmail) {
        final doc = await _firestore.collection('admins').doc(cred.user!.email).get();
        if (!doc.exists) {
           await signOut();
           throw Exception("This account exists, but does not have Admin privileges.");
        }
      }

      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Authentication failed');
    }
  }

  /// Master Admin Only: Creates a new user without logging out the current Master Admin
  Future<void> createAdminAccount({required String newEmail, required String newPassword}) async {
    if (currentUser?.email != masterEmail) {
       throw Exception("Only the Master Admin can create new admin accounts.");
    }

    try {
      // Spin up secondary Firebase App to create user silently
      FirebaseApp app = await Firebase.initializeApp(
          name: 'SecondaryApp', options: Firebase.app().options);
          
      UserCredential userCred = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: newEmail.trim().toLowerCase(), password: newPassword);

      // Destruct secondary app
      await app.delete();

      // Write to Firestore admins collection
      if (userCred.user != null) {
        await _firestore.collection('admins').doc(userCred.user!.email).set({
          'email': userCred.user!.email,
          'createdBy': masterEmail,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
       throw Exception(e.message ?? 'Failed to create secondary admin');
    } catch (e) {
       throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
