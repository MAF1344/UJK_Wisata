<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Wisata extends Model
{
    protected $fillable = ['nama_wisata', 'kota', 'kategori', 'favorit'];
}
