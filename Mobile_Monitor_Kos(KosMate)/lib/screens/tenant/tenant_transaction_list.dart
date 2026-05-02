import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/global_sliver_header.dart';
import '../../widgets/animations.dart';
import '../../utils/snackbar_helper.dart';

class TenantTransactionList extends StatefulWidget {
  const TenantTransactionList({super.key});

  @override
  State<TenantTransactionList> createState() => _TenantTransactionListState();
}

class _TenantTransactionListState extends State<TenantTransactionList> with AutomaticKeepAliveClientMixin {
  late Future<dynamic> _transactionFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }

  void _refreshTransactions() {
    setState(() {
      _transactionFuture = ApiService.getPembayaran();
    });
  }

  void _simulasiBayar(int id, String metode) async {
    try {
      String? bukti;
      if (metode == 'Transfer Bank') {
        bukti = 'BUKTI_TRANSFER_${DateTime.now().millisecondsSinceEpoch}.jpg';
      }
      
      final response = await ApiService.uploadBukti(id, metode, bukti);
      if (mounted) {
        SnackbarHelper.showSuccess(context, response['message']);
        _refreshTransactions();
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Error: $e');
      }
    }
  }

  void _showPaymentOptions(int id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(25, 25, 25, 40),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              _buildPaymentOption(
                icon: Icons.account_balance_rounded,
                title: 'Transfer Bank',
                subtitle: 'Wajib upload bukti transfer',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  _simulasiBayar(id, 'Transfer Bank');
                },
              ),
              const SizedBox(height: 15),
              _buildPaymentOption(
                icon: Icons.payments_rounded,
                title: 'Tunai / Cash',
                subtitle: 'Berikan uang langsung ke pemilik',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _simulasiBayar(id, 'Tunai');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[100]!),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<dynamic>(
        future: _transactionFuture,
        builder: (context, snapshot) {
          return RefreshIndicator(
            onRefresh: () async => _refreshTransactions(),
            color: Colors.orange,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                GlobalSliverHeader(
                  title: 'Tagihan & Riwayat',
                  subtitle: 'Pantau tagihan dan riwayat Anda',
                  showBackButton: true,
                ),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                  )
                else if (snapshot.data is! List || (snapshot.data as List).isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 15),
                          const Text('Belum ada tagihan masuk.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tx = (snapshot.data as List)[index];
                          final isLunas = tx['status'] == 'lunas';
                          final sudahMelapor = tx['metode'] != null;

                          return DelayedFadeIn(
                            delay: 100 + (index * 50),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
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
                                          Text('Tagihan ${tx['periode'].toString().substring(0, 7)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                          Text('Kamar ${tx['penyewaan']?['kamar']?['nomor_kamar'] ?? '-'}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                        ],
                                      ),
                                      _buildStatusBadge(tx['status']),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Divider(height: 1, color: Color(0xFFF8F9FA)),
                                  ),
                                  _buildDetailRow('Item', 'Sewa Kamar'),
                                  _buildDetailRow('Rincian', '${CurrencyFormat.convertToIdr(double.parse(tx['penyewaan']?['kamar']?['harga_sewa']?.toString() ?? '0'), 0)} x ${tx['penyewaan']?['lama_sewa'] ?? 0} Bulan'),
                                  const SizedBox(height: 10),
                                  _buildDetailRow('Total Nominal', CurrencyFormat.convertToIdr(double.parse(tx['jumlah'].toString()), 0), isTotal: true),
                                  const SizedBox(height: 20),
                                  
                                  if (!isLunas) 
                                    (sudahMelapor ? _buildWaitingMessage() : ElevatedButton(
                                      onPressed: () => _showPaymentOptions(tx['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(double.infinity, 48),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: const Text('BAYAR SEKARANG', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                    ))
                                  else 
                                    _buildSuccessMessage(tx['tanggal_bayar'] ?? '-'),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: (snapshot.data as List).length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isLunas = status == 'lunas';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: (isLunas ? Colors.green : Colors.orange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(color: isLunas ? Colors.green : Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? Colors.black : Colors.grey, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 14 : 12)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 16 : 13, color: isTotal ? Colors.deepOrange : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildWaitingMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.access_time_rounded, color: Colors.blue, size: 18),
          SizedBox(width: 10),
          Expanded(child: Text('Menunggu verifikasi pemilik', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
          const SizedBox(width: 10),
          Text('Lunas pada $date', style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
