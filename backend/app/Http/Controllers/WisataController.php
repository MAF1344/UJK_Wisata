<?php

namespace App\Http\Controllers;

use App\Models\Wisata;
use Illuminate\Http\Request;

class WisataController extends Controller
{
    public function index()
    {
        return Wisata::all();
    }

    public function store(Request $request)
    {
        return Wisata::create($request->all());
    }

    public function show(Wisata $wisata)
    {
        return $wisata;
    }

    public function update(Request $request, Wisata $wisata)
    {
        $wisata->update($request->all());
        return $wisata;
    }

    public function destroy(Wisata $wisata)
    {
        $wisata->delete();
        return response()->json(['message' => 'Data Wisata berhasil dihapus']);
    }

    public function updateFavorit(Request $request, $id)
    {
        $request->validate([
            'favorit' => 'required|in:iya,tidak',
        ]);

        $wisata = Wisata::findOrFail($id);
        $wisata->favorit = $request->favorit;
        $wisata->save();

        return response()->json(['message' => 'Status favorit diperbarui']);
    }
}
