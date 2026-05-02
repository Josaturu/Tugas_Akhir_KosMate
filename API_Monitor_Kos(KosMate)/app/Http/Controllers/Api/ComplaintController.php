<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use App\Models\Notification;
use Illuminate\Http\Request;

class ComplaintController extends Controller
{
    // Tenant: Kirim Komplain
    public function store(Request $request)
    {
        $request->validate([
            'kamar_id' => 'required',
            'category' => 'required',
            'description' => 'required',
        ]);

        $complaint = Complaint::create([
            'user_id' => auth()->id(),
            'kamar_id' => $request->kamar_id,
            'category' => $request->category,
            'description' => $request->description,
            'status' => 'pending',
        ]);

        // Kirim Notifikasi ke Owner (Asumsi User ID 1 adalah Owner)
        Notification::create([
            'user_id' => 1, 
            'title' => 'Komplain Baru',
            'message' => 'Ada komplain baru kategori ' . $request->category . ' di Kamar ' . $complaint->kamar->nomor_kamar,
            'type' => 'complaint',
            'related_id' => $complaint->id,
        ]);

        return response()->json(['message' => 'Komplain berhasil dikirim', 'data' => $complaint]);
    }

    // Owner: Lihat Semua Komplain
    public function index()
    {
        $complaints = Complaint::with(['user', 'kamar'])->latest()->get();
        return response()->json($complaints);
    }

    // Tenant: Lihat Komplain Saya
    public function myComplaints()
    {
        $complaints = Complaint::with('kamar')->where('user_id', auth()->id())->latest()->get();
        return response()->json($complaints);
    }

    // Owner: Update Status Komplain
    public function updateStatus(Request $request, $id)
    {
        $complaint = Complaint::findOrFail($id);
        $complaint->update(['status' => $request->status]);

        // Kirim Notifikasi Balik ke Tenant
        Notification::create([
            'user_id' => $complaint->user_id,
            'title' => 'Update Komplain',
            'message' => 'Komplain Anda tentang ' . $complaint->category . ' sekarang berstatus: ' . $request->status,
            'type' => 'complaint',
            'related_id' => $complaint->id,
        ]);

        return response()->json(['message' => 'Status komplain diperbarui']);
    }
}
