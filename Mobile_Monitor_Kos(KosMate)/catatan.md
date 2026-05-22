# Catatan Perubahan Aplikasi (Changelog)

Dokumen ini mencatat riwayat perubahan (penambahan, pengubahan, dan penghapusan) pada aplikasi Info Kosan.
Untuk melihat alur kerja aplikasi, silakan buka file `workflow_kosan.md`.

## [Versi 1.8.0] - Shimmer Skeleton, Smart Tenant Due Date & Network Error Handler
**Pembaruan & Perbaikan:**
- **Loading UI Modern (Shimmer Skeleton)**: Menggantikan `CircularProgressIndicator` dengan animasi kerangka muatan statis (skeleton loader) di seluruh halaman yang membutuhkan pengambilan data API, memberikan feedback visual yang lebih responsif dan modern.
- **Smart Tenant Due Date**: Menyesuaikan logika tanggal jatuh tempo pada dashboard penyewa. Jika seluruh tagihan sudah lunas, jatuh tempo akan menampilkan tanggal selesai sewa berdasarkan data Tenancy. Jika masih ada tagihan, jatuh tempo menampilkan periode tagihan aktif.
- **Network Error Handler**: Mengintegrasikan `ErrorStateWidget` khusus untuk menangani skenario kegagalan koneksi ke API (seperti server offline atau localtunnel terputus). Dilengkapi tombol "Coba Lagi" untuk penyegaran data tanpa perlu merefresh halaman utama.
- **Dukungan Halaman Lengkap**: 
  - Pembaruan merata pada Dashboard, Transaksi, Laporan, Komplain, dan Daftar Pengguna.
  - Perombakan penggunaan `FutureBuilder` di sisi Frontend untuk membedakan secara visual antara `waiting`, `error`, dan `hasData`.

## [Versi 1.7.0] - Backend Stability, Room Deletion & Smart Billing
**Pembaruan & Perbaikan:**
- **Critical Data Persistence Fix**: Resolusi masalah gagal simpan data kamar baru di database dengan memigrasikan Model Laravel dari PHP Attributes (`#[Fillable]`) ke properti `$fillable` standar untuk kompatibilitas lintas versi Laravel.
- **Advanced Room Management**:
  - Implementasi fungsi **Hapus Kamar** permanen dengan dialog konfirmasi (UX Safety).
  - Optimasi navigasi: Alur hapus kini otomatis melakukan *double-pop* kembali ke Dashboard untuk menghindari error *null data* pada halaman detail.
- **Improved API Communication**:
  - Standarisasi respon JSON Backend (Message & Data) untuk validasi frontend yang lebih presisi.
  - Peningkatan *Error Handling* pada form: Aplikasi kini menampilkan pesan kesalahan spesifik dari server jika validasi gagal.
- **Universal Broadcast System**: Pembaruan kueri pengumuman agar menjangkau **seluruh user terdaftar** (global broadcast) tanpa batasan role tertentu.
- **Financial Transparency**: Penambahan label **Metode Pembayaran** (Transfer/Tunai) pada daftar transaksi Owner untuk mempermudah audit keuangan manual.
- **Intelligent Billing Logic (Tenant)**: Implementasi status tagihan dinamis di Dashboard (Belum Aktif, Belum Ada Tagihan, Nominal Tagihan, atau Lunas) sesuai kondisi riil penyewaan.
- **Framework Compliance**: Audit dan pembersihan total fungsi *deprecated* `.withOpacity()` menjadi `.withValues(alpha: ...)` di seluruh codebase Flutter.

