import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'auth/login_screen.dart';
import '../widgets/global_sliver_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<dynamic> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.orange)));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }

        final user = snapshot.data;
        final name = user?['name']?.toString() ?? 'User';
        final role = user?['role']?.toString() ?? 'penghuni';

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header Profil Modern
              GlobalSliverHeader(
                centerContent: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      role == 'pemilik' ? 'Pemilik Kos' : 'Penghuni Kos',
                      style: const TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1),
                    ),
                  ],
                ),
              ),

              // Konten Profil
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 50),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionTitle('Informasi Akun'),
                    const SizedBox(height: 15),
                    _buildInfoCard(Icons.phone_iphone_rounded, 'Nomor Handphone', user?['no_hp'] ?? '-', Colors.blue),
                    _buildInfoCard(Icons.email_rounded, 'Alamat Email', user?['email'] ?? '-', Colors.green),
                    _buildInfoCard(Icons.verified_user_rounded, 'Tipe Akun', role.toUpperCase(), Colors.purple),
                    
                    const SizedBox(height: 35),
                    _buildSectionTitle('Keamanan & Aksi'),
                    const SizedBox(height: 15),
                    _buildActionCard(
                      icon: Icons.lock_reset_rounded,
                      title: 'Ganti Password',
                      onTap: () {},
                      color: Colors.orange,
                    ),
                    _buildActionCard(
                      icon: Icons.logout_rounded,
                      title: 'Keluar dari Aplikasi',
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      color: Colors.red,
                      isLast: true,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required VoidCallback onTap, required Color color, bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: color.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 15),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.5), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
