import 'package:flutter/material.dart';

class CheatSheetsScreen extends StatelessWidget {
  const CheatSheetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ІТ Шпаргалки', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Шпаргалка: Статус-коди HTTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(3)},
              children: const [
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Код', style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Значення / Опис', style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('200 OK')),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Запит успішно виконано сервером.')),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('400 Bad Req')),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Помилка клієнта. Невірний синтаксис запиту.')),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('404 Not Found')),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Сервер не може знайти затребуваний ресурс.')),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('500 Internal')),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Помилка сервера. Щось зламалося в коді бекенду.')),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}