## [Versi 1.6.0] - Stability, Cleanup & Profile Redesign
**Pembaruan & Perbaikan:**
- **Profile Redesign (Owner & Tenant)**: Implementasi tampilan profil baru dengan CustomScrollView, Header Modern, dan gaya kartu informasi yang lebih bersih.
- **Header & Stats Optimization**: Pemindahan foto profil ke header dashboard, penambahan rounded corners, dan penyederhanaan Monitoring Card (3-kolom: Total, Terisi, Kosong).
- **Critical Stability Fix**: Perbaikan error asersi `box.dart` (Spacer crash) dan loop "Unexpected null value" melalui sanitasi data API massal.
- **Functional Announcement**: Penambahan halaman `OwnerAnnouncementScreen` untuk mengirim pesan siaran (broadcast) ke seluruh penyewa.
- **Smart Navigation**: Menu cepat "Penyewa" di dashboard kini terhubung langsung ke tab navigasi bawah (Tab-switching logic).
- **Code Sanitization**: Pembersihan operator `!` yang berisiko crash dan penghapusan animasi `DelayedFadeIn` pada list besar untuk performa yang lebih stabil.
- **UI & Navigation Polish**: 
  - Resolusi tumpang tindih header dengan menyamakan warna `backgroundColor` SliverAppBar dengan background Scaffold.
  - Fix search bar tertimpa header dengan mencabut efek `transform: Matrix4.translationValues`.
  - Penambahan bayangan tegas pada `CustomBottomNav` agar round corner lebih terlihat.
  - Penghapusan total komponen `CustomDrawer` dan seluruh pemanggilannya untuk navigasi tersentralisasi via Bottom Navigation.
  - Pembersihan icon notifikasi ganda di halaman `OwnerUserList`.
- **Refactoring Arsitektur Komponen**: Penyatuan desain header (Dashboard, Standard, dan Profile) menjadi satu *Super-Component* (`GlobalSliverHeader`) agar seragam, mudah dirawat (*maintainable*), dan menggantikan gaya *hardcode*.
- **Integrasi API**: 
  - Menghubungkan fungsi *Broadcast Notification* pada halaman `OwnerAnnouncementScreen` ke `ApiService.sendBroadcastNotification()`.
  - Menambahkan route dan logika *Broadcast Controller* di Backend Laravel untuk mengirim notifikasi massal ke tenant.
- **UI/UX Enhancement**: 
  - Modularisasi `QuickMenuGrid` menjadi widget independen dengan LayoutBuilder dan Wrap agar responsif di seluruh rasio layar *smartphone*.
  - Penyamaan desain *Quick Menu* Owner dan Tenant (grid 3-kolom bergaya kartu putih berbayang premium).
  - Penyesuaian `expandedHeight` pada header dan perbaikan *overflow* di halaman `ProfileScreen`.
  - Re-strukturisasi Bottom Navigation Tenant: memindahkan menu Bantuan ke tengah (benjolan) dan Komplain ke urutan setelahnya.
  - *Clean-up* linting: Menghapus import usang, menghapus *dead code*, dan menyelesaikan _deprecated withOpacity_ issues.

## [Versi 1.5.0] - Owner Redesign & Null-Safety Audit

## [Versi 1.4.2] - Code Audit & Optimization
**Optimasi:**
- **Performance Clean-up**: Inisialisasi daftar halaman (pages) dipindahkan ke `initState` di `TenantMainScreen` untuk efisiensi render.
- **Transaction UI Redesign**: Penyesuaian tampilan daftar tagihan dengan gaya kartu premium yang selaras dengan Dashboard.
- **Navigation Logic Fix**: Tombol back dan drawer sekarang muncul secara cerdas (dinamis) tergantung bagaimana halaman dibuka (sebagai tab atau pushed screen).
- **Dead Code Removal**: Penghapusan baris kode yang tidak terpakai dan komentar "sampah" di seluruh halaman tenant.
- **State Persistence**: Implementasi `KeepAlive` pada seluruh halaman utama navigasi bawah agar data tidak reload saat pindah menu.

## [Versi 1.4.1] - UX Optimization & User Security
**Ditambahkan:**
- **Visual Feedback System**: Implementasi efek ripple/splash (InkWell) pada semua elemen interaktif untuk pengalaman pengguna yang lebih responsif.
- **Secure Logout Flow**: Penambahan fungsi logout di `ApiService` yang menghapus sesi lokal (token, role) dan mengarahkan kembali ke login.
- **Descriptive Support Modal**: Modal bantuan yang lebih informatif dengan panduan kontak (WhatsApp & Telepon).
- **Animated Navigation Items**: Penambahan animasi skala dan transisi warna pada item navigasi bawah.

