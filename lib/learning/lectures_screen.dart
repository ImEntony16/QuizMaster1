import 'package:flutter/material.dart';

class LecturesScreen extends StatelessWidget {
  const LecturesScreen({super.key});

  final List<Map<String, String>> _lectures = const [
    {
      'title': 'Лекція 1: Архітектура Flutter та Дерево Віджетів',
      'content': 'Flutter базується на трьох деревах: Widget Tree (конфігурація інтерфейсу), Element Tree (зв\'язуюча ланка та логіка) та RenderObject Tree (фізичне малювання пікселів на екрані).\n\nКоли ви викликаєте setState(), Flutter маркує елемент як "брудний" і оновлює лише змінені частини інтерфейсу, що забезпечує швидкість 60-120 FPS.'
    },
    {
      'title': 'Лекція 2: Що таке Індекси в Базах Даних (SQL)?',
      'content': 'Індекс у БД — це спеціальна структура (найчастіше B-Tree), яка створюється для прискорення пошуку рядків у таблиці. \n\nБез індексу СУБД робить повне сканування таблиці (Full Table Scan), що дуже повільно. Проте, індекси уповільнюють операції запису (INSERT, UPDATE), адже базу доводиться щоразу перебудовувати.'
    },
    {
      'title': 'Лекція 3: Принципи ООП простими словами',
      'content': '1. Інкапсуляція — ховаємо змінні всередині класу за допомогою private (_), даємо доступ через сетери/гетери.\n2. Успадкування — створюємо клас "Автомобіль" на основі класу "Транспорт".\n3. Поліморфізм — метод "рухатися()" працює по-різному для Літака та Човна.\n4. Абстракція — виділяємо лише важливе (наприклад, для користувача є кнопка "Старт", а як працює двигун — приховано).'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конспекти & Лекції', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _lectures.length,
        itemBuilder: (context, index) {
          final lecture = _lectures[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              leading: const Icon(Icons.menu_book, color: Colors.blue),
              title: Text(lecture['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    lecture['content']!,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}