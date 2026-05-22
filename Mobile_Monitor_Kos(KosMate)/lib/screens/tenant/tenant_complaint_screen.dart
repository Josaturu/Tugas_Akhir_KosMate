import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/global_sliver_header.dart';
import '../../widgets/animations.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';

class TenantComplaintScreen extends StatefulWidget {
  const TenantComplaintScreen({super.key});

  @override
  State<TenantComplaintScreen> createState() => _TenantComplaintScreenState();
}

class _TenantComplaintScreenState extends State<TenantComplaintScreen> with AutomaticKeepAliveClientMixin {
  late Future<dynamic> _complaintsFuture;
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  int? _myKamarId;
  bool _isLoadingKamar = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _fetchMyKamar();
  }

  void _refreshData() {
    setState(() {
      _complaintsFuture = ApiService.getMyComplaints();
    });
  }

  Future<void> _fetchMyKamar() async {
    try {
      final res = await ApiService.getMyTenancy();
      debugPrint('DEBUG: Response Tenancy -> $res'); // Biar kita bisa lihat di log
      if (mounted) {
        setState(() {
          if (res != null) {
            // Kita coba ambil dari berbagai kemungkinan field
            _myKamarId = res['kamar_id'] ?? res['id_kamar'] ?? (res['kamar'] != null ? res['kamar']['id'] : null);
          }
          _isLoadingKamar = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingKamar = false);
      debugPrint('Error fetch kamar: $e');
    }
  }

  void _submitComplaint() async {
    if (_myKamarId == null) {
      SnackbarHelper.showError(context, 'Data kamar tidak ditemukan. Pastikan Anda sudah terdaftar di kos.');
      return;
    }
    if (_descriptionController.text.isEmpty || _selectedCategory == null) {
      SnackbarHelper.showError(context, 'Pilih kategori dan isi deskripsi');
      return;
    }
    
    // Tampilkan loading dialog
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      final res = await ApiService.storeComplaint({
        'kamar_id': _myKamarId,
        'category': _selectedCategory,
        'description': _descriptionController.text,
      });

      if (mounted) {
        Navigator.pop(context); // Tutup loading
        Navigator.pop(context); // Tutup bottom sheet
        _descriptionController.clear();
        _selectedCategory = null;
        SnackbarHelper.showSuccess(context, res['message'] ?? 'Komplain terkirim');
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup loading
        SnackbarHelper.showError(context, 'Gagal mengirim komplain: $e');
      }
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 25, left: 25, right: 25
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Kirim Komplain', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Apa masalah yang Anda hadapi?', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 15),
                _buildCategoryChips(setSheetState),
                const SizedBox(height: 20),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan secara detail di sini...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text('KIRIM LAPORAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips(StateSetter setSheetState) {
    final categories = ['Fasilitas Kamar', 'Listrik', 'Air', 'Wifi', 'Kebersihan', 'Lainnya'];
    return Wrap(
      spacing: 8,
      runSpacing: 0,
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat;
        return FilterChip(
          label: Text(cat),
          selected: isSelected,
          onSelected: (val) {
            setSheetState(() => _selectedCategory = cat);
          },
          selectedColor: Colors.orange.withValues(alpha: 0.2),
          checkmarkColor: Colors.orange,
          labelStyle: TextStyle(
            color: isSelected ? Colors.orange : Colors.black87,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        color: Colors.orange,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            GlobalSliverHeader(
              title: 'Komplain & Keluhan',
              subtitle: 'Pantau status keluhan Anda',
              showBackButton: true,
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Riwayat Laporan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (!_isLoadingKamar)
                      TextButton.icon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: const Text('Buat Laporan', style: TextStyle(fontSize: 13)),
                        style: TextButton.styleFrom(foregroundColor: Colors.orange),
                      ),
                  ],
                ),
              ),
            ),

            FutureBuilder<dynamic>(
              future: _complaintsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: ListSkeleton(itemCount: 4),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: ErrorStateWidget(
                      errorMessage: 'Gagal mengambil data komplain. Pastikan server aktif.',
                      onRetry: _refreshData,
                    ),
                  );
                }
                
                final complaints = snapshot.data as List? ?? [];
                if (complaints.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_turned_in_outlined, size: 70, color: Colors.grey[300]),
                          const SizedBox(height: 15),
                          const Text('Belum ada laporan komplain', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final comp = complaints[index];
                        return DelayedFadeIn(
                          delay: 100 + (index * 100),
                          child: _buildComplaintCard(comp),
                        );
                      },
                      childCount: complaints.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(dynamic comp) {
    final status = comp['status'] ?? 'pending';
    Color statusColor = Colors.orange;
    if (status == 'processing') statusColor = Colors.blue;
    if (status == 'resolved') statusColor = Colors.green;

    final roomNumber = comp['kamar'] != null ? comp['kamar']['nomor_kamar'] : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              Text(comp['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: Text(comp['category'] ?? 'Kategori', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Kamar $roomNumber',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comp['description'] ?? '-', style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
