class Kamar {
  final int? id;
  final String nomorKamar;
  final String? tipeKamar;
  final double hargaSewa;
  final String status;
  final String? keterangan;
  final List<dynamic>? penyewaans;

  Kamar({
    this.id,
    required this.nomorKamar,
    this.tipeKamar,
    required this.hargaSewa,
    required this.status,
    this.keterangan,
    this.penyewaans,
  });

  factory Kamar.fromJson(Map<String, dynamic> json) {
    return Kamar(
      id: json['id'],
      nomorKamar: json['nomor_kamar']?.toString() ?? '-',
      tipeKamar: json['tipe_kamar'],
      hargaSewa: double.tryParse(json['harga_sewa']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'kosong',
      keterangan: json['keterangan'],
      penyewaans: json['penyewaans'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_kamar': nomorKamar,
      'tipe_kamar': tipeKamar,
      'harga_sewa': hargaSewa,
      'status': status,
      'keterangan': keterangan,
    };
  }
}
