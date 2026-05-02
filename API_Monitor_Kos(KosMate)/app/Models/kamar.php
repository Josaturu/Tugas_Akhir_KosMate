<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
class kamar extends Model
{
    protected $fillable = ['nomor_kamar', 'tipe_kamar', 'harga_sewa', 'status', 'keterangan'];

    public function penyewaans()
    {
        return $this->hasMany(penyewaan::class, 'kamars_id');
    }
}
