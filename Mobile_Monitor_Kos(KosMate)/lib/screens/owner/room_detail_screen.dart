import 'package:flutter/material.dart';
import '../../models/kamar_model.dart';
import '../../services/api_service.dart';
import 'kamar_form_screen.dart';
import 'add_tenancy_screen.dart';
import '../../utils/formatters.dart';
import '../../widgets/global_sliver_header.dart';
import '../../widgets/animations.dart';

class RoomDetailScreen extends StatefulWidget {
  final Kamar kamar;

  const RoomDetailScreen({super.key, required this.kamar});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late Kamar _kamar;
  dynamic _tenancyData;
  bool _isLoadingTenancy = false;

  @override
  void initState() {
    super.initState();
    _kamar = widget.kamar;
    if (_kamar.status.toLowerCase() == 'terisi') {
      _fetchTenancyDetail();
    }
  }

  void _fetchTenancyDetail() async {
    setState(() => _isLoadingTenancy = true);
    try {
      final response = await ApiService.getKamarDetail(_kamar.id!);
      setState(() {
        final data = response['data'] ?? response;
        _kamar = Kamar.fromJson(data);
        final List<dynamic> penyewaans = data['penyewaans'] ?? [];
        _tenancyData = penyewaans.isNotEmpty ? penyewaans.last : null;
        _isLoadingTenancy = false;
      });
    } catch (e) {
      setState(() => _isLoadingTenancy = false);
      debugPrint('Error fetching tenancy: $e');
    }
  }

  void _refreshKamar() async {
    try {
      final response = await ApiService.getKamarDetail(_kamar.id!);
      setState(() {
        final data = response['data'] ?? response;
        _kamar = Kamar.fromJson(data);
        if (_kamar.status.toLowerCase() == 'terisi') {
          final List<dynamic> penyewaans = data['penyewaans'] ?? [];
          _tenancyData = penyewaans.isNotEmpty ? penyewaans.last : null;
        } else {
          _tenancyData = null;
        }
      });
    } catch (e) {
      debugPrint('Error refreshing room: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async => _refreshKamar(),
        color: Colors.orange,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // Global Header with Back Button
            GlobalSliverHeader(
              title: 'Detail Kamar ${_kamar.nomorKamar}',
              subtitle: _kamar.tipeKamar ?? '-',
              showBackButton: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => KamarFormScreen(kamar: _kamar)),
                      );
                      if (result == true) _refreshKamar();
                    },
                  ),
                ),
              ],
            ),

            // Content Section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  DelayedFadeIn(delay: 100, child: _buildRoomCard()),
                  const SizedBox(height: 25),
                  if (_kamar.status.toLowerCase() == 'terisi')
                    DelayedFadeIn(delay: 200, child: _buildTenantSection())
                  else
                    DelayedFadeIn(delay: 200, child: _buildEmptyState()),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard() {
    final isTerisi = _kamar.status.toLowerCase() == 'terisi';
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Informasi Kamar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(height: 1, color: Color(0xFFF5F5F5)),
          ),
          _buildInfoRow('Nomor Kamar', _kamar.nomorKamar),
          _buildInfoRow('Tipe Kamar', _kamar.tipeKamar ?? '-'),
          _buildInfoRow('Harga Sewa', CurrencyFormat.convertToIdr(_kamar.hargaSewa, 0)),
          _buildInfoRow('Status Kamar', _kamar.status.toUpperCase(), 
            color: isTerisi ? Colors.red : Colors.green),
          _buildInfoRow('Keterangan', _kamar.keterangan ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Flexible(
            child: Text(
              value, 
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14, letterSpacing: 0.3)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantSection() {
    if (_isLoadingTenancy) return const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: Colors.orange)));
    
    final user = _tenancyData?['user'];
    if (user == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Text('Gagal memuat data penghuni'),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.people_alt_rounded, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Penghuni Saat Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(height: 1, color: Color(0xFFF5F5F5)),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.orange.withOpacity(0.1),
                child: Text(
                  (user['name'] != null && user['name'].toString().isNotEmpty)
                      ? user['name'].toString().substring(0, 1).toUpperCase()
                      : 'U',
                  style: const TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(user['email'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildInfoRow('Tanggal Masuk', _tenancyData['tanggal_masuk'] ?? '-'),
          _buildInfoRow('Lama Sewa', '${_tenancyData['lama_sewa']} Bulan'),
          _buildInfoRow('Kontak', user['no_hp'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Icon(Icons.person_add_rounded, size: 70, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 20),
          const Text('Kamar Kosong', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87)),
          const SizedBox(height: 8),
          const Text('Belum ada penyewa di kamar ini', style: TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTenancyScreen(kamar: _kamar)),
              );
              if (result == true) _refreshKamar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            child: const Text('DAFTARKAN PENYEWA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }
}
