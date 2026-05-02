import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../profile_screen.dart';

import 'tenant_dashboard.dart';
import 'tenant_transaction_list.dart';
import 'tenant_complaint_screen.dart';
class TenantMainScreen extends StatefulWidget {
  const TenantMainScreen({super.key});

  @override
  State<TenantMainScreen> createState() => _TenantMainScreenState();
}

class _TenantMainScreenState extends State<TenantMainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  // Simpan pages agar tidak re-init setiap build
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _pages = [
      const TenantDashboard(),
      const TenantTransactionList(),
      const SizedBox.shrink(), // Dummy index untuk Bantuan (Tengah)
      const TenantComplaintScreen(), // Komplain (Index 3)
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showContactOwner() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 25),
            const Text('Hubungi Pemilik Kos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.phone, color: Colors.white)),
              title: const Text('WhatsApp'),
              subtitle: const Text('Hubungi via WhatsApp untuk respon lebih cepat'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.call, color: Colors.white)),
              title: const Text('Telepon Langsung'),
              subtitle: const Text('Hubungi nomor pemilik kos untuk keadaan darurat'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        isPremium: true,
        onTap: (index) {
          if (index == 2) {
            _showContactOwner();
          } else {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index, 
              duration: const Duration(milliseconds: 400), 
              curve: Curves.easeInOutQuart,
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Tagihan'),
          BottomNavigationBarItem(icon: Icon(Icons.headset_mic_rounded), label: 'Bantuan'),
          BottomNavigationBarItem(icon: Icon(Icons.forum_rounded), label: 'Komplain'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Akun'),
        ],
      ),
    );
  }
}
