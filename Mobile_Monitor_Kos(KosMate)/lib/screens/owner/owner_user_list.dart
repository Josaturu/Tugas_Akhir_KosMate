import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/global_sliver_header.dart';


class OwnerUserList extends StatefulWidget {
  const OwnerUserList({super.key});

  @override
  State<OwnerUserList> createState() => _OwnerUserListState();
}

class _OwnerUserListState extends State<OwnerUserList> {
  late Future<dynamic> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = ApiService.getPenyewa();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _usersFuture,
      builder: (context, snapshot) {
        return RefreshIndicator(
          onRefresh: () async => _refreshUsers(),
          color: Colors.orange,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Global Header
              GlobalSliverHeader(
                title: 'Daftar Penyewa',
                subtitle: 'Data seluruh penghuni kos terdaftar',
              ),

              // Content Section
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: Center(child: Text('Gagal memuat data: ${snapshot.error}')),
                )
              else ...[
                _buildUserSliverList(snapshot.data),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserSliverList(dynamic rawData) {
    List<dynamic> users = [];
    if (rawData is List) {
      users = rawData;
    } else if (rawData is Map && rawData.containsKey('message')) {
      return SliverFillRemaining(
        child: Center(child: Text('Info: ${rawData['message']}')),
      );
    }

    if (users.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('Belum ada penyewa terdaftar.')),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final user = users[index];
            if (user == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange.withOpacity(0.2), width: 2),
                    ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.orange.withOpacity(0.05),
                        child: Text(
                          (user['name'] != null && user['name'].toString().isNotEmpty)
                              ? user['name'].toString()[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone_android_rounded, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(user['no_hp'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 0.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
          childCount: users.length,
        ),
      ),
    );
  }
}
