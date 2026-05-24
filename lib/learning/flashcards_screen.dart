import 'package:flutter/material.dart';
import 'package:quizmaster/learning/learning_topics_screen.dart';
import 'package:quizmaster/learning/lectures_screen.dart'; // Імпорт 2-го методу
import 'package:quizmaster/learning/syntax_trainer_screen.dart'; // Імпорт 3-го методу
import 'package:quizmaster/learning/cheat_sheets_screen.dart'; // Імпорт 4-го методу

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  final List<Map<String, dynamic>> _methods = const [
    {
      'title': 'Флеш-картки знань',
      'desc': 'Інтервальне повторення термінів, концепцій та коду за допомогою двосторонніх інтерактивних карт.',
      'icon': Icons.style,
      'color': Colors.green,
      'enabled': true,
    },
    {
      'title': 'Конспекти & Лекції',
      'desc': 'Стислі теоретичні матеріали, шпаргалки та документація по кожному IT-напрямку.',
      'icon': Icons.menu_book,
      'color': Colors.blue,
      'enabled': true, // Увімкнено!
    },
    {
      'title': 'Тренажер синтаксису',
      'desc': 'Практичні інтерактивні завдання на дописування коду Dart/SQL прямо на екрані смартфона.',
      'icon': Icons.terminal,
      'color': Colors.purple,
      'enabled': true, // Увімкнено!
    },
    {
      'title': 'ІТ Шпаргалки (Cheat Sheets)',
      'desc': 'Швидкий доступ до таблиць команд, статус-кодів HTTP та корисних конструкцій для іспитів.',
      'icon': Icons.quickreply,
      'color': Colors.orange,
      'enabled': true, // Увімкнено!
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Методи навчання', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.blueAccent,
            child: const Text(
              'Оберіть формат підготовки до іспитів чи співбесід:',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _methods.length,
              itemBuilder: (context, index) {
                final method = _methods[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: method['color'].withOpacity(0.15),
                      child: Icon(method['icon'], color: method['color']),
                    ),
                    title: Text(
                        method['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(method['desc'], style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.3)),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black45),
                    onTap: () {
                      // Логіка переходу залежно від обраного індексу картки методу
                      Widget targetScreen;
                      switch (index) {
                        case 0:
                          targetScreen = const LearningTopicsScreen();
                          break;
                        case 1:
                          targetScreen = const LecturesScreen();
                          break;
                        case 2:
                          targetScreen = const SyntaxTrainerScreen();
                          break;
                        case 3:
                          targetScreen = const CheatSheetsScreen();
                          break;
                        default:
                          targetScreen = const LearningTopicsScreen();
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => targetScreen),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}