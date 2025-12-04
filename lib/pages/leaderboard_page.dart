import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';



class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return FutureBuilder<void>(
      // разово насіваємо фейкових юзерів (якщо ще пусто)
      future: firestoreService.seedDummyUsers(count: 15),
      builder: (context, _) {
        return StreamBuilder<List<UserProfile>>(
          stream: firestoreService.getTopUsers(limit: 20),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Text('Рейтинг')),
                body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Поки що немає гравців у рейтингу',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            final topUsers = snapshot.data!;

            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(
                        'Рейтинг',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.amber.shade400,
                              Colors.orange.shade600,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.emoji_events,
                            size: 80,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Топ-3
                  if (topUsers.length >= 3)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              '🏆 Топ гравці',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _PodiumCard(
                                  rank: 2,
                                  name: topUsers[1].displayName,
                                  score: topUsers[1].totalScore,
                                  height: 120,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                _PodiumCard(
                                  rank: 1,
                                  name: topUsers[0].displayName,
                                  score: topUsers[0].totalScore,
                                  height: 150,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 8),
                                _PodiumCard(
                                  rank: 3,
                                  name: topUsers[2].displayName,
                                  score: topUsers[2].totalScore,
                                  height: 100,
                                  color: Colors.brown.shade400,
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),

                  // Решта
                  if (topUsers.length > 3)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final user = topUsers[index + 3];
                            return _LeaderboardTile(
                              rank: index + 4,
                              name: user.displayName,
                              score: user.totalScore,
                              quizzes: user.quizzesCompleted,
                            );
                          },
                          childCount: topUsers.length - 3,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final double height;
  final Color color;

  const _PodiumCard({
    required this.rank,
    required this.name,
    required this.score,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final medals = {1: '🥇', 2: '🥈', 3: '🥉'};

    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '$score балів',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              medals[rank]!,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final int quizzes;

  const _LeaderboardTile({
    required this.rank,
    required this.name,
    required this.score,
    required this.quizzes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$quizzes квізів пройдено'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              'балів',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
