<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\kamar;

class KamarController extends Controller
{
    public function index()
    {
        return response()->json(kamar::with(['penyewaans.user', 'penyewaans.pembayarans'])->get());
    }

    public function store(Request $request)
    {
        $request->validate([
            'nomor_kamar' => 'required',
            'tipe_kamar' => 'required',
            'harga_sewa' => 'required|numeric',
            'status' => 'required|in:kosong,terisi',
            'keterangan' => 'nullable'
        ]);

        $kamar = kamar::create($request->all());
        return response()->json([
            'message' => 'Data kamar berhasil ditambahkan',
            'data' => $kamar
        ], 201);
    }

    public function show($id)
    {
        $kamar = kamar::with(['penyewaans.user', 'penyewaans.pembayarans'])->find($id);
        if (!$kamar) return response()->json(['message' => 'Kamar tidak ditemukan'], 404);
        return response()->json($kamar);
    }

    public function update(Request $request, $id)
    {
        $kamar = kamar::find($id);
        if (!$kamar) return response()->json(['message' => 'Kamar tidak ditemukan'], 404);

        $request->validate([
            'nomor_kamar' => 'required',
            'tipe_kamar' => 'required',
            'harga_sewa' => 'required|numeric',
            'status' => 'required|in:kosong,terisi',
            'keterangan' => 'nullable'
        ]);

        $kamar->update($request->all());
        return response()->json($kamar);
    }

    public function destroy($id)
    {
        $kamar = kamar::find($id);
        if (!$kamar) return response()->json(['message' => 'Kamar tidak ditemukan'], 404);
        
        $kamar->delete();
        return response()->json(['message' => 'Data berhasil dihapus']);
    }
}
