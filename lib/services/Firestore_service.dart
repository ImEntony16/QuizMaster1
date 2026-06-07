import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;



  // Створити профіль користувача при реєстрації
  Future<void> createUserProfile(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.email?.split('@')[0] ?? 'Користувач',
        totalScore: 0,
        quizzesCompleted: 0,
        createdAt: DateTime.now(),
      );

      await userRef.set(profile.toMap());
    }
  }

  Stream<UserProfile?> getCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'displayName': displayName,
    });
  }

  Future<void> updateQuizStats(int score, int maxScore) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await createUserProfile(user);
    }

    await userRef.update({
      'totalScore': FieldValue.increment(score),
      'quizzesCompleted': FieldValue.increment(1),
    });
  }

  Stream<List<UserProfile>> getTopUsers({int limit = 10}) {
    return _firestore
        .collection('users')
        .orderBy('totalScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<int> getUserRank(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) return 0;

    final userScore = userDoc.data()?['totalScore'] ?? 0;

    final higherScores = await _firestore
        .collection('users')
        .where('totalScore', isGreaterThan: userScore)
        .get();

    return higherScores.docs.length + 1;
  }




  Future<void> seedDummyUsers({int count = 15, int minExisting = 3}) async {
    final usersCol = _firestore.collection('users');

    final existing = await usersCol.limit(minExisting).get();
    if (existing.docs.length >= minExisting) return;

    final rnd = Random();

    final sampleNames = [
      "andriy",
      "maria",
      "oleh",
      "vika",
      "ivan",
      "sofia",
      "artem",
      "dmytro",
      "nazar",
      "anna",
      "oleksii",
      "bogdan",
      "olena",
      "yaroslav",
      "katya",
      "vlad",
      "oksana",
      "taras"
    ];

    final batch = _firestore.batch();

    for (int i = 0; i < count; i++) {
      final name = sampleNames[rnd.nextInt(sampleNames.length)];
      final num = rnd.nextInt(900) + 100;

      final docRef = usersCol.doc('demo_user_${i}_$num');

      batch.set(docRef, {
        'uid': docRef.id,
        'email': '$name$num@example.com',
        'displayName': '${name[0].toUpperCase()}${name.substring(1)} $num',
        'totalScore': rnd.nextInt(900) + 100,
        'quizzesCompleted': rnd.nextInt(12) + 1,
        'createdAt': FieldValue.serverTimestamp(),
        'isDemo': true,
      });
    }

    await batch.commit();
  }

  Future<void> clearDemoUsers() async {
    final snap = await _firestore
        .collection('users')
        .where('isDemo', isEqualTo: true)
        .get();

    final batch = _firestore.batch();

    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }


  Future<void> addQuiz({
    required String title,
    required String description,
    List<Map<String, dynamic>> questions = const [],
    String? category,
    String? level,
  }) async {
    await _firestore.collection('quizzes').add({
      'title': title,
      'description': description,
      'category': category ?? 'Загальні',
      'level': level ?? 'easy',
      'questions': questions,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isDemo': false,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getQuizzes() {
    return _firestore
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> seedDummyQuizzes({int count = 10, int minExisting = 3}) async {
    final col = _firestore.collection('quizzes');
    final existing = await col.limit(minExisting).get();

    if (existing.docs.length >= minExisting) return;

    final titles = [
      'Основи програмування',
      'Flutter Basics',
      'ООП для всіх',
      'Git практикум',
      'SQL Intro',
      'JS базовий',
      'HTTP & REST',
      'Linux CLI',
      'Dart синтаксис',
      'DevOps Intro'
    ];

    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();

    for (int i = 0; i < count; i++) {
      final doc = col.doc('demo_quiz_$i');
      batch.set(doc, {
        'title': '${titles[i % titles.length]} #$i',
        'description': 'Демонстраційний квіз для перегляду списку',
        'category': 'Demo',
        'level': 'easy',
        'questions': const [],
        'createdAt': now,
        'updatedAt': now,
        'isDemo': true,
      });
    }

    await batch.commit();
  }
}
