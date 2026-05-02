<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index()
    {
        $notifications = Notification::where('user_id', auth()->id())
            ->latest()
            ->get();
        return response()->json($notifications);
    }

    public function markAsRead($id)
    {
        $notification = Notification::where('user_id', auth()->id())->findOrFail($id);
        $notification->update(['is_read' => true]);
        return response()->json(['message' => 'Notifikasi dibaca']);
    }

    public function unreadCount()
    {
        $count = Notification::where('user_id', auth()->id())
            ->where('is_read', false)
            ->count();
        return response()->json(['unread_count' => $count]);
    }

    public function broadcast(Request $request)
    {
        $request->validate([
            'title' => 'required|string',
            'message' => 'required|string',
        ]);

        // Ambil semua user kecuali yang sedang login (owner)
        $tenants = \App\Models\User::where('id', '!=', auth()->id())->get();
        $count = 0;

        foreach ($tenants as $tenant) {
            Notification::create([
                'user_id' => $tenant->id,
                'title' => $request->title,
                'message' => $request->message,
                'is_read' => false,
            ]);
            $count++;
        }

        return response()->json([
            'success' => true,
            'message' => 'Pengumuman berhasil dikirim ke ' . $count . ' penyewa',
        ]);
    }
}
