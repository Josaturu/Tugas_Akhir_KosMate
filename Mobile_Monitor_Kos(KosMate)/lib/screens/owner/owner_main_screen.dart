import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../profile_screen.dart';
import 'owner_dashboard.dart';
import 'owner_user_list.dart';
import 'owner_transaction_list.dart';
import 'owner_complaint_list_screen.dart';
import 'kamar_form_screen.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({super.key});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int _currentIndex = 0;
  final GlobalKey<OwnerDashboardState> _dashboardKey = GlobalKey<OwnerDashboardState>();
  late PageController _pageController;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _pages = [
      OwnerDashboard(key: _dashboardKey, onTabChange: _onTap),
      const OwnerUserList(),
      const OwnerTransactionList(),
      const OwnerComplaintListScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }



  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
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
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const KamarFormScreen()));
          _dashboardKey.currentState?.refreshKamar();
        },
        backgroundColor: Colors.orange,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        isPremium: true,
        hasCenterBulge: false, // Flat untuk Owner sesuai referensi
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Penyewa'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.forum_rounded), label: 'Komplain'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Akun'),
        ],
      ),
    );
  }
}
