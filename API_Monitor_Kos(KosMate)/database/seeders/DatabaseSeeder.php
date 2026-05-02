<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\kamar;
use App\Models\penyewaan;
use App\Models\pembayaran;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Database\Eloquent\Model;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        Model::unguard(); // Disable mass assignment checks for seeding

        // 1. Create Users
        $pemilik = User::create([
            'name' => 'Bapak Kos',
            'email' => 'pemilik@gmail.com', // Bedakan agar tidak tabrakan
            'password' => Hash::make('123'),
            'role' => 'pemilik',
            'no_hp' => '081234567890',
            'status' => 'aktif',
        ]);

        $penyewa = User::create([
            'name' => 'Budi Penyewa',
            'email' => 'penyewa@gmail.com',
            'password' => Hash::make('123'),
            'role' => 'penyewa',
            'no_hp' => '089876543210',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Siti Aminah',
            'email' => 'siti@gmail.com',
            'password' => Hash::make('123'),
            'role' => 'penyewa',
            'no_hp' => '081222333444',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Agus Santoso',
            'email' => 'agus@gmail.com',
            'password' => Hash::make('123'),
            'role' => 'penyewa',
            'no_hp' => '085566778899',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Dewi Lestari',
            'email' => 'dewi@gmail.com',
            'password' => Hash::make('123'),
            'role' => 'penyewa',
            'no_hp' => '081122334455',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Eko Prasetyo',
            'email' => 'eko@gmail.com',
            'password' => Hash::make('123'),
            'role' => 'penyewa',
            'no_hp' => '082233445566',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Fitriani',
            'email' => 'fitri@gmail.com',
            'password' => Hash::make('123'),
            'role' => 'penyewa',
            'no_hp' => '083344556677',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Guntur Wibowo',
            'email' => 'guntur@gmail.com',
            'password' => Hash::make('123'),
            'role' => 'penyewa',
            'no_hp' => '084455667788',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Hani Safitri',
            'email' => 'hani@gmail.com',
            'password' => Hash::make('123'),
            'role' => 'penyewa',
            'no_hp' => '085566778800',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Indra Wijaya',
            'email' => 'indra@gmail.com',
            'password' => Hash::make('123'),
            'role' => 'penyewa',
            'no_hp' => '086677889911',
            'status' => 'aktif',
        ]);

        User::create([
            'name' => 'Joko Susilo',
            'email' => 'joko@gmail.com',
            'password' => Hash::make('123'),
            'role' => 'penyewa',
            'no_hp' => '087788990022',
            'status' => 'aktif',
        ]);

        // 2. Create Kamar
        $kamarA1 = kamar::create([
            'nomor_kamar' => 'A1',
            'tipe_kamar' => 'Standar',
            'harga_sewa' => 800000,
            'status' => 'terisi',
            'keterangan' => 'Kamar standar AC',
        ]);

        kamar::create([
            'nomor_kamar' => 'A2',
            'tipe_kamar' => 'Standar',
            'harga_sewa' => 800000,
            'status' => 'kosong',
            'keterangan' => 'Kamar standar Non-AC',
        ]);

        kamar::create([
            'nomor_kamar' => 'B1',
            'tipe_kamar' => 'VIP',
            'harga_sewa' => 1000000,
            'status' => 'kosong',
            'keterangan' => 'Kamar luas dengan jendela',
        ]);

        kamar::create([
            'nomor_kamar' => 'B2',
            'tipe_kamar' => 'VIP',
            'harga_sewa' => 1000000,
            'status' => 'kosong',
            'keterangan' => 'Kamar VIP lantai 2',
        ]);

        kamar::create([
            'nomor_kamar' => 'C1',
            'tipe_kamar' => 'Exclusive',
            'harga_sewa' => 1500000,
            'status' => 'kosong',
            'keterangan' => 'Kamar paling luas, Smart TV',
        ]);

        kamar::create([
            'nomor_kamar' => 'C2',
            'tipe_kamar' => 'Exclusive',
            'harga_sewa' => 1500000,
            'status' => 'kosong',
            'keterangan' => 'Kamar paling luas, Balkon',
        ]);

        kamar::create([
            'nomor_kamar' => 'A3',
            'tipe_kamar' => 'Standar',
            'harga_sewa' => 800000,
            'status' => 'kosong',
            'keterangan' => 'Kamar standar AC ekonomis',
        ]);

        kamar::create([
            'nomor_kamar' => 'B3',
            'tipe_kamar' => 'VIP',
            'harga_sewa' => 1000000,
            'status' => 'kosong',
            'keterangan' => 'Kamar VIP nyaman',
        ]);

        kamar::create([
            'nomor_kamar' => 'D1',
            'tipe_kamar' => 'Suite',
            'harga_sewa' => 2000000,
            'status' => 'kosong',
            'keterangan' => 'Suite Room dengan Pantry',
        ]);

        kamar::create([
            'nomor_kamar' => 'D2',
            'tipe_kamar' => 'Suite',
            'harga_sewa' => 2000000,
            'status' => 'kosong',
            'keterangan' => 'Suite Room Premium',
        ]);

        // 3. Create Penyewaan
        $penyewaan = penyewaan::create([
            'users_id' => $penyewa->id,
            'kamars_id' => $kamarA1->id,
            'tanggal_masuk' => '2024-01-01',
            'lama_sewa' => 12, // bulan
            'status_sewa' => 'aktif',
        ]);

        // 4. Create Pembayaran
        pembayaran::create([
            'penyewaans_id' => $penyewaan->id,
            'periode' => '2024-04-01',
            'jumlah' => 800000,
            'tanggal_bayar' => '2024-04-05',
            'status' => 'lunas',
            'metode' => 'Transfer Bank',
            'keterangan' => 'Pembayaran bulan April',
        ]);

        Model::reguard();
    }
}
