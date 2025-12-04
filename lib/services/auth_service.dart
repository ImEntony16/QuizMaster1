// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Стрім користувача
  Stream<User?> get user => _auth.authStateChanges();

  // Реєстрація
  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  // Вхід
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  // Вихід
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
