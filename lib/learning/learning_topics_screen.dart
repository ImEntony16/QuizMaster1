import 'package:flutter/material.dart';
import 'package:quizmaster/learning/flashcards_data.dart';
import 'package:quizmaster/learning/cards_view_page.dart';

class LearningTopicsScreen extends StatelessWidget {
  const LearningTopicsScreen({super.key});

  final List<Map<String, dynamic>> _topicsConfig = const [
    {'title': 'Основи Flutter & Dart', 'desc': 'Віджети, керування станом, асинхронність та архітектура додатків.', 'icon': Icons.phone_android, 'color': Colors.blue},
    {'title': 'Бази даних & SQL', 'desc': 'Реляційні БД, проектування таблиць, складні запити JOIN та індексація.', 'icon': Icons.storage, 'color': Colors.amber},
    {'title': 'Об\'єктно-орієнтоване ПР (ООП)', 'desc': 'Інкапсуляція, поліморфізм, успадкування, abstraction та SOLID.', 'icon': Icons.code, 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Оберіть тему карток', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _topicsConfig.length,
        itemBuilder: (context, index) {
          final config = _topicsConfig[index];
          final cards = FlashcardsData.topicsWithCards[config['title']] ?? [];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: config['color'].withOpacity(0.15),
                child: Icon(config['icon'], color: config['color']),
              ),
              title: Text(config['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(config['desc'], style: const TextStyle(fontSize: 12)),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                child: Text('${cards.length} шт', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardsViewPage(
                      topicTitle: config['title'],
                      cards: cards,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}