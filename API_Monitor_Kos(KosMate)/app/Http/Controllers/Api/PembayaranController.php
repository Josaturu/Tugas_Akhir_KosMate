<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\pembayaran;
use App\Models\penyewaan;
use App\Models\Notification;

class PembayaranController extends Controller
{
    // List Pembayaran (Bisa untuk Owner maupun Tenant)
    public function index(Request $request)
    {
        $user = $request->user();
        $query = pembayaran::with(['penyewaan.user', 'penyewaan.kamar']);

        // Jika dia penyewa, tampilkan hanya milik dia
        if ($user->role == 'penyewa') {
            $query->whereHas('penyewaan', function($q) use ($user) {
                $q->where('users_id', $user->id);
            });
        } elseif ($user->role == 'pemilik') {
            // Optional: Jika owner hanya ingin melihat pembayaran untuk kamarnya sendiri
            // $query->whereHas('penyewaan.kamar', function($q) use ($user) { ... });
        }

        return response()->json($query->orderBy('periode', 'desc')->get());
    }

    // Owner Konfirmasi Pembayaran
    public function konfirmasi($id)
    {
        $pembayaran = pembayaran::find($id);
        if (!$pembayaran) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $pembayaran->update([
            'status' => 'lunas',
            'tanggal_bayar' => date('Y-m-d'),
        ]);

        // Notifikasi ke Tenant
        Notification::create([
            'user_id' => $pembayaran->penyewaan->users_id,
            'title' => 'Pembayaran Lunas',
            'message' => 'Pembayaran Anda untuk periode ' . substr($pembayaran->periode, 0, 7) . ' telah dikonfirmasi.',
            'type' => 'payment',
            'related_id' => $pembayaran->id,
        ]);

        return response()->json(['message' => 'Pembayaran berhasil dikonfirmasi']);
    }

    // Tenant Melaporkan Pembayaran (Transfer atau Tunai)
    public function uploadBukti(Request $request, $id)
    {
        $request->validate([
            'metode' => 'required|in:Transfer Bank,Tunai',
            'bukti' => 'required_if:metode,Transfer Bank',
        ]);
        
        $pembayaran = pembayaran::find($id);
        if (!$pembayaran) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $pembayaran->update([
            'bukti_pembayaran' => $request->bukti, // Null jika tunai
            'metode' => $request->metode,
            'keterangan' => $request->metode == 'Tunai' ? 'Penyewa melapor bayar tunai' : 'Penyewa melapor transfer bank',
        ]);

        // Notifikasi ke Owner (User ID 1)
        Notification::create([
            'user_id' => 1,
            'title' => 'Laporan Pembayaran',
            'message' => 'Penyewa Kamar ' . $pembayaran->penyewaan->kamar->nomor_kamar . ' telah melaporkan pembayaran via ' . $request->metode,
            'type' => 'payment',
            'related_id' => $pembayaran->id,
        ]);

        return response()->json(['message' => 'Laporan pembayaran berhasil dikirim']);
    }

    // Owner Generate Tagihan Bulan Berikutnya secara Manual
    public function generateNextBill(Request $request)
    {
        $request->validate([
            'penyewaans_id' => 'required|exists:penyewaans,id',
            'periode' => 'required' // Format YYYY-MM
        ]);

        // Validasi Duplikasi: Cek apakah periode ini sudah ada tagihannya
        $exists = pembayaran::where('penyewaans_id', $request->penyewaans_id)
            ->where('periode', 'LIKE', $request->periode . '%')
            ->exists();

        if ($exists) {
            return response()->json(['message' => 'Tagihan untuk periode ini sudah tersedia'], 400);
        }

        $penyewaan = penyewaan::with('kamar')->find($request->penyewaans_id);

        $newBill = pembayaran::create([
            'penyewaans_id' => $request->penyewaans_id,
            'periode' => $request->periode . '-01',
            'jumlah' => $penyewaan->kamar->harga_sewa,
            'status' => 'menunggu'
        ]);

        return response()->json([
            'message' => 'Tagihan periode ' . $request->periode . ' berhasil dibuat',
            'data' => $newBill
        ], 201);
    }
}
