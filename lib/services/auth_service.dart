import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTER
  Future<void> register({
    required String email,
    required String password,
    String? name,
  }) async {
    // Create user in Firebase Auth
    UserCredential user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = user.user!.uid;

    // Save user info in Firestore with default role 'user'
    await _firestore.collection('users').doc(uid).set({
      'name': name ?? '',
      'email': email,
      'role': 'user', // default role
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update display name if provided
    if (name != null && name.isNotEmpty) {
      await user.user!.updateDisplayName(name);
    }
  }

  // LOGIN
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
