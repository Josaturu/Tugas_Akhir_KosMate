# Alur Navigasi (Workflow) Info Kosan

Aplikasi ini menggunakan arsitektur folder modular (fitur `auth`, `owner`, dan `tenant`). Berikut adalah alur kerja aplikasinya:

1.  **Splash Screen** (`lib/screens/splash_screen.dart`):
    *   Muncul pertama kali saat aplikasi dibuka.
    *   Berlangsung selama **3 detik** menggunakan `Timer`.
    *   Otomatis pindah ke **Login Page**.

2.  **Login Page** (`lib/screens/auth/login_screen.dart`):
    *   Halaman utama untuk masuk ke aplikasi.
    *   Melakukan pengecekan role berdasarkan dummy data:
        *   Username: `pemilik`, Password: `123` -> Masuk ke **Owner Dashboard**.
        *   Username: `penyewa`, Password: `123` -> Masuk ke **Tenant Dashboard**.

3.  **Register Page** (`lib/screens/auth/register_screen.dart`):
    *   Halaman untuk mendaftar akun baru dengan pilihan role (Pemilik/Penyewa).

4.  **Owner Dashboard** (`lib/screens/owner/owner_dashboard.dart`):
    *   **Premium Header**: Header oranye luas dengan sapaan personal "Halo, Bapak Kos!".
    *   **Search & Filter**: Bar pencarian melayang dengan tombol filter terintegrasi.
    *   **Monitoring Section**: Barisan 4 kartu statistik (Total, Terisi, Kosong, Maintenance).
    *   **Quick Menu Grid**: 6 menu akses cepat dengan layout 3-kolom bergaya kartu berbayang (Penyewa, Tagihan, Laporan, Pengumuman, Komplain, Pengaturan).
    *   **Horizontal Room List**: Daftar kamar model horizontal dengan detail penghuni dan status badge.
    *   **Flat Navigation**: Navigasi bawah premium tanpa benjolan tengah untuk efisiensi ruang.

5.  **Room Detail Screen** (`lib/screens/owner/room_detail_screen.dart`):
    *   Menampilkan detail kamar secara lengkap (Data Penyewa, Pembayaran, Laporan).
    *   **Room Management**: Tersedia tombol Edit dan **Hapus Kamar** (dengan konfirmasi). Navigasi setelah hapus akan otomatis dialihkan kembali ke Dashboard.

6.  **Tenant Dashboard** (`lib/screens/tenant/tenant_dashboard.dart`):
    *   **Premium Header**: Header gradien dengan sapaan personal dan akses notifikasi.
    *   **Smart Billing Summary**: Menampilkan status dinamis berdasarkan kondisi penyewaan:
        *   **Penyewaan Belum Aktif**: Jika user belum terdaftar di unit kamar manapun.
        *   **Belum Ada Tagihan**: Jika sudah sewa tapi tagihan bulan berjalan belum diterbitkan.
        *   **Nominal Tagihan (Oranye)**: Jika ada tagihan yang harus dibayar.
        *   **Lunas (Hijau)**: Jika tagihan sudah terbayar dan terkonfirmasi.
    *   **Main Menu Grid**: Akses cepat ke 6 layanan (Tagihan, Komplain, Bantuan, Pengumuman, Info Kos, Pengaturan).
    *   **Recent Bills List**: Tampilan 3 transaksi terakhir untuk pemantauan cepat.
    *   **Room Info Card**: Informasi kamar aktif yang sedang disewa.

7.  **Navigasi Utama Tenant** (`lib/screens/tenant/tenant_main_screen.dart`):
    *   Menggunakan `CustomBottomNav` dengan 5 menu utama yang dianimasikan.
    *   **State Persistence**: Seluruh halaman utama menggunakan `KeepAlive` sehingga tidak terjadi reload saat berpindah tab.
    *   **Smart Navigation**: Tombol navigasi (back/drawer) menyesuaikan diri secara otomatis berdasarkan konteks tumpukan halaman (stack).
    *   **Center Action Button**: Tombol benjolan tengah khusus untuk mengakses Bantuan (Kontak Owner) secara instan.
    *   **Interactive Support**: Akses modal bantuan deskriptif dari navigasi bawah.
    *   **Account Management**: Halaman profil untuk melihat data diri dan melakukan logout aman.
    *   **Real-time Alerts**: Muncul saat ada tagihan baru atau komplain masuk.
    *   **Deep Linking**: Mengetuk notifikasi akan langsung mengarahkan ke halaman detail yang relevan (Tagihan atau Komplain) sesuai role user.
    *   **Smart Back**: Tombol back cerdas di header yang otomatis berubah menjadi tombol drawer jika tidak ada riwayat navigasi.

8.  **Alur Penagihan (Billing Flow)**:
    *   **Penyewa:** Klik tombol 'Bayar' -> Pilih Metode (**Transfer** atau **Tunai**).
    *   **Jika Transfer:** Upload simulasi bukti -> Status: Menunggu Verifikasi.
    *   **Jika Tunai:** Klik konfirmasi lapor tunai -> Status: Menunggu Konfirmasi (Tanpa Upload).
    *   **Pemilik:** Melihat riwayat transaksi (Dilengkapi keterangan metode Transfer/Tunai) -> Klik 'Konfirmasi' -> Status: Lunas.