## [Versi 1.4.0] - Tenant Dashboard Redesign & Premium Navigation
**Ditambahkan:**
- **Premium Bottom Navigation**: Implementasi `CustomBottomNav` baru dengan desain "floating center button" untuk akses cepat komplain.
- **Modern Tenant Dashboard**: Redesign total halaman utama penyewa dengan header gradien, grid menu 4x2 (White Card Style), dan ringkasan tagihan yang informatif.
- **Recent Bills Preview**: Penambahan daftar tagihan terbaru langsung di dashboard tenant untuk kemudahan monitoring.
- **Enhanced Visual Hierarchy**: Penggunaan kartu melengkung (rounded cards) dan bayangan halus (soft shadows) sesuai standar desain UI modern.
- **Modular Dashboard Components**: Pemisahan logic UI dashboard menjadi fungsi-fungsi builder yang rapi dan mudah di-maintain.

**Diubah:**
- **Re-Hierarchy Dashboard Owner**: Urutan tata letak yang lebih logis (Search Bar -> Monitoring Card -> Quick Menu).
- **Simplified Quick Menu**: Menghapus tombol redundan "Penyewa" pada dashboard owner dan mengoptimalkan 3 tombol utama tenant (Tagihan, Komplain, Bantuan).
- **Asset Integration**: Menggunakan `New_Icon_Pure.png` sebagai indikator visual status kamar yang lebih modern.
- **Navigation Stability**: Perbaikan bug "Black Screen" pada tombol Back dengan pengecekan `Navigator.canPop`.

**Dibersihkan:**
- Penghapusan unused imports dan standarisasi `const` di seluruh file dashboard, laporan, dan transaksi (Clean Lint Warnings).

---

**Ditambahkan:**
- Sistem Penagihan Otomatis (Backend): Menghitung total biaya berdasarkan (Harga x Durasi Sewa).
- Fitur Pilihan Metode Pembayaran (Penyewa): Opsi Transfer Bank atau Tunai/Cash.
- Label Metode Pembayaran di sisi Pemilik untuk transparansi verifikasi.
- Utility `formatters.dart` untuk konversi otomatis nominal ke format Rupiah standar (titik ribuan).
- Rincian kalkulasi transparan pada tagihan penyewa (Contoh: Rp 500.000 x 3 Bulan).
- Tombol Edit & Hapus Kamar yang sudah aktif di Dashboard Owner.

**Diubah (Poles UI):**
- Desain ulang `KamarFormScreen` dengan gaya premium dan input modern.
- Desain ulang `OwnerUserList` (Daftar Penyewa) dengan kartu profil elegan.
- Desain ulang `AddTenancyScreen` (Pendaftaran Penyewa) dengan header gradient.
- Standarisasi header dan padding (25px) di seluruh halaman utama.
- Perbaikan bug tombol "Bayar" yang tidak hilang pada metode Tunai.

## [Versi 1.1.0] - Restrukturisasi & Fitur Dashboard
**Ditambahkan:**
- Folder struktur modular: `lib/models`, `lib/services`, `lib/providers`, `lib/widgets`.
- Folder fitur: `lib/screens/auth`, `lib/screens/owner`, `lib/screens/tenant`.
- Halaman `TenantDashboard` yang menampilkan Info Kamar, Tagihan, Riwayat Pembayaran, dan Komplain penyewa.
- Tombol Logout di Dashboard.
- File `workflow_kosan.md` untuk memisahkan dokumentasi alur kerja.
- Halaman `RoomDetailScreen` (Fitur Owner) untuk melihat data detail kamar, penyewa, pembayaran, dan laporan dengan tampilan berbasis Card.

**Diubah:**
- Memindahkan `login_screen.dart` dan `register_screen.dart` ke folder `auth`.
- Memindahkan dan mengubah nama `dashboard_pemilik.dart` menjadi `owner_dashboard.dart` ke folder `owner`.
- Memindahkan dan mengubah nama `dashboard_penyewa.dart` menjadi `tenant_dashboard.dart` ke folder `tenant`.
- Mengubah fungsi tombol aksi di `owner_dashboard.dart` untuk membuka `RoomDetailScreen`.
- Memisahkan dokumentasi alur aplikasi ke `workflow_kosan.md`.

**Dihapus:**
- File UI lama yang tidak dipakai di *root folder* `lib/screens/`.

---

