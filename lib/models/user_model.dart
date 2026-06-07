class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final int totalScore;
  final int quizzesCompleted;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.totalScore,
    required this.quizzesCompleted,
    required this.createdAt,
  });

  // Середній бал
  double get averageScore {
    if (quizzesCompleted == 0) return 0;
    return (totalScore / quizzesCompleted * 100).roundToDouble();
  }

  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'Користувач',
      totalScore: data['totalScore'] ?? 0,
      quizzesCompleted: data['quizzesCompleted'] ?? 0,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'totalScore': totalScore,
      'quizzesCompleted': quizzesCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}