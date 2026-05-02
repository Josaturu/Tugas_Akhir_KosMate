<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\penyewaan;

class TenancyController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        
        // Ambil penyewaan aktif milik user ini, sertakan data kamar dan pembayaran
        $tenancy = penyewaan::with(['kamar', 'pembayarans'])
            ->where('users_id', $user->id)
            ->where('status_sewa', 'aktif')
            ->first();

        if (!$tenancy) {
            return response()->json(['message' => 'Anda belum memiliki data sewa aktif'], 404);
        }

        return response()->json($tenancy);
    }

    public function store(Request $request)
    {
        $request->validate([
            'users_id' => 'required|exists:users,id',
            'kamars_id' => 'required|exists:kamars,id',
            'tanggal_masuk' => 'required|date',
            'lama_sewa' => 'required|integer',
        ]);

        return \DB::transaction(function () use ($request) {
            // 1. Proteksi: Cek apakah User sudah menyewa kamar lain yang aktif
            $userHasActiveTenancy = penyewaan::where('users_id', $request->users_id)
                ->where('status_sewa', 'aktif')
                ->exists();
            
            if ($userHasActiveTenancy) {
                return response()->json([
                    'message' => 'Penyewa ini masih memiliki status sewa aktif di kamar lain.'
                ], 400);
            }

            // 2. Update status kamar menjadi 'terisi'
            $kamar = \App\Models\kamar::find($request->kamars_id);
            if ($kamar->status == 'terisi') {
                return response()->json(['message' => 'Kamar sudah terisi'], 400);
            }
            $kamar->update(['status' => 'terisi']);

            // 2. Simpan data penyewaan
            $penyewaan = penyewaan::create([
                'users_id' => $request->users_id,
                'kamars_id' => $request->kamars_id,
                'tanggal_masuk' => $request->tanggal_masuk,
                'lama_sewa' => $request->lama_sewa,
                'status_sewa' => 'aktif'
            ]);

            // 3. Otomatis Generate Tagihan Pertama (Total Selama Masa Sewa)
            \App\Models\pembayaran::create([
                'penyewaans_id' => $penyewaan->id,
                'periode' => date('Y-m-01'), 
                'jumlah' => $kamar->harga_sewa * $request->lama_sewa, // Harga x Durasi
                'status' => 'menunggu', 
            ]);

            return response()->json([
                'message' => 'Penyewa berhasil didaftarkan dan tagihan telah dibuat',
                'data' => $penyewaan
            ], 201);
        });
    }
}