## [Versi 1.0.0] - Inisiasi Proyek
**Ditambahkan:**
- Splash Screen dengan icon rumah kos dan timer 3 detik.
- Welcome Page/Login Screen sederhana dengan verifikasi dummy data.
- Register Screen sederhana dengan pilihan role (Pemilik/Penyewa).

**Dihapus:**
- Menghapus template counter bawaan Flutter (`MyHomePage`).
- Menghapus `welcome_screen.dart` karena alurnya digabung ke `login_screen.dart`.

---

# Panduan Pengembangan (Development Setup Guide)

Bagian ini berisi panduan teknis untuk menghubungkan Frontend (Flutter) dengan Backend (Laravel API) selama proses pengembangan, baik menggunakan emulator maupun perangkat fisik.

---

## 1. ADB Reverse (Rekomendasi untuk Emulator Android)

### Fungsi bagi Pengembangan:
`adb reverse` digunakan untuk meneruskan lalu lintas jaringan dari port emulator Android ke port komputer host (laptop).
* **Masalah**: Emulator Android berjalan di jaringan virtual terisolasi. Jika aplikasi Flutter memanggil `http://localhost:8000`, ia akan mencari port tersebut di dalam emulator itu sendiri, sehingga menghasilkan error *Connection Refused*.
* **Solusi**: `adb reverse` membuat jembatan langsung dari emulator ke laptop.
* **Keuntungan**: Sangat cepat (koneksi lokal, tanpa internet) dan kamu tidak perlu mengubah base URL di Flutter jika laptop berganti jaringan WiFi (IP laptop berubah).

### Langkah Setup:
1. Jalankan emulator Android kamu (melalui VS Code atau Android Studio).
2. Setelah emulator menyala penuh, buka terminal di laptop dan jalankan perintah:
   ```powershell
   adb reverse tcp:8000 tcp:8000
   ```
   *(Catatan: Sesuaikan `8000` dengan port tempat Laravel API berjalan).*

### Penyesuaian Kode:
Pada file `lib/services/api_service.dart`, atur `baseUrl` ke `localhost`:
```dart
static const String baseUrl = "http://localhost:8000/api";
```

---

## 2. Localtunnel (Rekomendasi untuk HP Fisik / Demo Jarak Jauh)

### Fungsi bagi Pengembangan:
Localtunnel membuat terowongan aman (secure tunnel) dari internet global langsung ke port lokal komputer kamu, menghasilkan URL publik dengan protokol HTTPS.
* **Masalah**: Menguji aplikasi di HP fisik yang dicolok kabel biasanya memerlukan konfigurasi IP lokal (`192.168.x.x`) dan mengharuskan kedua perangkat berada di WiFi yang sama. Selain itu, Android secara default memblokir request non-HTTPS (`http://`).
* **Solusi**: Localtunnel mengekspos port Laravel lokal kamu ke internet secara gratis dan instan dengan enkripsi SSL/HTTPS.
* **Keuntungan**: HP fisik bisa mengakses API Laravel meskipun menggunakan paket data seluler di luar rumah, dan kamu bisa membagikan URL ini ke orang lain (misal bimbingan dengan dosen pembimbing) secara real-time.

### Langkah Setup:
1. Pastikan Node.js sudah terinstal di komputermu.
2. Jalankan Laravel API (`php artisan serve`).
3. Buka terminal baru dan jalankan perintah:
   ```powershell
   npx localtunnel --port 8000
   ```
   *(Tips: Jika ingin nama subdomain tetap dan tidak acak setiap kali di-restart, gunakan parameter `--subdomain`, contoh: `npx localtunnel --port 8000 --subdomain kosmate-api`)*.

### Penyesuaian Kode:
1. Salin URL publik yang dihasilkan oleh localtunnel (misal: `https://kosmate-api.loca.lt`).
2. Tempelkan URL tersebut ke `baseUrl` di file `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = "https://kosmate-api.loca.lt/api";
   ```
3. **Penting**: Saat pertama kali mengakses link localtunnel dari browser/perangkat, biasanya ada halaman intersisial (halaman pengaman dari localtunnel). Pastikan untuk mengklik tombol konfirmasi sekali pada browser HP agar request API dari Flutter tidak terhambat halaman tersebut.

