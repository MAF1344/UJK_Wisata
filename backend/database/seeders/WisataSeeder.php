<?php

namespace Database\Seeders;

use App\Models\Wisata;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class WisataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Wisata::create([
            'nama_wisata' => 'Raja Ampat',
            'kota' => 'Papua',
            'kategori' => 'Pantai',
            'favorit' => 'iya',
        ]);
        
        Wisata::create([
            'nama_wisata' => 'Curug Cilember',
            'kota' => 'Bogor',
            'kategori' => 'Curug',
            'favorit' => 'tidak',
        ]);

        Wisata::create([
            'nama_wisata' => 'Tanah Lot',
            'kota' => 'Bali',
            'kategori' => 'Bangunan Bersejarah',
            'favorit' => 'iya',
        ]);

        Wisata::create([
            'nama_wisata' => 'Ancol',
            'kota' => 'Jakarta',
            'kategori' => 'Pantai',
            'favorit' => 'tidak',
        ]);
    }
}
