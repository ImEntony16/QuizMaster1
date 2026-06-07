import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final _db = FirebaseFirestore.instance;

  Future<void> _seedDummyQuizzes({int count = 10}) async {
    final rnd = Random();
    final topics = [
      'Flutter Basics',
      'Dart Fundamentals',
      'OOP в практиці',
      'Алгоритми',
      'Структури даних',
      'Web 101',
      'SQL Intro',
      'Git та GitHub',
      'Мережі',
      'Design Patterns'
    ];

    try {
      final batch = _db.batch();
      for (int i = 0; i < count; i++) {
        final topic = topics[rnd.nextInt(topics.length)];
        final title = '$topic — квіз #${100 + rnd.nextInt(900)}';
        final desc = 'Короткий демо-квіз на тему: $topic. (плейсхолдер)';

        final docRef = _db.collection('quizzes').doc();
        batch.set(docRef, {
          'title': title,
          'description': desc,
          'questions': <Map<String, dynamic>>[],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Додано 10 демо-квізів')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка при створенні демо-квізів: $e')),
        );
      }
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _quizzesStream() {
    return _db
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список квізів'),
        actions: [
          IconButton(
            tooltip: 'Додати 10 демо-квізів',
            onPressed: () => _seedDummyQuizzes(count: 10),
            icon: const Icon(Icons.bolt_outlined),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _quizzesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Помилка завантаження: ${snapshot.error}'),
            );
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Поки що квізів немає',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _seedDummyQuizzes(count: 10),
                    icon: const Icon(Icons.add),
                    label: const Text('Додати демо-квізи'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final title = (data['title'] ?? 'Без назви') as String;
              final description =
              (data['description'] ?? 'Без опису') as String;
              final questions = (data['questions'] as List?) ?? const [];
              final createdAt = data['createdAt'];
              String dateText = '';
              if (createdAt is Timestamp) {
                final dt = createdAt.toDate();
                dateText =
                '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
              }

              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.quiz_outlined),
                  ),
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (dateText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Створено: $dateText',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.help_outline, size: 18),
                      const SizedBox(height: 2),
                      Text(
                        '${questions.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Екран проходження квізу — скоро 😉'),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _seedDummyQuizzes(count: 10),
        icon: const Icon(Icons.add),
        label: const Text('Демо-квізи'),
      ),
    );
  }
}
