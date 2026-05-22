import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/global_sliver_header.dart';
import '../widgets/animations.dart';
import 'owner/owner_complaint_list_screen.dart';
import 'tenant/tenant_complaint_screen.dart';
import 'owner/owner_transaction_list.dart';
import 'tenant/tenant_transaction_list.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_state.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<dynamic> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      _notificationsFuture = ApiService.getNotifications();
    });
  }

  void _markAsRead(int id) async {
    try {
      await ApiService.markNotificationRead(id);
      _refreshNotifications();
    } catch (e) {
      debugPrint('Error mark as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<dynamic>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const GlobalSliverHeader(
                title: 'Notifikasi',
                subtitle: 'Pesan dan pemberitahuan terbaru',
                showBackButton: true,
              ),

              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverToBoxAdapter(
                  child: ListSkeleton(itemCount: 5),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: ErrorStateWidget(
                    errorMessage: 'Gagal mengambil notifikasi. Pastikan server aktif.',
                    onRetry: _refreshNotifications,
                  ),
                )
              else if (snapshot.data == null || (snapshot.data as List).isEmpty)
                const SliverFillRemaining(child: Center(child: Text('Tidak ada notifikasi.')))
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notif = (snapshot.data as List)[index];
                        return DelayedFadeIn(
                          delay: 100 * index,
                          child: _buildNotificationCard(notif),
                        );
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

  Widget _buildNotificationCard(dynamic notif) {
    final bool isRead = notif['is_read'] == 1 || notif['is_read'] == true;
    
    return InkWell(
      onTap: () async {
        if (!isRead) _markAsRead(notif['id']);
        
        // 1. Ambil Role dari SharedPreferences (lebih cepat & akurat)
        final prefs = await SharedPreferences.getInstance();
        final String role = prefs.getString('role') ?? 'penyewa';
        
        // 2. Deteksi Tipe Notifikasi
        String type = (notif['type'] ?? 'general').toString().toLowerCase();
        
        if (!mounted) return;

        // 3. Navigasi Berdasarkan Role & Tipe
        if (type.contains('complaint') || type.contains('komplain')) {
          if (role == 'pemilik') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OwnerComplaintListScreen()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TenantComplaintScreen()));
          }
        } else if (type.contains('payment') || type.contains('bayar') || type.contains('tagihan')) {
          if (role == 'pemilik') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OwnerTransactionList()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TenantTransactionList()));
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.orange.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isRead ? Colors.transparent : Colors.orange.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _getIconColor(notif['type']).withOpacity(0.1),
              child: Icon(_getIcon(notif['type']), color: _getIconColor(notif['type']), size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(notif['title'], style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold, fontSize: 15)),
                      if (!isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(notif['message'], style: TextStyle(color: isRead ? Colors.grey : Colors.black87, fontSize: 13)),
                  const SizedBox(height: 10),
                  Text(notif['created_at'].toString().substring(0, 16).replaceAll('T', ' '), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'payment': return Icons.payments_rounded;
      case 'complaint': return Icons.report_problem_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'payment': return Colors.green;
      case 'complaint': return Colors.red;
      default: return Colors.blue;
    }
  }
}
