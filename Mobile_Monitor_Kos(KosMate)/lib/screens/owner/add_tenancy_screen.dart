import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/kamar_model.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_header.dart';

class AddTenancyScreen extends StatefulWidget {
  final Kamar kamar;

  const AddTenancyScreen({super.key, required this.kamar});

  @override
  State<AddTenancyScreen> createState() => _AddTenancyScreenState();
}

class _AddTenancyScreenState extends State<AddTenancyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _durationController = TextEditingController(text: '1');
  
  int? _selectedUserId;
  List<dynamic> _users = [];
  bool _isLoadingUsers = true;
  dynamic _selectedUser; // Untuk menyimpan objek user yang sedang dipilih

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    try {
      final data = await ApiService.getPenyewa();
      setState(() {
        _users = data;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() => _isLoadingUsers = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengambil data user: $e')));
      }
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.orange, onPrimary: Colors.white, onSurface: Colors.black87),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan pilih penyewa dulu'), backgroundColor: Colors.orange));
        return;
      }

      // Cek apakah user sudah punya sewa aktif
      if (_selectedUser != null && (_selectedUser['active_tenancy_count'] ?? 0) > 0) {
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Peringatan!'),
            content: Text('Penyewa ${_selectedUser['name']} saat ini masih tercatat memiliki kamar aktif. Apakah Anda yakin ingin memindahkannya ke kamar ini?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('BATAL')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('YA, LANJUTKAN', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (confirm != true) return;
      }

      try {
        final response = await ApiService.storePenyewaan({
          'users_id': _selectedUserId,
          'kamars_id': widget.kamar.id,
          'tanggal_masuk': _dateController.text,
          'lama_sewa': int.parse(_durationController.text),
        });

        if (mounted) {
          if (response['data'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['message'] ?? 'Berhasil!'), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['message'] ?? 'Gagal mendaftarkan'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
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
            title: 'Sewa Kamar ${widget.kamar.nomorKamar}',
            subtitle: widget.kamar.tipeKamar ?? '-',
            showBackButton: true,
          ),
          Expanded(
            child: _isLoadingUsers 
              ? const Center(child: CircularProgressIndicator(color: Colors.orange))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20), // Lebih compact
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pilih Calon Penyewa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        _buildDropdownField(),
                        
                        // Tooltip Peringatan jika sudah punya kamar
                        if (_selectedUser != null && (_selectedUser['active_tenancy_count'] ?? 0) > 0)
                          _buildWarningTooltip(),

                        const SizedBox(height: 20),
                        const Text('Konfigurasi Sewa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        _buildInputField(
                          label: 'Tanggal Mulai Masuk',
                          controller: _dateController,
                          icon: Icons.calendar_month_outlined,
                          readOnly: true,
                          onTap: _selectDate,
                          validator: (v) => AppValidators.required(v, 'Tanggal Masuk'),
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          label: 'Durasi Sewa (Bulan)',
                          controller: _durationController,
                          icon: Icons.timer_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) => AppValidators.number(v, 'Lama Sewa'),
                        ),
                        const SizedBox(height: 35),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50), // Lebih ramping
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                          ),
                          child: const Text('KONFIRMASI PENDAFTARAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningTooltip() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Penyewa ini terdeteksi sudah memiliki kamar aktif di sistem.',
              style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: DropdownButtonFormField<int>(
        isDense: false, // Beri ruang lebih lega
        itemHeight: 50, // Tambah tinggi agar muat 2 baris teks (Nama & Email)
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person_search_outlined, color: Colors.orange, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        value: _selectedUserId,
        hint: const Text('Cari nama penyewa...', style: TextStyle(fontSize: 13)),
        isExpanded: true,
        items: _users.map((user) {
          bool hasRoom = (user['active_tenancy_count'] ?? 0) > 0;
          return DropdownMenuItem<int>(
            value: user['id'],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, // Pusatkan secara vertikal
                    children: [
                      Text(
                        user['name'] ?? '-', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user['email'] ?? '-', 
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (hasRoom)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                    child: const Text('PUNYA KAMAR', style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            _selectedUserId = val;
            _selectedUser = _users.firstWhere((u) => u['id'] == val);
          });
        },
        validator: (v) => v == null ? 'Penyewa wajib dipilih' : null,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.orange, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orange, width: 1)),
          ),
        ),
      ],
    );
  }
}
