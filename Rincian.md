# Rincian Proyek KosMate (Changelog & Dokumentasi Teknis)

Dokumen ini berisi penjelasan komprehensif mengenai aplikasi **KosMate**, mulai dari arsitektur, struktur kode, aliran data, hingga analisis kelebihan dan kekurangan sistem. Dokumen ini dirancang khusus sebagai panduan teknis sekaligus referensi utama untuk kebutuhan Tugas Akhir (TA) dan Ujian Kompetensi (Ujikom).

---

## 1. Tentang Project Ini (Overview)
**KosMate** adalah platform manajemen kos terintegrasi yang menggabungkan aplikasi *mobile* berbasis **Flutter** (Frontend) dengan RESTful API berbasis **Laravel** (Backend). Aplikasi ini dirancang untuk mendigitalisasi dan menyederhanakan seluruh alur operasional pengelolaan rumah kos, yang sebelumnya didominasi oleh pencatatan manual.

KosMate berfokus pada dua aktor utama dengan fungsionalitas yang berbeda (*Dual-Role*):
*   **Pemilik Kos (Owner):** Memiliki kontrol penuh untuk mengelola kamar (CRUD), memantau status hunian lewat dashboard interaktif, mengelola penyewa, memverifikasi pembayaran (Transfer/Cash) secara langsung, serta mengirim pengumuman massal (*broadcast*) ke semua pengguna terdaftar.
*   **Penyewa Kos (Tenant):** Dapat memantau informasi kamar yang aktif, melihat ringkasan tagihan bulanan secara cerdas (*Smart Billing Summary*), melaporkan pembayaran bulanan secara mandiri (unggah bukti transfer atau klaim cash), mengirim pengaduan kerusakan/keluhan (komplain), serta membaca pengumuman dari pemilik kos.

---

## 2. Tech Stack & Struktur Monorepo

### Teknologi yang Digunakan (Tech Stack)
1.  **Frontend (Mobile App):**
    *   **Framework:** Flutter (SDK 3.x) & Dart.
    *   **HTTP Client:** `http` package untuk berkomunikasi dengan REST API.
    *   **Local Storage:** `shared_preferences` untuk menyimpan session token (Bearer Token) dan data role pengguna secara persisten.
    *   **Styling & UI:** Vanilla Flutter Custom Widgets dengan desain premium modern (soft shadows, rounded borders, sliver headers, dan skema warna harmonis).
2.  **Backend (RESTful API):**
    *   **Framework:** Laravel 13.
    *   **Database:** MySQL.
    *   **Autentikasi:** Laravel Sanctum (Token-Based Authentication).
    *   **ORM:** Eloquent untuk pemetaan data database ke model OOP.

---

## 3. Penjelasan Struktur Folder dan Fungsi File

Proyek ini menggunakan struktur monorepo yang memisahkan aplikasi API dan Mobile di tingkat root:

```text
Tugas_Akhir_KosMate/
│
├── API_Monitor_Kos(KosMate)/      <-- Backend Laravel 13
└── Mobile_Monitor_Kos(KosMate)/   <-- Frontend Flutter Mobile
```

### A. Struktur Backend: `API_Monitor_Kos(KosMate)`

Berikut adalah folder-folder kunci di dalam proyek Laravel beserta fungsinya:

*   **`app/Models/`** (Representasi struktur tabel database):
    *   `User.php`: Mengelola data akun pengguna, role (`pemilik`/`penyewa`), password yang di-hash, dan relasi ke penyewaan.
    *   `kamar.php`: Mengelola nomor kamar, tipe, harga sewa, status ketersediaan (`kosong`, `terisi`, `maintenance`), dan keterangan tambahan.
    *   `penyewaan.php`: Penghubung transaksi antara `User` and `Kamar`. Mencatat tanggal masuk, lama sewa (dalam bulan), dan status sewa aktif.
    *   `pembayaran.php`: Mengelola data tagihan bulanan, nominal, status (`pending`, `menunggu_konfirmasi`, `lunas`), metode (`Transfer`/`Tunai`), dan bukti bayar.
    *   `Complaint.php`: Mengelola data pengaduan kerusakan dari penyewa.
    *   `Notification.php`: Menyimpan notifikasi sistem dan data pesan *broadcast*.

