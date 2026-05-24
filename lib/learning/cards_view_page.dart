import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CardsViewPage extends StatefulWidget {
  final String topicTitle;
  final List<Map<String, String>> cards;

  const CardsViewPage({super.key, required this.topicTitle, required this.cards});

  @override
  State<CardsViewPage> createState() => _CardsViewPageState();
}

class _CardsViewPageState extends State<CardsViewPage> {
  late List<Map<String, String>> _activeCards;
  int _currentIndex = 0;
  bool _showFront = true;
  int _initialLength = 0;

  @override
  void initState() {
    super.initState();
    _activeCards = List.from(widget.cards);
    _initialLength = widget.cards.length;
  }

  void _nextCard(bool knewIt) async {
    if (knewIt) {

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
          final docSnapshot = await userDoc.get();

          if (!docSnapshot.exists) {
            await userDoc.set({
              'cardsCount': 1,
              'score': 10,
              'testsCount': 0,
            });
          } else {
            await userDoc.update({
              'cardsCount': FieldValue.increment(1),
              'score': FieldValue.increment(10),
            });
          }
          print("✅ Статистика карток успішно оновлена у Firebase!");
        } catch (e) {
          print("❌ Помилка Firebase при збереженні картки: $e");
        }
      }

      setState(() {
        _showFront = true;
        _activeCards.removeAt(_currentIndex);

        if (_activeCards.isEmpty) {
          _showSuccessDialog();
        } else if (_currentIndex >= _activeCards.length) {
          _currentIndex = 0;
        }
      });
    } else {
      setState(() {
        _showFront = true;
        if (_activeCards.length > 1) {
          final currentCard = _activeCards.removeAt(_currentIndex);
          _activeCards.add(currentCard);
        }
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Модуль завершено! 🎉'),
        content: const Text('Чудова робота! Ви успішно повторили всі картки з цієї теми. Прогрес збережено в статистику.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закриваємо діалог
              Navigator.pop(context); // Повертаємося назад
            },
            child: const Text('Супер', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_activeCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.topicTitle, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text('Усі картки вивчено!')),
      );
    }

    final currentCard = _activeCards[_currentIndex];
    final cardFrontText = currentCard['front'] ?? 'Немає тексту';
    final cardBackText = currentCard['back'] ?? 'Немає визначення';

    final learnedCount = _initialLength - _activeCards.length;
    final progress = _initialLength > 0 ? (learnedCount / _initialLength) : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.topicTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: Colors.green,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10)
            ),
            const SizedBox(height: 10),
            Text(
                'Залишилось карток: ${_activeCards.length}',
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 40),

            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showFront = !_showFront),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _showFront ? Colors.green[50] : Colors.teal[950],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showFront ? 'Натисніть, щоб побачити відповідь' : 'Визначення поняття',
                        style: TextStyle(
                            fontSize: 11,
                            color: _showFront ? Colors.green[900]!.withOpacity(0.6) : Colors.white70,
                            fontStyle: FontStyle.italic
                        ),
                      ),
                      const SizedBox(height: 24),
                      SingleChildScrollView(
                        child: Text(
                          _showFront ? cardFrontText : cardBackText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _showFront ? Colors.green[900] : Colors.white,
                              height: 1.4
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _nextCard(false),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  icon: const Icon(Icons.replay, size: 18),
                  label: const Text('Повторити'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _nextCard(true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Знаю!'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}