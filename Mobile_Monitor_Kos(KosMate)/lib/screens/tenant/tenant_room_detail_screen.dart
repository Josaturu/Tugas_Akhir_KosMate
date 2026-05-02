import 'package:flutter/material.dart';
import '../../widgets/global_sliver_header.dart';
import '../../widgets/animations.dart';
import '../../utils/formatters.dart';

class TenantRoomDetailScreen extends StatelessWidget {
  final Map<String, dynamic> kamar;
  final Map<String, dynamic> tenancy;

  const TenantRoomDetailScreen({super.key, required this.kamar, required this.tenancy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          GlobalSliverHeader(
            title: 'Kamar ${kamar['nomor_kamar']}',
            subtitle: 'Status Sewa: AKTIF',
            showBackButton: true,
            expandedHeight: 160,
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const DelayedFadeIn(
                  delay: 100,
                  child: Text('Fasilitas & Detail Kamar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                ),
                const SizedBox(height: 20),
                DelayedFadeIn(delay: 200, child: _buildInfoCard(Icons.king_bed_rounded, 'Tipe Kamar', kamar['tipe_kamar'], Colors.blue)),
                DelayedFadeIn(
                  delay: 300, 
                  child: _buildInfoCard(
                    Icons.payments_rounded, 
                    'Harga Sewa', 
                    CurrencyFormat.convertToIdr(double.parse(kamar['harga_sewa'].toString()), 0), 
                    Colors.green
                  )
                ),
                DelayedFadeIn(delay: 400, child: _buildInfoCard(Icons.description_rounded, 'Keterangan', kamar['keterangan'] ?? 'Tidak ada keterangan tambahan', Colors.orange)),
                
                const SizedBox(height: 35),
                const DelayedFadeIn(
                  delay: 500,
                  child: Text('Informasi Sewa Saya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                ),
                const SizedBox(height: 20),
                DelayedFadeIn(delay: 600, child: _buildInfoCard(Icons.calendar_today_rounded, 'Tanggal Masuk', tenancy['tanggal_masuk'], Colors.purple)),
                DelayedFadeIn(delay: 700, child: _buildInfoCard(Icons.timer_rounded, 'Durasi Sewa', '${tenancy['lama_sewa']} Bulan', Colors.teal)),
                DelayedFadeIn(delay: 800, child: _buildInfoCard(Icons.event_available_rounded, 'Berakhir Pada', tenancy['tanggal_selesai'], Colors.red)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
