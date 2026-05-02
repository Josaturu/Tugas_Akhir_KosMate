import 'package:flutter/material.dart';

class MonitoringCard extends StatelessWidget {
  final int total;
  final int terisi;
  final int kosong;

  const MonitoringCard({
    super.key,
    required this.total,
    required this.terisi,
    required this.kosong,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatCard(
            icon: Icons.home_rounded,
            value: total.toString(),
            label: 'Total Kamar',
            color: Colors.blue,
            subLabel: 'Semua unit',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSmallStatCard(
            icon: Icons.door_front_door_rounded,
            value: terisi.toString(),
            label: 'Terisi',
            color: Colors.red,
            subLabel: '${total > 0 ? (terisi / total * 100).toInt() : 0}% Okupansi',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSmallStatCard(
            icon: Icons.meeting_room_rounded,
            value: kosong.toString(),
            label: 'Kosong',
            color: Colors.green,
            subLabel: 'Siap sewa',
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required String subLabel,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Expanded(child: Text(subLabel, style: const TextStyle(color: Colors.grey, fontSize: 8), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }
}
