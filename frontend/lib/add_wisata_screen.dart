import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddWisataScreen extends StatefulWidget {
  @override
  _AddWisataScreenState createState() => _AddWisataScreenState();
}

class _AddWisataScreenState extends State<AddWisataScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();

  Future<void> _submitWisata() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/wisatas'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nama_wisata': _namaController.text,
        'kota': _kotaController.text,
        'kategori': _kategoriController.text,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, true); // kembali dan beri sinyal refresh
    } else {
      final body = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal tambah wisata: ${body['message'] ?? 'Unknown error'}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Wisata')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama Wisata'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _kotaController,
                decoration: InputDecoration(labelText: 'Kota'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Kota tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _kategoriController,
                decoration: InputDecoration(labelText: 'Kategori'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Kategori tidak boleh kosong' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Simpan'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitWisata();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
