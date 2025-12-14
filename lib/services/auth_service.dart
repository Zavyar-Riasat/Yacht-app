import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> register({
    required String email,
    required String password,
    String? name,
  }) async {
    UserCredential user =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (name != null && name.isNotEmpty) {
      await user.user!.updateDisplayName(name);
    }
  }

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
