import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/global_sliver_header.dart';
import '../../widgets/owner/kamar_card.dart';
import 'kamar_form_screen.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';

class OwnerRoomListScreen extends StatefulWidget {
  const OwnerRoomListScreen({super.key});

  @override
  State<OwnerRoomListScreen> createState() => _OwnerRoomListScreenState();
}

class _OwnerRoomListScreenState extends State<OwnerRoomListScreen> {
  List<dynamic> _allRooms = [];
  List<dynamic> _filteredRooms = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ApiService.getKamar();
      if (mounted) {
        setState(() {
          _allRooms = (data is List) ? data : [];
          _filteredRooms = _allRooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _filterRooms(String query) {
    setState(() {
      _filteredRooms = _allRooms.where((room) {
        final nomor = room['nomor_kamar'].toString().toLowerCase();
        final tipe = room['tipe_kamar'].toString().toLowerCase();
        return nomor.contains(query.toLowerCase()) || tipe.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          const GlobalSliverHeader(
            title: 'Kelola Kamar',
            subtitle: 'Manajemen unit dan ketersediaan',
            showBackButton: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              child: TextField(
                controller: _searchController,
                onChanged: _filterRooms,
                decoration: InputDecoration(
                  hintText: 'Cari nomor atau tipe kamar...',
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: ListSkeleton(itemCount: 4),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: ErrorStateWidget(
                errorMessage: 'Gagal memuat data kamar. Pastikan server aktif.',
                onRetry: _fetchRooms,
              ),
            )
          else if (_filteredRooms.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('Kamar tidak ditemukan')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final room = _filteredRooms[index];
                    return KamarCard(json: room);
                  },
                  childCount: _filteredRooms.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KamarFormScreen()),
          );
          if (result == true) _fetchRooms();
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('TAMBAH KAMAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
