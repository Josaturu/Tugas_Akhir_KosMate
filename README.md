# KosMate - Sistem Manajemen Kos Modern 🏠

**KosMate** adalah solusi digital terintegrasi yang dirancang untuk menyederhanakan pengelolaan rumah kos. Aplikasi ini memfasilitasi interaksi antara **Pemilik Kos** dan **Penyewa** melalui platform mobile yang responsif dan backend API yang tangguh.

---

## 🚀 Fitur Utama

### 👨‍💼 Fitur Pemilik (Owner)
- **Monitoring Kamar Real-time**: Dashboard visual untuk memantau status okupansi kamar (Total, Terisi, Kosong).
- **Manajemen Penyewa**: Pendataan penyewa yang aktif dan riwayat sewa.
- **Broadcast Pengumuman**: Mengirim notifikasi siaran ke seluruh penyewa dalam satu klik.
- **Verifikasi Pembayaran**: Sistem konfirmasi pembayaran tagihan bulanan dari penyewa.
- **Laporan & Keluhan**: Memantau dan merespon keluhan yang masuk dari penyewa secara langsung.

### 👨‍🎓 Fitur Penyewa (Tenant)
- **Dashboard Personal**: Informasi detail kamar dan ringkasan tagihan aktif.
- **Pembayaran Digital**: Melaporkan pembayaran bulanan baik tunai maupun transfer dengan unggah bukti.
- **Sistem Komplain**: Mengirim keluhan fasilitas kos dengan status yang dapat dipantau (Pending/Proses/Selesai).
- **Bantuan Cepat**: Akses cepat untuk menghubungi pemilik kos dalam keadaan darurat.
- **Riwayat Transaksi**: Arsip seluruh pembayaran yang pernah dilakukan.

---

## 🛠️ Teknologi yang Digunakan

### Frontend (Mobile)
- **Framework**: Flutter (Dart)
- **State Management**: Stateful Widgets & AutomaticKeepAlive
- **UI Architecture**: Modular Components with Custom Sliver Headers
- **Animations**: Custom Fade-in & Scale transitions

### Backend (API)
- **Framework**: Laravel 13 (PHP)
- **Database**: MySQL
- **Authentication**: Laravel Sanctum (Token-based)
- **Architecture**: RESTful API with Resource Controllers

---

## 📦 Struktur Proyek
```text
Tugas_Akhir_KosMate/
├── Mobile_Monitor_Kos(KosMate)/     # Aplikasi Flutter (Frontend)
├── API_Monitor_Kos(KosMate)/        # Laravel Framework (Backend)
└── README.md                       # Dokumentasi Proyek
```

---

## ⚙️ Cara Instalasi

### 1. Persiapan Backend (Laravel)
```bash
cd API_Monitor_Kos(KosMate)/
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

### 2. Persiapan Frontend (Flutter)
- Pastikan Flutter SDK sudah terinstal.
- Sesuaikan `baseUrl` pada `lib/services/api_service.dart` dengan alamat IP server lokal Anda.
```bash
cd Mobile_Monitor_Kos(KosMate)/
flutter pub get
flutter run
```

> [!IMPORTANT]
> Jangan lupa membaca **[catatan.md](catatan.md)** & **[workflow_kosan.md](workflow_kosan.md)** untuk petunjuk lebih lanjut mengenai konfigurasi detail dan alur kerja sistem.

---

## 📝 Catatan Proyek
Proyek ini dikembangkan sebagai bagian dari **Tugas Akhir** untuk mendigitalisasi proses manajemen kos konvensional menjadi lebih efisien, transparan, dan terorganisir.

**Kontak Pengembang:** [Josaturu](https://github.com/Josaturu)
