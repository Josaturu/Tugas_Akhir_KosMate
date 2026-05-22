import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/global_sliver_header.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';

class OwnerComplaintListScreen extends StatefulWidget {
  const OwnerComplaintListScreen({super.key});

  @override
  State<OwnerComplaintListScreen> createState() => _OwnerComplaintListScreenState();
}

class _OwnerComplaintListScreenState extends State<OwnerComplaintListScreen> {
  late Future<dynamic> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _refreshComplaints();
  }

  void _refreshComplaints() {
    setState(() {
      _complaintsFuture = ApiService.getComplaints();
    });
  }

  void _updateStatus(int id, String newStatus) async {
    try {
      await ApiService.updateComplaintStatus(id, newStatus);
      SnackbarHelper.showSuccess(context, 'Status komplain diperbarui');
      _refreshComplaints();
    } catch (e) {
      SnackbarHelper.showError(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<dynamic>(
        future: _complaintsFuture,
        builder: (context, snapshot) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const GlobalSliverHeader(
                title: 'Daftar Komplain',
                subtitle: 'Tanggapi keluhan penyewa dengan cepat',
                showBackButton: true,
              ),

              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverToBoxAdapter(
                  child: ListSkeleton(itemCount: 4),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: ErrorStateWidget(
                    errorMessage: 'Gagal mengambil data komplain. Pastikan server aktif.',
                    onRetry: _refreshComplaints,
                  ),
                )
              else if (snapshot.data == null || (snapshot.data as List).isEmpty)
                const SliverFillRemaining(child: Center(child: Text('Belum ada komplain masuk.')))
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cp = (snapshot.data as List)[index];
                        if (cp == null) return const SizedBox.shrink();
                        return _buildOwnerComplaintCard(cp);
                      },
                      childCount: (snapshot.data as List).length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOwnerComplaintCard(dynamic cp) {
    final status = cp['status'].toString();
    Color statusColor = Colors.orange;
    if (status == 'processing') statusColor = Colors.blue;
    if (status == 'resolved') statusColor = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kamar ${cp['kamar']?['nomor_kamar'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(cp['user']?['name'] ?? 'Anonim', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
          Text(cp['category'] ?? 'Lainnya', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepOrange)),
          const SizedBox(height: 5),
          Text(cp['description'] ?? '-', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          const SizedBox(height: 20),
          if (status != 'resolved')
            Row(
              children: [
                if (status == 'pending')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateStatus(cp['id'], 'processing'),
                      icon: const Icon(Icons.sync_rounded, size: 18),
                      label: const Text('PROSES'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (status == 'pending') const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(cp['id'], 'resolved'),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('SELESAI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
