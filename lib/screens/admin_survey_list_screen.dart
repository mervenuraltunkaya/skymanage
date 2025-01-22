import 'package:flutter/material.dart';
import 'create_survey_screen.dart';
import 'survey_list_screen.dart';
import 'completed_surveys_screen.dart';
import 'user_management_screen.dart';
import 'login_screen.dart';

class AdminSurveyListScreen extends StatefulWidget {
  final int adminId;

  const AdminSurveyListScreen({Key? key, required this.adminId})
      : super(key: key);

  @override
  State<AdminSurveyListScreen> createState() => _AdminSurveyListScreenState();
}

class _AdminSurveyListScreenState extends State<AdminSurveyListScreen> {
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
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const GirisSayfasi(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'SKYMANAGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Image.asset(
                  'assets/logo.png',
                  height: 50,
                  width: 50,
                ),
                const Spacer(),
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            _menuItem(
              icon: Icons.help_outline,
              title: 'Yetkinlik Soru Seti Oluştur',
              subtitle: 'Yeni bir yetkinlik değerlendirme seti oluşturun',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateSurveyScreen(
                      adminId: widget.adminId,
                    ),
                  ),
                );
              },
            ),
            _menuItem(
              icon: Icons.bar_chart_outlined,
              title: 'Yetkinlik Soru Setleri Güncelleme',
              subtitle: 'Mevcut setleri düzenleyin ve yönetin',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurveyListScreen(
                      adminId: widget.adminId,
                    ),
                  ),
                );
              },
            ),
            _menuItem(
              icon: Icons.description_outlined,
              title: 'Sonuç Raporları',
              subtitle: 'Değerlendirme sonuçlarını inceleyin',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompletedSurveysScreen(
                      userId: widget.adminId,
                    ),
                  ),
                );
              },
            ),
            _menuItem(
              icon: Icons.person_outline,
              title: 'Kullanıcı Yönetimi',
              subtitle: 'Kullanıcıları yönetin ve düzenleyin',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserManagementScreen(
                      adminId: widget.adminId,
                    ),
                  ),
                );
              },
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
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF212A39),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 6,
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
                      style: const TextStyle(
                        color: Color(0xFFFDFEFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(Icons.arrow_forward_ios,
                    color: Color(0xFF60A5FA), size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
