import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  // БЕЗ services/
import '../pages/auth_gate.dart';  // ДОДАЛИ ../

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Перевіряємо чи Firebase вже ініціалізовано
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }git init
  git add .
  git commit -m "Initial commit"
  git branch -M main
  git remote add origin https://github.com/ImEntony16/QuizMaster1.git
  git push -u origin main

  runApp(const QuizMasterApp());
}

class QuizMasterApp extends StatelessWidget {
  const QuizMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuizMaster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}