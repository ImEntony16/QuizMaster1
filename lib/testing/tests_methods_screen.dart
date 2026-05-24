import 'package:flutter/material.dart';
import 'package:quizmaster/testing/tests_topics_screen.dart';

class TestsMethodsScreen extends StatelessWidget {
  const TestsMethodsScreen({super.key});

  final List<Map<String, dynamic>> _testMethods = const [
    {
      'title': 'Класичний Квіз',
      'desc': 'Стандартний тест: питання та 4 варіанти відповідей. Без обмеження часу. (+10 XP за правильну)',
      'icon': Icons.assignment,
      'color': Colors.blue,
      'type': 'classic',
    },
    {
      'title': 'Спринт проти часу',
      'desc': 'Динамічний режим: встигни відповісти на максимальну кількість питань за 60 секунд! (+15 XP)',
      'icon': Icons.timer,
      'color': Colors.red,
      'type': 'sprint',
    },
    {
      'title': 'Іспит (Hardcore)',
      'desc': 'Суворе тестування: всього 3 життя. Одна помилка коштує дорого. Для справжніх про. (+25 XP)',
      'icon': Icons.gavel,
      'color': Colors.amber,
      'type': 'exam',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        title: const Text('Формати тестування', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.blueAccent,
            child: const Text(
              'Оберіть режим тестування для перевірки знань та прокачки вашого рівня XP:',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _testMethods.length,
              itemBuilder: (context, index) {
                final method = _testMethods[index];
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
                      // Переходимо на екран вибору тем, передаючи тип тесту
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TestsTopicsScreen(
                            methodTitle: method['title'],
                            methodType: method['type'],
                          ),
                        ),
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