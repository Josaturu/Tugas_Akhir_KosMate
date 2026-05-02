import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'owner_report_screen.dart';
import 'owner_announcement_screen.dart';
import 'owner_complaint_list_screen.dart';
import 'owner_transaction_list.dart';
import '../../widgets/global_sliver_header.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/owner/monitoring_card.dart';
import '../../widgets/owner/kamar_card.dart';
import '../../widgets/quick_menu_grid.dart';

class OwnerDashboard extends StatefulWidget {
  final Function(int)? onTabChange;
  const OwnerDashboard({super.key, this.onTabChange});

  @override
  State<OwnerDashboard> createState() => OwnerDashboardState();
}

class OwnerDashboardState extends State<OwnerDashboard>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> _allKamar = [];
  List<dynamic> _filteredKamar = [];
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    refreshKamar();
    loadProfile();
  }

  void loadProfile() async {
    try {
      final data = await ApiService.getProfile();
      if (mounted) setState(() => _userData = data);
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  void refreshKamar() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getKamar();
      if (mounted) {
        setState(() {
          final List rawData = (data is List) ? data : [];
          _allKamar = rawData.where((item) => item != null).toList();
          _filteredKamar = _allKamar;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data kamar: $e')));
      }
    }
  }

  void _filterKamar(String query) {
    setState(() {
      _filteredKamar = _allKamar
          .where(
            (k) => k['nomor_kamar'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async => refreshKamar(),
        color: Colors.orange,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildSearchAndFilter(),
                    const SizedBox(height: 25),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monitoring Kamar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Diperbarui baru saja',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    MonitoringCard(
                      total: _allKamar.length,
                      terisi: _allKamar
                          .where(
                            (k) =>
                                k['status']?.toString().toLowerCase() ==
                                'terisi',
                          )
                          .length,
                      kosong: _allKamar
                          .where(
                            (k) =>
                                k['status']?.toString().toLowerCase() ==
                                'kosong',
                          )
                          .length,
                    ),
                    const SizedBox(height: 25),
                    _buildQuickMenuGrid(),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daftar Kamar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Row(
                            children: [
                              Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.orange,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final itemData = _filteredKamar[index];
                    if (itemData == null) return const SizedBox.shrink();
                    return KamarCard(json: itemData);
                  }, childCount: _filteredKamar.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final name = _userData?['name'] ?? 'Bapak Kos';
    return GlobalSliverHeader(
      title: 'Halo, $name! 👋',
      subtitle: 'Kelola kosan kamu hari ini',
      headerAvatar: GestureDetector(
        onTap: () {
          if (widget.onTabChange != null) {
            widget.onTabChange!(4);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Text(
              (name.isNotEmpty) ? name[0].toUpperCase() : 'B',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
      actions: const [NotificationBell(), SizedBox(width: 15)],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _filterKamar,
              decoration: const InputDecoration(
                hintText: 'Cari kamar atau penyewa...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur Filter akan segera hadir!'),
                ),
              );
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[100]!),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune_rounded, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenuGrid() {
    return QuickMenuGrid(
      menus: [
        QuickMenuItem(
          icon: Icons.people_alt_rounded,
          label: 'Penyewa',
          color: Colors.orange,
          onTap: () {
            if (widget.onTabChange != null) {
              widget.onTabChange!(1);
            }
          },
        ),
        QuickMenuItem(
          icon: Icons.receipt_long_rounded,
          label: 'Tagihan',
          color: Colors.amber,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OwnerTransactionList(),
              ),
            );
          },
        ),
        QuickMenuItem(
          icon: Icons.assessment_rounded,
          label: 'Laporan',
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OwnerReportScreen(),
              ),
            );
          },
        ),
        QuickMenuItem(
          icon: Icons.campaign_rounded,
          label: 'Pengumuman',
          color: Colors.red,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OwnerAnnouncementScreen(),
              ),
            );
          },
        ),
        QuickMenuItem(
          icon: Icons.forum_rounded,
          label: 'Komplain',
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OwnerComplaintListScreen(),
              ),
            );
          },
        ),
        QuickMenuItem(
          icon: Icons.settings_rounded,
          label: 'Pengaturan',
          color: Colors.blueGrey,
          onTap: () {},
        ),
      ],
    );
  }
}
