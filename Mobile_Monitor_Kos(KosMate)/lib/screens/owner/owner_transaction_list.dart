import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/global_sliver_header.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';

class OwnerTransactionList extends StatefulWidget {
  const OwnerTransactionList({super.key});

  @override
  State<OwnerTransactionList> createState() => _OwnerTransactionListState();
}

class _OwnerTransactionListState extends State<OwnerTransactionList> {
  late Future<dynamic> _transactionFuture;
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }

  void _refreshTransactions() {
    if (!mounted) return;
    setState(() {
      _transactionFuture = ApiService.getPembayaran();
    });
    _transactionFuture.then((val) {
      if (mounted && val is List) {
        setState(() => _transactions = val.where((item) => item != null).toList());
      }
    });
  }

  void _confirmPayment(int id) async {
    try {
      final response = await ApiService.konfirmasiPembayaran(id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<dynamic>(
        future: _transactionFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              body: ErrorStateWidget(
                onRetry: () => _refreshTransactions(),
              ),
            );
          }

          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return RefreshIndicator(
            onRefresh: () async => _refreshTransactions(),
            color: Colors.orange,
            child: CustomScrollView(
              physics: isLoading ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
              slivers: [
                const GlobalSliverHeader(
                  title: 'Riwayat Pembayaran',
                  subtitle: 'Pantau pembayaran bulanan penyewa',
                  showBackButton: true,
                ),

                if (isLoading)
                  const SliverToBoxAdapter(
                    child: ListSkeleton(),
                  )
                else if (snapshot.data is! List || (snapshot.data as List).isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('Belum ada data transaksi.')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tx = (snapshot.data as List)[index];
                          if (tx == null) return const SizedBox.shrink();
                          final penyewaan = tx['penyewaan'];
                          final isLunas = tx['status'] == 'lunas';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
                                            child: const Icon(Icons.person_rounded, color: Colors.orange, size: 24),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(penyewaan?['user']?['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                Text('Kamar ${penyewaan?['kamar']?['nomor_kamar'] ?? '-'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: (isLunas ? Colors.green : Colors.orange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                      child: Text(tx['status'].toString().toUpperCase(), style: TextStyle(color: isLunas ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(height: 1, color: Color(0xFFF5F5F5))),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Periode Tagihan', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                        const SizedBox(height: 4),
                                        Text(
                                          tx['periode'] != null && tx['periode'].toString().length >= 7 
                                            ? tx['periode'].toString().substring(0, 7) 
                                            : (tx['periode']?.toString() ?? '-'), 
                                          style: const TextStyle(fontWeight: FontWeight.w600)
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text('Metode', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                        const SizedBox(height: 4),
                                        Text(
                                          tx['metode']?.toString() ?? 'Belum Lapor', 
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: tx['metode'] != null ? Colors.blue : Colors.grey,
                                            fontSize: 12
                                          )
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text('Total Biaya', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                        const SizedBox(height: 4),
                                        Text(
                                          CurrencyFormat.convertToIdr(double.tryParse(tx['jumlah']?.toString() ?? '0') ?? 0, 0), 
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 16)
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (!isLunas) ...[
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () => _confirmPayment(tx['id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      elevation: 0,
                                    ),
                                    child: const Text('KONFIRMASI PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ]
                              ],
                            ),
                          );
                        },
                        childCount: _transactions.length,
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
}
