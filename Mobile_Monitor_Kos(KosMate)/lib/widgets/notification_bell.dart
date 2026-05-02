import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/notification_screen.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;
  Timer? _timer; // Timer untuk polling

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
    // Jalankan polling setiap 20 detik
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _fetchUnreadCount();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Jangan lupa matikan timer saat widget dihancurkan
    super.dispose();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final res = await ApiService.getUnreadNotificationCount();
      if (mounted) {
        setState(() {
          _unreadCount = (res != null && res is Map) ? (res['unread_count'] ?? 0) : 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetch unread: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationScreen()),
        );
        _fetchUnreadCount(); // Refresh count after returning
      },
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
          ),
          if (_unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            )
        ],
      ),
    );
  }
}
