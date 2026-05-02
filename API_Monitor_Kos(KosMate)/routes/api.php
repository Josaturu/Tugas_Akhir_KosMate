<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\KamarController;
use App\Http\Controllers\Api\TenancyController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\PembayaranController;
use App\Http\Controllers\Api\ComplaintController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ReportController;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/kamar', [KamarController::class, 'index']);
    Route::post('/kamar', [KamarController::class, 'store']);
    Route::get('/kamar/{id}', [KamarController::class, 'show']);
    Route::put('/kamar/{id}', [KamarController::class, 'update']);
    Route::delete('/kamar/{id}', [KamarController::class, 'destroy']);
    Route::get('/my-tenancy', [TenancyController::class, 'index']);
    Route::post('/store-penyewaan', [TenancyController::class, 'store']);
    
    Route::get('/get-penyewa', [UserController::class, 'getPenyewa']);
    Route::get('/profile', [UserController::class, 'profile']);

    // Routes Pembayaran
    Route::get('/pembayaran', [PembayaranController::class, 'index']);
    Route::post('/pembayaran/konfirmasi/{id}', [PembayaranController::class, 'konfirmasi']);
    Route::post('/pembayaran/upload-bukti/{id}', [PembayaranController::class, 'uploadBukti']);
    Route::post('/pembayaran/generate', [PembayaranController::class, 'generateNextBill']);

    // Routes Komplain
    Route::get('/complaints', [ComplaintController::class, 'index']);
    Route::post('/complaints', [ComplaintController::class, 'store']);
    Route::get('/my-complaints', [ComplaintController::class, 'myComplaints']);
    Route::post('/complaints/update-status/{id}', [ComplaintController::class, 'updateStatus']);

    // Routes Notifikasi
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::post('/notifications/mark-read/{id}', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/broadcast', [NotificationController::class, 'broadcast']);

    // Routes Laporan
    Route::get('/reports/summary', [ReportController::class, 'getSummary']);
    Route::get('/reports/payments', [ReportController::class, 'getPaymentReport']);
    Route::get('/reports/tunggakan', [ReportController::class, 'getTunggakanReport']);
    Route::get('/reports/active-tenants', [ReportController::class, 'getPenyewaAktifReport']);
});