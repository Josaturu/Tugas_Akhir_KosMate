import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'tenant_room_detail_screen.dart';
import '../notification_screen.dart';
import '../../widgets/animations.dart';
import '../../widgets/global_sliver_header.dart';
import '../../widgets/notification_bell.dart';
import 'tenant_transaction_list.dart';
import 'tenant_complaint_screen.dart';
import '../../utils/formatters.dart';
import '../../widgets/quick_menu_grid.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> with AutomaticKeepAliveClientMixin {
  late Future<dynamic> _tenancyFuture;
  late Future<dynamic> _pembayaranFuture;
  late Future<dynamic> _profileFuture;

  @override
  bool get wantKeepAlive => true; // Menjaga state agar tidak hancur saat pindah tab

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _tenancyFuture = ApiService.getMyTenancy();
      _pembayaranFuture = ApiService.getPembayaran();
      _profileFuture = ApiService.getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Wajib dipanggil
    return FutureBuilder<dynamic>(
      future: Future.wait([_tenancyFuture, _pembayaranFuture, _profileFuture]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: ErrorStateWidget(
              onRetry: () => _refreshData(),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                _buildHeader('...'),
                const SliverToBoxAdapter(
                  child: DashboardSkeleton(isOwner: false),
                ),
              ],
            ),
          );
        }

        final dataTenancy = snapshot.data?[0];
        final dataProfile = snapshot.data?[2];
        final dataPembayaran = snapshot.data?[1];
        
        final hasTenancy = dataTenancy != null && dataTenancy['message'] == null;
        final name = dataProfile != null ? (dataProfile['name'] ?? 'Penyewa') : 'Penyewa';

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: RefreshIndicator(
            onRefresh: () async => _refreshData(),
            color: Colors.orange,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(name),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        if (hasTenancy) _buildKamarCard(dataTenancy) else _buildEmptyTenancyCard(),
                        const SizedBox(height: 18),
                        _buildBillingSummarySection(dataPembayaran, dataTenancy, hasTenancy),
                        const SizedBox(height: 22),
                        const DelayedFadeIn(
                          delay: 300,
                          child: Text('Menu Utama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const SizedBox(height: 8),
                        _buildMenuGrid(),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tagihan Terbaru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TenantTransactionList())),
                              child: const Text('Lihat Semua', style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        _buildRecentBillsList(dataPembayaran),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String name) {
    return GlobalSliverHeader(
      title: 'Halo, $name 👋',
      subtitle: 'Selamat datang kembali!',
      actions: const [
        NotificationBell(),
        SizedBox(width: 15),
      ],
    );
  }

  Widget _buildKamarCard(dynamic data) {
    final kamar = data['kamar'];
    return DelayedFadeIn(
      delay: 100,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.door_front_door_rounded, color: Colors.orange, size: 35),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Unit Kamar', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text('Kamar ${kamar['nomor_kamar']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(kamar['tipe_kamar'] ?? 'Lantai 1', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
                  child: const Text('Aktif', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Terdaftar Sejak', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(data['tanggal_masuk'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TenantRoomDetailScreen(kamar: kamar, tenancy: data))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                  child: const Row(
                    children: [
                      Text('Detail Kamar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 5),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingSummarySection(dynamic data, dynamic dataTenancy, bool hasTenancy) {
    final payments = data as List? ?? [];
    
    // Logika Status Tagihan
    String statusTitle = 'Tagihan Bulan Ini';
    String statusValue = 'Lunas';
    String dueDate = '-';
    Color valueColor = Colors.green;

    if (!hasTenancy) {
      statusValue = 'Belum Aktif';
      statusTitle = 'Penyewaan';
      valueColor = Colors.grey;
    } else if (payments.isEmpty) {
      statusValue = 'Belum Ada Tagihan';
      valueColor = Colors.blue;
    } else {
      final pending = payments.firstWhere((p) => p['status'] != 'lunas', orElse: () => null);
      if (pending != null) {
        statusValue = CurrencyFormat.convertToIdr(double.parse(pending['jumlah'].toString()), 0);
        dueDate = pending['periode']?.toString().substring(0, 10) ?? '-';
        valueColor = Colors.deepOrange;
      } else {
        statusValue = 'Lunas';
        dueDate = dataTenancy != null && dataTenancy['tanggal_selesai'] != null
            ? dataTenancy['tanggal_selesai'].toString().substring(0, 10)
            : '-';
        valueColor = Colors.green;
      }
    }

    return DelayedFadeIn(
      delay: 200,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statusTitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    statusValue,
                    style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 35, color: Colors.grey[100]),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jatuh Tempo', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(dueDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            Material(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TenantTransactionList())),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return QuickMenuGrid(
      menus: [
        QuickMenuItem(icon: Icons.payments_rounded, label: 'Tagihan', color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TenantTransactionList()))),
        QuickMenuItem(icon: Icons.forum_rounded, label: 'Komplain', color: Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TenantComplaintScreen()))),
        QuickMenuItem(icon: Icons.headset_mic_rounded, label: 'Bantuan', color: Colors.blue, onTap: () => _showContactOwner(context)),
        QuickMenuItem(icon: Icons.notifications_rounded, label: 'Pengumuman', color: Colors.amber, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()))),
        QuickMenuItem(icon: Icons.info_outline_rounded, label: 'Info Kos', color: Colors.cyan, onTap: () {}),
        QuickMenuItem(icon: Icons.settings_rounded, label: 'Pengaturan', color: Colors.blueGrey, onTap: () {}),
      ],
    );
  }

  Widget _buildRecentBillsList(dynamic data) {
    final payments = data as List? ?? [];
    if (payments.isEmpty) return const Center(child: Text('Tidak ada riwayat tagihan', style: TextStyle(color: Colors.grey, fontSize: 11)));
    return Column(children: payments.take(3).map((p) => _buildRecentBillItem(p)).toList());
  }

  Widget _buildRecentBillItem(dynamic p) {
    final isLunas = p['status'] == 'lunas';
    return DelayedFadeIn(
      delay: 500,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TenantTransactionList())),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: (isLunas ? Colors.green : Colors.orange).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.receipt_rounded, color: isLunas ? Colors.green : Colors.orange, size: 18),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tagihan ${p['periode']?.toString().substring(0, 7) ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Text('Tagihan Bulanan', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(CurrencyFormat.convertToIdr(double.parse(p['jumlah'].toString()), 0), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isLunas ? Colors.green : Colors.deepOrange)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: (isLunas ? Colors.green : Colors.orange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(isLunas ? 'Lunas' : 'Belum Bayar', style: TextStyle(color: isLunas ? Colors.green : Colors.orange, fontSize: 7, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTenancyCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: const Column(
        children: [
          Icon(Icons.bed_rounded, size: 45, color: Colors.grey),
          SizedBox(height: 8),
          Text('Belum ada sewa aktif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text('Hubungi pemilik kos', style: TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  void _showContactOwner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
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
}
