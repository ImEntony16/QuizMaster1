import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizmaster/pages/home_page.dart'; // або quiz_list_screen, що в тебе головне
import 'package:quizmaster/pages/auth_page.dart'; // <-- твій гарний екран

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          if (user == null) {
            // ПОКАЗУЄМО ТВІЙ КАСТОМНИЙ ЕКРАН
            return const AuthPage();
          } else {
            // Після логіну/реєстрації — на головну
            return const HomePage(); // або твій QuizListScreen
          }
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
