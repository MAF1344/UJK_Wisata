import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FavoriteScreen extends StatefulWidget {
  final VoidCallback onFavoriteChanged;

  const FavoriteScreen({Key? key, required this.onFavoriteChanged})
    : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<dynamic> _favoriteWisata = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/wisatas'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> allWisata = json.decode(response.body);
      setState(() {
        _favoriteWisata =
            allWisata.where((item) => item['favorit'] == 'iya').toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Gagal mengambil data wisata');
    }
  }

  Future<void> _removeFavorite(int id) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/api/wisatas/$id/favorit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'favorit': 'tidak'}),
    );

    if (response.statusCode == 200) {
      // Refresh data favorit lokal
      await _fetchFavorites();

      // Beritahu halaman utama untuk refresh data
      widget.onFavoriteChanged();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus dari favorit')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _favoriteWisata.isEmpty
              ? const Center(child: Text('Belum ada wisata favorit.'))
              : ListView.builder(
                itemCount: _favoriteWisata.length,
                itemBuilder: (context, index) {
                  final wisata = _favoriteWisata[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.place, color: Colors.blue),
                      title: Text(wisata['nama_wisata'] ?? wisata['nama']),
                      subtitle: Text('Kota: ${wisata['kota']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeFavorite(wisata['id']),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
