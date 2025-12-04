import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// екрани, що вже є в проєкті
import 'package:quizmaster/pages/quiz_list_screen.dart';
import 'package:quizmaster/pages/leaderboard_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // хедер з привітанням
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Вітаю 👋',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email?.split('@').first ?? 'Користувач',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        (user?.email?.substring(0, 1) ?? 'U').toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // основний контент
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // заголовок
                        Text(
                          'Що сьогодні пройдемо?',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2x2 меню
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _MenuCard(
                              icon: Icons.quiz,
                              title: 'Квізи',
                              subtitle: 'Вибрати тест',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const QuizListScreen()),
                                );
                              },
                            ),
                            _MenuCard(
                              icon: Icons.create,
                              title: 'Створити',
                              subtitle: 'Новий квіз',
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B9D), Color(0xFFC86DD7)],
                              ),
                              onTap: () {
                                // TODO: підключимо CreateQuizPage, коли додаси файл
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Створення квізу — скоро 😉')),
                                );
                              },
                            ),
                            _MenuCard(
                              icon: Icons.bar_chart,
                              title: 'Твій рейтинг',
                              subtitle: 'Ваші результати',
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFA751), Color(0xFFFFE259)],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                                );
                              },
                            ),
                            _MenuCard(
                              icon: Icons.settings,
                              title: 'Налаштування',
                              subtitle: 'Профіль',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                              ),
                              onTap: () {
                                _showProfileBottomSheet(context);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // “популярні квізи” (поки для вигляду)
                        Text(
                          'Популярні квізи',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _PopularQuizCard(
                          title: 'Випадкові питання',
                          questions: 10,
                          icon: Icons.public,
                          color: Colors.blue,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Скоро додамо підбірки 👍')),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _PopularQuizCard(
                          title: 'ООП квіз',
                          questions: 15,
                          icon: Icons.history_edu,
                          color: Colors.orange,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Скоро додамо запуск конкретного квізу')),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _PopularQuizCard(
                          title: 'Flutter та Dart',
                          questions: 12,
                          icon: Icons.code,
                          color: Colors.purple,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Скоро буде!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileBottomSheet(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // хендл
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // аватар
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                (user?.email?.substring(0, 1) ?? 'U').toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              user?.email ?? 'Користувач',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // вихід
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Вийти'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _PopularQuizCard extends StatelessWidget {
  final String title;
  final int questions;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PopularQuizCard({
    required this.title,
    required this.questions,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$questions питань'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
