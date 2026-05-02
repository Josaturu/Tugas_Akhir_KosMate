<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\kamar;
use App\Models\pembayaran;
use App\Models\penyewaan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function getSummary(Request $request)
    {
        $bulan = $request->query('bulan', date('m'));
        $tahun = $request->query('tahun', date('Y'));

        // 1. Ringkasan Kamar
        $totalKamar = kamar::count();
        $kamarTerisi = kamar::where('status', 'terisi')->count();
        $kamarKosong = $totalKamar - $kamarTerisi;

        // 2. Pendapatan Bulan Ini
        $totalPemasukan = pembayaran::where('status', 'lunas')
            ->whereYear('tanggal_bayar', $tahun)
            ->whereMonth('tanggal_bayar', $bulan)
            ->sum('jumlah');

        // 3. Jumlah Tunggakan (Belum Lunas)
        $totalTunggakan = pembayaran::where('status', 'pending')
            ->where('periode', 'like', "$tahun-$bulan%")
            ->sum('jumlah');

        return response()->json([
            'summary' => [
                'total_kamar' => $totalKamar,
                'kamar_terisi' => $kamarTerisi,
                'kamar_kosong' => $kamarKosong,
                'total_pemasukan' => $totalPemasukan,
                'total_tunggakan' => $totalTunggakan,
            ]
        ]);
    }

    public function getPaymentReport(Request $request)
    {
        $bulan = $request->query('bulan', date('m'));
        $tahun = $request->query('tahun', date('Y'));

        $pembayarans = pembayaran::with(['penyewaan.user', 'penyewaan.kamar'])
            ->where('periode', 'like', "$tahun-$bulan%")
            ->get();

        return response()->json($pembayarans);
    }

    public function getTunggakanReport()
    {
        // Ambil penyewa yang status pembayarannya masih 'pending'
        $tunggakan = pembayaran::with(['penyewaan.user', 'penyewaan.kamar'])
            ->where('status', 'pending')
            ->orderBy('periode', 'asc')
            ->get();

        return response()->json($tunggakan);
    }

    public function getPenyewaAktifReport()
    {
        $penyewas = penyewaan::with(['user', 'kamar'])
            ->whereHas('kamar', function($query) {
                $query->where('status', 'terisi');
            })
            ->get();

        return response()->json($penyewas);
    }
}
