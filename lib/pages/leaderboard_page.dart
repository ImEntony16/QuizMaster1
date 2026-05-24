import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Моя статистика',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: db.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

          final int score = data['score'] ?? 1450;
          final int quizzesDone = data['quizzesCount'] ?? 12;
          final int cardsStudied = data['cardsCount'] ?? 48;
          final double accuracy = (data['accuracy'] ?? 0.84) * 100;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Блок з профілем
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.indigoAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.psychology, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.displayName ?? user?.email?.split('@')[0] ?? 'Студент',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Рівень 4: Знавець',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Основні показники',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Метрики
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard(
                      title: 'Загальні бали',
                      value: '$score',
                      icon: Icons.emoji_events,
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      title: 'Тестів пройдено',
                      value: '$quizzesDone',
                      icon: Icons.task_alt,
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      title: 'Вивчено карток',
                      value: '$cardsStudied',
                      icon: Icons.style,
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      title: 'Точність відповідей',
                      value: '${accuracy.toStringAsFixed(0)}%',
                      icon: Icons.track_changes,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Мої досягнення',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _buildAchievementTile(
                  title: 'Перша кров',
                  subtitle: 'Успішно завершено перший тест без помилок',
                  icon: Icons.workspace_premium,
                  color: Colors.amber,
                  isUnlocked: true,
                ),
                _buildAchievementTile(
                  title: 'Генератор знань',
                  subtitle: 'Повторено понад 30 флеш-карток за добу',
                  icon: Icons.bolt,
                  color: Colors.cyan,
                  isUnlocked: true,
                ),
                _buildAchievementTile(
                  title: 'Нічний кодер',
                  subtitle: 'Пройдено тест на тему ООП після 12 години ночі',
                  icon: Icons.nightlight_round,
                  color: Colors.indigo,
                  isUnlocked: quizzesDone >= 5,
                ),
                _buildAchievementTile(
                  title: 'Абсолютний Майстер',
                  subtitle: 'Набрати 5000 балів у загальному заліку',
                  icon: Icons.stars,
                  color: Colors.grey,
                  isUnlocked: score >= 5000,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isUnlocked,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUnlocked ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isUnlocked ? color : Colors.grey, size: 26),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? Colors.black87 : Colors.grey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
      ),
    );
  }
}