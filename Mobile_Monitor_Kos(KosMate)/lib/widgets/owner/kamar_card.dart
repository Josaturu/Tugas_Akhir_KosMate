import 'package:flutter/material.dart';
import '../../models/kamar_model.dart';
import '../../screens/owner/room_detail_screen.dart';
import '../../utils/formatters.dart';

class KamarCard extends StatelessWidget {
  final dynamic json;
  const KamarCard({super.key, required this.json});

  @override
  Widget build(BuildContext context) {
    final Kamar kamarObj = Kamar.fromJson(json);
    bool isKosong = kamarObj.status.toLowerCase() == 'kosong';
    final Color statusColor = isKosong ? Colors.green : Colors.red;
    
    // Simulasi data penghuni dan lantai dari JSON jika ada
    final String floor = json['lantai']?.toString() ?? 'Lantai 1';
    
    String tenantName = isKosong ? 'Kosong' : 'Penghuni Aktif';
    final activeTenant = json['penyewa_aktif'];
    if (activeTenant is Map && activeTenant.containsKey('name')) {
      tenantName = activeTenant['name']?.toString() ?? tenantName;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RoomDetailScreen(kamar: kamarObj))),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black.withOpacity(0.03)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Foto Kamar di Kiri
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: statusColor.withOpacity(0.05),
                    child: Stack(
                      children: [
                        const Center(child: Icon(Icons.image_outlined, color: Colors.grey, size: 30)),
                        Positioned(
                          top: 5,
                          left: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(5)),
                            child: Text(kamarObj.nomorKamar, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                
                // Info Tengah
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kamar ${kamarObj.nomorKamar}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(floor, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person_rounded, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tenantName, 
                              style: TextStyle(color: Colors.grey[600], fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Info Kanan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.more_vert, color: Colors.grey, size: 18),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        isKosong ? 'Kosong' : 'Terisi',
                        style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${CurrencyFormat.convertToIdr(kamarObj.hargaSewa, 0)} / bulan',
                      style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
