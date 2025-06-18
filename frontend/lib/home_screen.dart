import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/add_wisata_screen.dart';
import 'package:frontend/device_info_screen.dart';
import 'package:frontend/favorite_screen.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

Future<List<Map<String, dynamic>>> fetchWisata() async {
  final box = Hive.box('wisataBox');

  try {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/wisatas'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final list = data.map((item) => item as Map<String, dynamic>).toList();

      // Simpan ke lokal
      await box.put('wisataList', list);
      return list;
    } else {
      throw Exception('Gagal mengambil data wisata');
    }
  } catch (e) {
    // Jika error (misal karena offline), ambil dari cache
    final cachedList = box.get('wisataList', defaultValue: []);
    return List<Map<String, dynamic>>.from(cachedList);
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;
  bool _isConnected = true; // default diasumsikan terhubung
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      _snackBarController;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen(_updateConnectionStatus);
    _checkInitialConnection(); // cek status awal
    _futureWisata = fetchWisata();
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final isNowConnected = result != ConnectivityResult.none;

    if (!isNowConnected && _isConnected) {
      // koneksi baru saja terputus
      _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak ada koneksi internet'),
          duration: Duration(days: 1), // biar tidak hilang
          backgroundColor: Colors.red,
        ),
      );
    } else if (isNowConnected && !_isConnected) {
      // koneksi baru saja tersambung kembali
      _snackBarController?.close(); // hilangkan snackbar
    }

    _isConnected = isNowConnected;
  }

  @override
  int _selectedIndex = 0;
  late Future<List<Map<String, dynamic>>> _futureWisata;

  String? _selectedKota;
  String? _selectedKategori;

  @override
  void _refreshWisata() {
    setState(() {
      _futureWisata = fetchWisata();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Refresh data wisata jika kembali ke tab wisata
    if (index == 0) {
      _refreshWisata();
    }
  }

  Future<void> _toggleFavorit(
    BuildContext context,
    Map<String, dynamic> wisata,
  ) async {
    final newStatus = wisata['favorit'] == 'iya' ? 'tidak' : 'iya';

    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/api/wisatas/${wisata['id']}/favorit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'favorit': newStatus}),
    );

    if (response.statusCode == 200) {
      setState(() {
        wisata['favorit'] = newStatus;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status favorit')),
      );
    }
  }

  Widget _buildWisataList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureWisata,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final wisataList = snapshot.data ?? [];

        if (wisataList.isEmpty) {
          return const Center(child: Text('Tidak ada data wisata.'));
        }

        // Apply filter
        final filteredList = wisataList.where((wisata) {
          final cocokKota =
              _selectedKota == null || wisata['kota'] == _selectedKota;
          final cocokKategori = _selectedKategori == null ||
              wisata['kategori'] == _selectedKategori;
          return cocokKota && cocokKategori;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedKota,
                      hint: const Text('Filter Kota'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Semua Kota'),
                        ),
                        ...wisataList
                            .map((w) => w['kota'].toString())
                            .toSet()
                            .map((kota) {
                          return DropdownMenuItem<String>(
                            value: kota,
                            child: Text(kota),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedKota = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedKategori,
                      hint: const Text('Filter Kategori'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Semua Kategori'),
                        ),
                        ...wisataList
                            .map((w) => w['kategori'].toString())
                            .toSet()
                            .map((kategori) {
                          return DropdownMenuItem<String>(
                            value: kategori,
                            child: Text(kategori),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedKategori = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        _selectedKota = null;
                        _selectedKategori = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final wisata = filteredList[index];
                  return ListTile(
                    title: Text(wisata['nama_wisata']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kota: ${wisata['kota']}'),
                        Text('Kategori: ${wisata['kategori']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        wisata['favorit'] == 'iya'
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: wisata['favorit'] == 'iya' ? Colors.red : null,
                      ),
                      onPressed: () => _toggleFavorit(context, wisata),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildWisataList(),
      FavoriteScreen(onFavoriteChanged: _refreshWisata),
      DeviceInfoScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_getAppBarTitle())),
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddWisataScreen()),
                );
                if (result == true) {
                  _refreshWisata();
                }
              },
              child: const Icon(Icons.add),
              tooltip: 'Tambah Wisata',
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Wisata'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'),
          BottomNavigationBarItem(
            icon: Icon(Icons.device_unknown),
            label: 'Info Perangkat',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Daftar Wisata';
      case 1:
        return 'Daftar Favorit';
      case 2:
        return 'Info Perangkat';
      default:
        return 'Aplikasi';
    }
  }
}