*   **`app/Http/Controllers/Api/`** (Pusat logika bisnis & REST API):
    *   `AuthController.php`: Logika login (generate token Sanctum) dan register akun baru.
    *   `KamarController.php`: Logika CRUD kamar kos untuk pemilik.
    *   `UserController.php`: Mengelola profil user dan mengambil data penyewa terdaftar.
    *   `TenancyController.php`: Pendaftaran penyewa baru ke kamar tertentu (*check-in*).
    *   `PembayaranController.php`: Manajemen tagihan, generate otomatis tagihan bulanan, pelaporan bukti bayar oleh penyewa, dan konfirmasi pembayaran oleh pemilik.
    *   `ComplaintController.php`: Pengiriman komplain oleh tenant dan update status penanganan komplain oleh owner.
    *   `NotificationController.php`: Mengambil riwayat notifikasi serta mengirimkan pengumuman global (*broadcast*).

*   **`routes/api.php`** (Definisi endpoint API):
    *   Mengatur rute publik (`/login`, `/register`) dan rute yang diproteksi oleh middleware `auth:sanctum` agar hanya bisa diakses oleh pengguna yang memiliki token valid.

*   **`database/migrations/`** (Skema database):
    *   Menciptakan tabel-tabel terelasi (`users`, `kamars`, `penyewaans`, `pembayarans`, `complaints`, `notifications`) di dalam MySQL secara konsisten.

---

### B. Struktur Frontend: `Mobile_Monitor_Kos(KosMate)`

Struktur folder Flutter didesain modular di bawah direktori `lib/`:

*   **`lib/models/`**:
    *   `kamar_model.dart`: Melakukan serialisasi data JSON dari Laravel API menjadi Object Dart yang aman digunakan di dalam UI (*Null-Safety*).
*   **`lib/services/`**:
    *   `api_service.dart`: Berisi fungsi-fungsi HTTP Request (GET, POST, PUT, DELETE) yang langsung terhubung ke server Laravel. Secara otomatis menyisipkan `Authorization: Bearer <Token>` pada header request.
*   **`lib/utils/`** (Fungsi pembantu):
    *   `formatters.dart`: Konversi angka nominal ke format Rupiah standar (contoh: `Rp 1.500.000`).
    *   `validators.dart`: Fungsi validasi form untuk memastikan kolom input tidak kosong dan berformat benar.
    *   `snackbar_helper.dart`: Menampilkan notifikasi umpan balik sukses/gagal yang seragam di seluruh aplikasi.
*   **`lib/screens/`** (Halaman Tampilan):
    *   `auth/`: `login_screen.dart` (Halaman masuk) & `register_screen.dart` (Pendaftaran akun).
    *   `splash_screen.dart`: Halaman animasi pembuka selama 3 detik.
    *   `profile_screen.dart`: Halaman akun untuk melihat biodata dan tombol logout aman.
    *   `owner/` (Halaman khusus Pemilik):
        *   `owner_main_screen.dart`: Struktur navigasi bawah owner.
        *   `owner_dashboard.dart`: Dashboard ringkasan kamar (Total, Terisi, Kosong) dan menu cepat.
        *   `owner_room_list_screen.dart`: Halaman manajemen unit kamar dengan fitur pencarian & akses CRUD.
        *   `kamar_form_screen.dart`: Form untuk menambah, mengedit, serta menghapus data kamar kos.
        *   `owner_user_list.dart`: Daftar seluruh penyewa terdaftar.
        *   `owner_transaction_list.dart`: Daftar transaksi pembayaran bulanan yang masuk untuk diverifikasi.
        *   `owner_announcement_screen.dart`: Form untuk menulis dan mengirim pengumuman broadcast.
    *   `tenant/` (Halaman khusus Penyewa):
        *   `tenant_dashboard.dart`: Dashboard penyewa berisi status sewa aktif dan status tagihan bulanan berjalan.
        *   `tenant_room_detail_screen.dart`: Detail spesifikasi kamar yang ditempati beserta profil pemilik kos.
        *   `tenant_transaction_list.dart`: Halaman pelaporan pembayaran (input bukti transfer/lapor tunai).
        *   `tenant_complaint_screen.dart`: Halaman pelaporan keluhan kerusakan fasilitas kos.
*   **`lib/widgets/`** (Komponen UI Reusable):
    *   `global_sliver_header.dart`: Header premium dengan efek paralaks yang menjaga konsistensi visual di seluruh halaman.
    *   `custom_bottom_nav.dart`: Navigasi bawah modern yang dinamis (menampilkan tombol melayang/benjolan di sisi tenant).

---

## 4. Aliran Data Aplikasi (Data Flow)

### A. Alur Autentikasi (Login & Session Persistence)
1.  **Pengiriman Data:** Pengguna memasukkan email dan password di `login_screen.dart`, lalu menekan tombol "Login".
2.  **API Call:** Flutter mengirim permintaan POST ke `/api/login` melalui `ApiService.login()`.
3.  **Proses Server:** `AuthController` di backend mencocokkan email di database MySQL. Jika password cocok, Laravel Sanctum men-generate token akses baru.
4.  **Respon API:** Server mengembalikan data JSON berisi profil pengguna, role, dan session token.
5.  **Local Persistence:** Flutter menyimpan token dan role tersebut menggunakan `SharedPreferences` agar user tetap masuk (*stay logged in*) meskipun aplikasi ditutup.

