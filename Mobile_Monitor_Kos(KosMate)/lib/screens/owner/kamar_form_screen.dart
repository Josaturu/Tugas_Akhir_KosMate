import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/kamar_model.dart';
import '../../widgets/custom_header.dart';
import '../../utils/validators.dart';

class KamarFormScreen extends StatefulWidget {
  final Kamar? kamar;

  const KamarFormScreen({super.key, this.kamar});

  @override
  State<KamarFormScreen> createState() => _KamarFormScreenState();
}

class _KamarFormScreenState extends State<KamarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomorController;
  late TextEditingController _tipeController;
  late TextEditingController _hargaController;
  late TextEditingController _keteranganController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _nomorController = TextEditingController(text: widget.kamar?.nomorKamar ?? '');
    _tipeController = TextEditingController(text: widget.kamar?.tipeKamar ?? '');
    _hargaController = TextEditingController(text: widget.kamar?.hargaSewa.toInt().toString() ?? '');
    _keteranganController = TextEditingController(text: widget.kamar?.keterangan ?? '');
    _status = widget.kamar?.status ?? 'kosong';
  }

  void _saveKamar() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nomor_kamar': _nomorController.text,
        'tipe_kamar': _tipeController.text,
        'harga_sewa': double.parse(_hargaController.text),
        'status': _status,
        'keterangan': _keteranganController.text,
      };

      try {
        dynamic response;
        if (widget.kamar == null) {
          response = await ApiService.createKamar(data);
        } else {
          response = await ApiService.updateKamar(widget.kamar!.id!, data);
        }

        if (response != null && (response['message'] != null || response['id'] != null)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Berhasil menyimpan data kamar'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          throw response['message'] ?? 'Gagal menyimpan data';
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sistem Error: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  void _deleteKamar() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kamar?'),
        content: const Text('Data kamar ini akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await ApiService.deleteKamar(widget.kamar!.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Kamar berhasil dihapus'), backgroundColor: Colors.red),
          );
          // Pop 2 kali: Keluar dari Form ini dan keluar dari halaman Detail Kamar
          // agar langsung kembali ke Dashboard Owner
          Navigator.of(context).pop(); 
          Navigator.of(context).pop(true); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          CustomHeader(
            title: widget.kamar == null ? 'Tambah Kamar Baru' : 'Edit Kamar ${widget.kamar!.nomorKamar}',
            subtitle: 'Pastikan data kamar sudah benar',
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      label: 'Nomor Kamar',
                      controller: _nomorController,
                      icon: Icons.door_front_door_outlined,
                      validator: (v) => AppValidators.required(v, 'Nomor Kamar'),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: 'Tipe Kamar',
                      controller: _tipeController,
                      icon: Icons.category_outlined,
                      hint: 'Misal: VIP, Standard, AC',
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: 'Harga Sewa (Bulan)',
                      controller: _hargaController,
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => AppValidators.number(v, 'Harga Sewa'),
                    ),
                    const SizedBox(height: 25),
                    const Text('Status Kamar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatusOption('kosong', 'Kosong', Colors.green),
                        const SizedBox(width: 20),
                        _buildStatusOption('terisi', 'Terisi', Colors.red),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _buildInputField(
                      label: 'Keterangan Tambahan',
                      controller: _keteranganController,
                      icon: Icons.notes,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _saveKamar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: Text(
                        widget.kamar == null ? 'TAMBAHKAN KAMAR' : 'SIMPAN PERUBAHAN',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                    if (widget.kamar != null) ...[
                      const SizedBox(height: 15),
                      OutlinedButton(
                        onPressed: _deleteKamar,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('HAPUS KAMAR', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.orange),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.orange, width: 1)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOption(String value, String label, Color color) {
    bool isSelected = _status == value;
    return InkWell(
      onTap: () => setState(() => _status = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey[300]!, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? color : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? color : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
