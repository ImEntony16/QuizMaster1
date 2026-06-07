import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizmaster/pages/statistics_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;


  void _showChangeNicknameDialog(String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Змінити нікнейм'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Введіть новий нікнейм",
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty && user != null) {
                final newName = controller.text.trim();

                try {
                  await user!.updateDisplayName(newName);
                  await user!.reload();

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .update({
                    'name': newName,
                    'displayName': newName,
                  });
                } catch (e) {
                  print("Помилка при зміні нікнейму: $e");
                }

                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Зберегти', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _resetPassword() async {
    if (user != null && user!.email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.mail_outline_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text("Посилання для зміни пароля надіслано на ${user!.email}"),
                  ),
                ],
              ),
              backgroundColor: Colors.deepPurple[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Помилка: ${e.toString()}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  String _formatRegistrationDate(Map<String, dynamic> data) {
    final createdAtData = data['createdAt'] ??
        data['date'] ??
        data['registrationDate'] ??
        data['dateRegistration'];

    if (createdAtData == null) {
      return "28 листопада 2025";
    }

    if (createdAtData is String) {
      return createdAtData;
    }

    if (createdAtData is Timestamp) {
      DateTime date = createdAtData.toDate();
      String day = date.day.toString().padLeft(2, '0');
      String month = date.month.toString().padLeft(2, '0');
      String year = date.year.toString();
      return "$day.$month.$year";
    }

    return "28 листопада 2025";
  }

  void _logout() async {
    try {
      if (mounted) {
        Navigator.pop(context);
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Помилка при виході з акаунта: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        title: const Text('Профіль', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          String name = "Користувач";
          String email = user?.email ?? "Не вказано";
          int score = 0;
          Map<String, dynamic> userData = {};

          if (snapshot.hasData && snapshot.data!.exists) {
            userData = snapshot.data!.data() as Map<String, dynamic>;
            name = userData['displayName'] ?? userData['name'] ?? "Користувач";
            score = userData['score'] ?? 0;
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [

                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
                            ]
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF673AB7), Color(0xFF8E24AA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : "U",
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Рівень досвіду: $score XP",
                        style: TextStyle(fontSize: 13, color: Colors.deepPurple[400], fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                _buildSectionTitle("ОСОБИСТІ ДАНІ"),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      _buildProfileInfoItem(Icons.person_outline_rounded, "Нікнейм", name),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE), thickness: 0.5),
                      ),
                      _buildProfileInfoItem(Icons.mail_outline_rounded, "Ел. пошта", email),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE), thickness: 0.5),
                      ),

                      // Дата реєстрації
                      _buildProfileInfoItem(
                        Icons.calendar_today_outlined,
                        "Дата реєстрації",
                        _formatRegistrationDate(userData),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),


                _buildSectionTitle("ІНСТРУМЕНТИ АКАУНТУ"),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      // Редагування імені
                      _buildActionItem(
                        icon: Icons.edit_rounded,
                        title: "Змінити нікнейм",
                        accentColor: Colors.deepPurple,
                        onTap: () => _showChangeNicknameDialog(name),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),

                      // Зміна пароля
                      _buildActionItem(
                        icon: Icons.lock_outline_rounded,
                        title: "Змінити пароль акаунта",
                        accentColor: Colors.redAccent,
                        onTap: _resetPassword,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),

                      // Статистика навчання
                      _buildActionItem(
                        icon: Icons.bar_chart_rounded,
                        title: "Статистика навчання",
                        accentColor: Colors.orange[700]!,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),

                      // Про додаток / Версія
                      _buildInfoRow(
                        icon: Icons.info_outline_rounded,
                        title: "Про додаток",
                        value: "v1.0.5 (Реліз)",
                        accentColor: Colors.blue,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),


                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text("Вийти з акаунта", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      side: BorderSide(color: Colors.red[200]!, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black38, letterSpacing: 1.5),
        ),
      ),
    );
  }

  Widget _buildProfileInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black38, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width - 120,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: accentColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D))),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black26),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color accentColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: accentColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D))),
      trailing: Text(
        value,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[500]),
      ),
    );
  }
}