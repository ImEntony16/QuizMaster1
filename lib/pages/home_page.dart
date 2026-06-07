import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizmaster/learning/flashcards_screen.dart';
import 'package:quizmaster/testing/tests_methods_screen.dart';
import 'package:quizmaster/pages/statistics_screen.dart';
import 'package:quizmaster/pages/profile_page.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  late String _currentQuote;

  final List<String> _quotes = [
    "«Код — як нестабільна споруда: працює, поки нічого не чіпаєш.»",
    "«Найкращий спосіб передбачити майбутнє — створити його.» — Пітер Друкер",
    "«Програмування — це не те, що ви знаєте, а те, що ви можете з'ясувати.»",
    "«Спочатку виріши задачу. Потім пиши код.» — Джон Джонсон",
    "«Помилки — це просто доказ того, що ви намагаєтеся.»",
    "«Два тижні програмування можуть зекономити вам одну годину планування.»"
  ];

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[Random().nextInt(_quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          int score = 0;
          String displayName = user?.email?.split('@')[0] ?? 'Користувач';

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            score = data?['score'] ?? 0;
            displayName = data?['displayName'] ?? data?['name'] ?? displayName;
          }

          int currentLevel = (score / 100).floor() + 1;
          double levelProgress = (score % 100) / 100.0;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ПРОСТІР ЗНАНЬ",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF673AB7).withOpacity(0.4),
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: -0.7,
                            ),
                          ),
                        ],
                      ),

                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF673AB7).withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Icon(Icons.person_outline_rounded, color: Color(0xFF673AB7), size: 24),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // КАРТКА ПРОГРЕСУ
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF673AB7).withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF673AB7).withOpacity(0.07),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF673AB7), size: 18),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "Рівень $currentLevel",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF673AB7).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "$score XP",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF673AB7)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: levelProgress,
                            backgroundColor: const Color(0xFFF0EBF7),
                            color: const Color(0xFF673AB7),
                            minHeight: 7,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("До рівня ${currentLevel + 1}", style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                            Text("${(levelProgress * 100).toInt()}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF673AB7))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ГОЛОВНЕ МЕНЮ",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black.withOpacity(0.35),
                          letterSpacing: 1.8,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => FirebaseAuth.instance.signOut(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "ВИЙТИ",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.red[400], letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                    children: [
                      _buildPremiumBlockCard(
                        title: "Тести",
                        subtitle: "Перевірка знань",
                        icon: Icons.analytics_outlined,
                        accentColor: Colors.blue[600]!,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TestsMethodsScreen())),
                      ),
                      _buildPremiumBlockCard(
                        title: "Навчання",
                        subtitle: "Повторення IT",
                        icon: Icons.collections_bookmark_outlined,
                        accentColor: const Color(0xFF00A86B),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FlashcardsScreen())),
                      ),
                      _buildPremiumBlockCard(
                        title: "Статистика",
                        subtitle: "Твої успіхи",
                        icon: Icons.bubble_chart_outlined,
                        accentColor: Colors.orange[700]!,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen())),
                      ),
                      _buildPremiumBlockCard(
                        title: "Профіль",
                        subtitle: "Мій кабінет",
                        icon: Icons.fingerprint_rounded,
                        accentColor: const Color(0xFF673AB7),
                        // ФІКС: Змінено ProfileScreen() на ProfilePage()
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),


                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.015),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote_rounded, color: Color(0xFF673AB7), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _currentQuote,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumBlockCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final Color cleanAccent = accentColor == const Color(0xFF00A86B) ? const Color(0xFF00A86B) : accentColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF673AB7).withOpacity(0.025),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cleanAccent.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: cleanAccent, size: 22),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[300], size: 12),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}