<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function getPenyewa()
    {
        // Ambil semua user yang rolenya penyewa dan cek apakah punya sewa aktif
        $users = User::where('role', 'penyewa')
            ->withCount(['penyewaans as active_tenancy_count' => function($query) {
                $query->where('status_sewa', 'aktif');
            }])
            ->get();
        
        return response()->json($users);
    }

    public function profile(Request $request)
    {
        return response()->json($request->user());
    }
}
