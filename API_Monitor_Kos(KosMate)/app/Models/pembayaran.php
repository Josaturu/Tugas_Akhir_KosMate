<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class pembayaran extends Model
{
    protected $fillable = [
        'penyewaans_id', 
        'periode', 
        'jumlah', 
        'tanggal_bayar', 
        'bukti_pembayaran', 
        'status', 
        'metode', 
        'keterangan'
    ];

    public function penyewaan()
    {
        return $this->belongsTo(penyewaan::class, 'penyewaans_id');
    }
}
