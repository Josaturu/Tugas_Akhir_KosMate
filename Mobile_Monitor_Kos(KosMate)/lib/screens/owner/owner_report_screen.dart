import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/global_sliver_header.dart';
import '../../widgets/animations.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';

class OwnerReportScreen extends StatefulWidget {
  const OwnerReportScreen({super.key});

  @override
  State<OwnerReportScreen> createState() => _OwnerReportScreenState();
}

class _OwnerReportScreenState extends State<OwnerReportScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  
  Map<String, dynamic>? _summary;
  List<dynamic> _payments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final summaryRes = await ApiService.getReportSummary(_selectedMonth, _selectedYear);
      final paymentRes = await ApiService.getPaymentReport(_selectedMonth, _selectedYear);
      
      setState(() {
        _summary = summaryRes['summary'];
        _payments = paymentRes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: Colors.orange,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            const GlobalSliverHeader(
              title: 'Laporan Keuangan',
              subtitle: 'Pantau pemasukan & okupansi kos',
              showBackButton: true,
            ),

            // Filter Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Expanded(child: _buildDropdownMonth()),
                    const SizedBox(width: 15),
                    Expanded(child: _buildDropdownYear()),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const SliverToBoxAdapter(
                child: ReportSkeleton(),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorStateWidget(
                  errorMessage: 'Gagal mengambil laporan keuangan. Pastikan koneksi server aktif.',
                  onRetry: _fetchData,
                ),
              )
            else ...[
              // Summary Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      DelayedFadeIn(delay: 200, child: _buildMainSummaryCard()),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: DelayedFadeIn(delay: 400, child: _buildSmallSummaryCard('Kamar Terisi', '${_summary?['kamar_terisi'] ?? 0}', Icons.door_front_door_rounded, Colors.blue))),
                          const SizedBox(width: 15),
                          Expanded(child: DelayedFadeIn(delay: 600, child: _buildSmallSummaryCard('Tunggakan', CurrencyFormat.convertToIdr(double.tryParse(_summary?['total_tunggakan']?.toString() ?? '0') ?? 0, 0), Icons.warning_rounded, Colors.red))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Title Section
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
                  child: Text('Rincian Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
              ),

              // Payment List
              _payments.isEmpty
                  ? const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Tidak ada data pembayaran bulan ini')))
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final tx = _payments[index];
                            final isLunas = tx['status'] == 'lunas';
                            return DelayedFadeIn(
                              delay: 100 * index,
                              child: _buildPaymentListItem(tx, isLunas),
                            );
                          },
                          childCount: _payments.length,
                        ),
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownMonth() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedMonth,
          isExpanded: true,
          items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_getMonthName(i + 1)))),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedMonth = val);
              _fetchData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDropdownYear() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYear,
          isExpanded: true,
          items: List.generate(5, (i) => DropdownMenuItem(value: 2024 + i, child: Text('${2024 + i}'))),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedYear = val);
              _fetchData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildMainSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Pemasukan', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            CurrencyFormat.convertToIdr(double.tryParse(_summary?['total_pemasukan']?.toString() ?? '0') ?? 0, 0),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
            child: Text('${_getMonthName(_selectedMonth)} $_selectedYear', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildSmallSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
          const SizedBox(height: 15),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentListItem(dynamic tx, bool isLunas) {
    final penyewaan = tx['penyewaan'];
    final kamar = penyewaan?['kamar'];
    final user = penyewaan?['user'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: (isLunas ? Colors.green : Colors.orange).withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Text(kamar?['nomor_kamar']?.toString() ?? '-', style: TextStyle(color: isLunas ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?['name']?.toString() ?? 'Anonim', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(isLunas ? 'Lunas: ${tx['tanggal_bayar'] ?? '-'}' : 'Belum Bayar', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            CurrencyFormat.convertToIdr(double.tryParse(tx['jumlah']?.toString() ?? '0') ?? 0, 0), 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return months[month - 1];
  }
}
