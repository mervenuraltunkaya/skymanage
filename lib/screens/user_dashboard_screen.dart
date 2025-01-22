import 'package:flutter/material.dart';
import 'user_evaluations_screen.dart';

class UserDashboardScreen extends StatelessWidget {
  final int userId;

  const UserDashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      endDrawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 10),
                const Text(
                  'SKYMANAGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.white),
              title: const Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop(); // Drawer'ı kapatır
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve logo kısmı
            Padding(
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
              child: Row(
                children: [
                  const Text(
                    'SKYMANAGE', // Başlık metni
                    style: TextStyle(
                      color: Color(0xFFE5E7EB),
                      fontSize: 28, // Yazı boyutu büyütüldü
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Neo Sans',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    'assets/logo.png', // Logo resmi
                    height: 40,
                    width: 40,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  Builder(
                    builder: (context) => IconButton(
                      icon:
                          const Icon(Icons.menu, color: Colors.white, size: 30),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            _menuItem(
              icon: Icons.assessment,
              title: 'Değerlendirmeler',
              subtitle: 'Kendi değerlendirme sonuçlarınızı görüntüleyin.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserEvaluationsScreen(userId: userId),
                  ),
                );
              },
            ),
            _menuItem(
              icon: Icons.feedback,
              title: 'Geri Dönüşler',
              subtitle: 'Henüz kullanılabilir değil.',
              onTap: null, // Şimdilik devre dışı
              isDisabled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF212A39),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Yuvarlak ikon arka planı
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF1E3A8A), // Lacivert yuvarlak arka plan
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: const Color(0xFF60A5FA), size: 30),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color:
                            isDisabled ? Colors.grey : const Color(0xFFFDFEFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDisabled ? Colors.grey : Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: isDisabled ? Colors.grey : const Color(0xFF60A5FA),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
