<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
class penyewaan extends Model
{
    protected $fillable = ['users_id', 'kamars_id', 'tanggal_masuk', 'tanggal_keluar', 'lama_sewa', 'status_sewa'];
    protected $appends = ['tanggal_selesai'];

    public function getTanggalSelesaiAttribute()
    {
        return date('Y-m-d', strtotime($this->tanggal_masuk . " + $this->lama_sewa month"));
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'users_id');
    }

    public function kamar()
    {
        return $this->belongsTo(kamar::class, 'kamars_id');
    }

    public function pembayarans()
    {
        return $this->hasMany(pembayaran::class, 'penyewaans_id');
    }
}
