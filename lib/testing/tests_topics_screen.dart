import 'package:flutter/material.dart';
import 'package:quizmaster/testing/quiz_data.dart';
import 'package:quizmaster/testing/quiz_game_screen.dart'; // Додали імпорт гри!

class TestsTopicsScreen extends StatelessWidget {
  final String methodTitle;
  final String methodType;

  const TestsTopicsScreen({
    super.key,
    required this.methodTitle,
    required this.methodType
  });

  @override
  Widget build(BuildContext context) {
    // Беремо список тем безпосередньо з нашого файлу даних
    final topics = QuizData.topicsQuestions.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        title: Text(methodTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
              child: Text(
                'Оберіть тему для проходження тесту:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topicName = topics[index];
                  final questionsCount = QuizData.topicsQuestions[topicName]?.length ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(Icons.menu_book, color: Colors.blue),
                      ),
                      title: Text(
                        topicName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Text(
                        'Кількість питань: $questionsCount',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.play_arrow, color: Colors.blueAccent),
                      onTap: () {
                        // Повністю робочий перехід до самої гри з передачею типу режиму
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizGameScreen(
                              topicName: topicName,
                              methodTitle: methodTitle,
                              methodType: methodType,
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
      ),
    );
  }
}