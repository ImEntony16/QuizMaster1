import 'package:flutter/material.dart';

class SyntaxTrainerScreen extends StatefulWidget {
  const SyntaxTrainerScreen({super.key});

  @override
  State<SyntaxTrainerScreen> createState() => _SyntaxTrainerScreenState();
}

class _SyntaxTrainerScreenState extends State<SyntaxTrainerScreen> {
  final _answerController = TextEditingController();
  int _currentTask = 0;
  String _feedback = '';

  final List<Map<String, dynamic>> _tasks = const [
    {
      'code': 'void main() {\n  print("Hello");\n} // яка функція запускає Flutter?',
      'question': 'Введіть назву функції, яка запускає додаток Flutter (наприклад, runApp):',
      'correct': 'runApp'
    },
    {
      'code': 'SELECT * ________ users WHERE id = 1;',
      'question': 'Введіть пропущене ключове слово SQL для вибору з таблиці:',
      'correct': 'FROM'
    }
  ];

  void _checkAnswer() {
    if (_answerController.text.trim().toLowerCase() == _tasks[_currentTask]['correct'].toString().toLowerCase()) {
      setState(() {
        _feedback = '🎉 Правильно! Чудова робота.';
      });
    } else {
      setState(() {
        _feedback = '❌ Неправильно, спробуйте ще раз або перевірте регістр.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = _tasks[_currentTask];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренажер синтаксису', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Завдання:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
              child: Text(task['code'], style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 14)),
            ),
            const SizedBox(height: 20),
            Text(task['question'], style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Ваша відповідь тут...'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _checkAnswer,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                  child: const Text('Перевірити'),
                ),
                if (_feedback.contains('🎉') && _currentTask < _tasks.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentTask++;
                        _answerController.clear();
                        _feedback = '';
                      });
                    },
                    child: const Text('Наступне >'),
                  )
              ],
            ),
            const SizedBox(height: 20),
            Text(_feedback, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}