### B. Alur Penagihan & Verifikasi Pembayaran (Smart Billing Flow)
1.  **Inisiasi Tagihan:** Pemilik kos men-generate tagihan untuk penyewa melalui menu transaksi. Baris baru terbentuk di tabel `pembayarans` dengan status `pending`.
2.  **Membaca Status Tagihan:** Saat aplikasi Tenant dibuka, Flutter meminta data penyewaan aktif melalui `getMyTenancy()`.
    *   Jika belum sewa -> Tampil status **"Belum Aktif"** (Warna Abu-abu).
    *   Jika sudah sewa tapi tagihan belum diterbitkan -> Tampil **"Belum Ada Tagihan"** (Warna Biru).
    *   Jika ada tagihan tertunggak -> Tampil **Nominal Tagihan** (Warna Oranye).
3.  **Melakukan Pembayaran:** Tenant memilih tagihan tersebut di aplikasi, menentukan metode pembayaran (`Transfer` atau `Tunai`), mengunggah bukti jika memilih transfer, dan menekan tombol konfirmasi.
4.  **Mengirim Data Laporan:** Aplikasi mengirim data via POST ke `/api/pembayaran/upload-bukti/{id}`. Status tagihan di database berubah menjadi `menunggu_konfirmasi`.
5.  **Verifikasi Pemilik:** Pemilik kos membuka menu transaksi di aplikasi, melihat laporan tagihan masuk lengkap dengan **Metode Pembayaran** (Transfer/Tunai) dan **Bukti Bayar**.
6.  **Konfirmasi Sukses:** Pemilik menekan tombol **"Konfirmasi Pembayaran"**. Flutter mengirim POST ke `/api/pembayaran/konfirmasi/{id}`.
7.  **Update Database & Dashboard:** Status di database berubah menjadi `lunas`. Ketika tenant me-refresh dashboard, status tagihan otomatis berubah menjadi **"Lunas"** dengan ikon centang hijau.

---

## 5. Kelebihan dan Kekurangan Proyek

### Kelebihan Proyek (Strengths)
1.  **Desain UI/UX Premium & Konsisten:** Penggunaan widget custom seperti `GlobalSliverHeader` dan skema warna oranye-putih yang harmonis membuat aplikasi terlihat mewah dan sangat profesional (standar industri).
2.  **Smart Billing Logic:** Penyajian status tagihan secara dinamis dan bertahap mencegah kebingungan penyewa baru yang belum memiliki unit kamar aktif.
3.  **Keamanan API dengan Laravel Sanctum:** Seluruh komunikasi data aman karena setiap endpoint yang bersifat sensitif dilindungi oleh token otentikasi yang divalidasi ketat oleh server.
4.  **Efisiensi Render State:** Penggunaan `KeepAlive` pada *PageController* utama di Flutter memastikan data tidak selalu memuat ulang (*reload*) saat pengguna berpindah menu, menghemat kuota internet dan baterai smartphone.
5.  **Penanganan Error yang Informatif:** Input form divalidasi langsung di sisi klien (*client-side validation*), dan pesan kegagalan dari database diparsing dengan baik oleh Flutter untuk ditampilkan ke pengguna.

### Kekurangan & Limitasi Proyek (Weaknesses & Bugs)
1.  **Simulasi Bukti Unggah Transfer:** Pada proses unggah bukti transfer, sistem saat ini masih menyimpan nama file atau path simulasi (*mock path*) di database, bukan mengunggah file gambar asli ke layanan *cloud storage* (seperti Amazon S3 atau Cloudinary). Namun secara alur logika database, hal ini sudah memadai untuk kebutuhan TA/Ujikom.
2.  **Ketiadaan Push Notifications:** Sistem notifikasi broadcast saat ini masih bersifat pasif (relies on API Polling/manual refresh), belum terintegrasi dengan layanan pengiriman pesan langsung secara real-time seperti *Firebase Cloud Messaging (FCM)*.
3.  **Skalabilitas Aktor Terbatas:** Arsitektur database saat ini dirancang untuk model kepemilikan kos tunggal (*Single-Owner*). Jika ingin dikembangkan menjadi aplikasi SaaS berskala besar di mana banyak pemilik kos mendaftar di satu aplikasi, diperlukan tabel relasi *tenancy* baru untuk memisahkan kepemilikan kosan secara logis.
