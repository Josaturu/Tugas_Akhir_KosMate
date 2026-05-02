import 'package:flutter/material.dart';

import '../../widgets/global_sliver_header.dart';
import '../../services/api_service.dart';

class OwnerAnnouncementScreen extends StatefulWidget {
  const OwnerAnnouncementScreen({super.key});

  @override
  State<OwnerAnnouncementScreen> createState() => _OwnerAnnouncementScreenState();
}

class _OwnerAnnouncementScreenState extends State<OwnerAnnouncementScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendAnnouncement() async {
    final title = _titleController.text.trim();
    final message = _contentController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan isi pengumuman harus diisi')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final response = await ApiService.sendBroadcastNotification(title, message);
      
      if (mounted) {
        if (response['success'] == true || response['status'] == 'success' || response['message'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengumuman berhasil dikirim ke seluruh penyewa!'), backgroundColor: Colors.green),
          );
          _titleController.clear();
          _contentController.clear();
          Navigator.pop(context);
        } else {
          throw Exception(response['message'] ?? 'Unknown error');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pengumuman: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          const GlobalSliverHeader(
            title: 'Kirim Pengumuman',
            subtitle: 'Broadcast pesan ke semua penyewa',
            showBackButton: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(25),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'Buat Pengumuman Baru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _titleController,
                  label: 'Judul Pengumuman',
                  hint: 'Contoh: Kerja Bakti Hari Minggu',
                  icon: Icons.title_rounded,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _contentController,
                  label: 'Isi Pengumuman',
                  hint: 'Tulis detail pesan di sini...',
                  icon: Icons.notes_rounded,
                  maxLines: 5,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isSending ? null : _sendAnnouncement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: _isSending
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'KIRIM SEKARANG',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.orange),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.orange, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
