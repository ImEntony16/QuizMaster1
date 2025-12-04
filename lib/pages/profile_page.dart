import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: _firestoreService.getCurrentUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar з градієнтом
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Аватар
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            profile?.displayName ?? user?.email?.split('@')[0] ?? 'Користувач',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Контент
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Статистика (заглушка)
                      const Text(
                        'Статистика',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.quiz,
                              title: 'Квізи',
                              value: '${profile?.quizzesCompleted ?? 0}',
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.star,
                              title: 'Бали',
                              value: '${profile?.totalScore ?? 0}',
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.trending_up,
                              title: 'Середній бал',
                              value: '${profile?.averageScore.toStringAsFixed(0) ?? 0}%',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.emoji_events,
                              title: 'Рейтинг',
                              value: '-',
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Налаштування
                      const Text(
                        'Налаштування',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Редагувати профіль'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                _showEditProfileDialog();
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.notifications),
                              title: const Text('Сповіщення'),
                              trailing: Switch(
                                value: false,
                                onChanged: (value) {},
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.dark_mode),
                              title: const Text('Темна тема'),
                              trailing: Switch(
                                value: Theme.of(context).brightness == Brightness.dark,
                                onChanged: (value) {},
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Кнопка виходу
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Вийти'),
                                content: const Text('Ви впевнені, що хочете вийти?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Скасувати'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Вийти'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && mounted) {
                              await FirebaseAuth.instance.signOut();
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

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(
      text: user?.displayName ?? user?.email?.split('@')[0],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редагувати профіль'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Ім\'я',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.updateDisplayName(nameController.text);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Профіль оновлено!')),
                );
              }
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}