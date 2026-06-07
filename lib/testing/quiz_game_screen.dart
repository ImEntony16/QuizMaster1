import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizmaster/testing/quiz_data.dart';

class QuizGameScreen extends StatefulWidget {
  final String topicName;
  final String methodTitle;
  final String methodType;

  const QuizGameScreen({
    super.key,
    required this.topicName,
    required this.methodTitle,
    required this.methodType,
  });

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  late List<Map<String, dynamic>> _questions;
  int _currentIndex = 0;
  int _scoreEarned = 0;
  int _correctAnswersCount = 0;

  int? _selectedAnswerIndex;
  bool _isAnswered = false;


  Timer? _timer;
  int _timeLeft = 60;

  //  "Іспит"
  int _lives = 5;

  @override
  void initState() {
    super.initState();
    _questions = List.from(QuizData.topicsQuestions[widget.topicName] ?? []);
    _questions.shuffle();

    if (widget.methodType == 'sprint') {
      _startSprintTimer();
    }
  }

  void _startSprintTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _finishQuiz();
      }
    });
  }

  void _onAnswerClick(int selectedIndex) {
    if (_isAnswered) return;

    final correctAnswer = _questions[_currentIndex]['correctIndex'];
    bool isCorrect = selectedIndex == correctAnswer;

    int pointsPerQuestion = 10;
    if (widget.methodType == 'sprint') pointsPerQuestion = 15;
    if (widget.methodType == 'exam') pointsPerQuestion = 25;

    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = selectedIndex;

      if (isCorrect) {
        _scoreEarned += pointsPerQuestion;
        _correctAnswersCount++;
      } else {
        if (widget.methodType == 'exam') {
          _lives--;
        }
      }
    });
  }

  void _goToNextQuestion() {
    setState(() {
      if (_lives <= 0) {
        _timer?.cancel();
        _finishQuiz(failedExam: true);
        return;
      }

      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
        _isAnswered = false;
        _selectedAnswerIndex = null;
      } else {
        _timer?.cancel();
        _finishQuiz();
      }
    });
  }

  void _finishQuiz({bool failedExam = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !failedExam) {
      try {
        // Оновлюємо XP
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'score': FieldValue.increment(_scoreEarned),
          'testsCount': FieldValue.increment(1), // +1 пройдений тест в статистику
        }, SetOptions(merge: true));
      } catch (e) {
        print("Помилка Firebase: $e");
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(failedExam ? 'Іспит провалено ❌' : 'Тест завершено! 🎉'),
        content: Text(
          failedExam
              ? 'У вас закінчилися життя. Спробуйте підготуватися краще через вкладку Навчання та повернутися знову!'
              : 'Ваш результат: $_correctAnswersCount/${_questions.length}\nЗароблено балів: +$_scoreEarned XP!',
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Супер', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('Питання відсутні.')));
    }

    final currentQuestion = _questions[_currentIndex];
    final options = currentQuestion['options'] as List<String>;
    final correctAnswerIndex = currentQuestion['correctIndex'] as int;
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        title: Text(widget.topicName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.methodType == 'sprint')
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Chip(
                avatar: const Icon(Icons.timer, size: 16, color: Colors.red),
                label: Text('$_timeLeft сек', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          if (widget.methodType == 'exam')
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < _lives ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  );
                }),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: Colors.blueAccent,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Text('Питання ${_currentIndex + 1} з ${_questions.length}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Блок питання
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                currentQuestion['question'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),

            //  фідбек (Правильно / Неправильно)
            if (_isAnswered)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: _selectedAnswerIndex == correctAnswerIndex ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedAnswerIndex == correctAnswerIndex ? Colors.green[200]! : Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedAnswerIndex == correctAnswerIndex ? Icons.check_circle : Icons.cancel,
                      color: _selectedAnswerIndex == correctAnswerIndex ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedAnswerIndex == correctAnswerIndex ? 'Правильна відповідь! 🎉' : 'Неправильно ❌',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedAnswerIndex == correctAnswerIndex ? Colors.green[900] : Colors.red[900],
                      ),
                    ),
                  ],
                ),
              ),

            // Варіанти відповідей
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  Color buttonColor = Colors.white;
                  Color textColor = Colors.black87;
                  IconData? rightIcon;

                  if (_isAnswered) {
                    if (index == correctAnswerIndex) {
                      buttonColor = Colors.green[100]!;
                      textColor = Colors.green[900]!;
                      rightIcon = Icons.check;
                    } else if (index == _selectedAnswerIndex) {
                      buttonColor = Colors.red[100]!;
                      textColor = Colors.red[900]!;
                      rightIcon = Icons.close;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ElevatedButton(
                      onPressed: () => _onAnswerClick(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: textColor,
                        elevation: _isAnswered ? 0 : 1,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: _isAnswered && (index == correctAnswerIndex || index == _selectedAnswerIndex)
                                ? textColor.withOpacity(0.3)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              options[index],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (rightIcon != null) Icon(rightIcon, size: 18, color: textColor),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _goToNextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentIndex == _questions.length - 1 ? 'Завершити' : 'Наступне питання',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}