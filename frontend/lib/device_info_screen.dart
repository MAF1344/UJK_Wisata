import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DeviceInfoScreen extends StatefulWidget {
  @override
  _DeviceInfoScreenState createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  String deviceModel = '';
  String osVersion = '';
  String deviceID = '';
  String _connectionStatus = 'Memeriksa koneksi...';
  AccelerometerEvent? _accelerometerEvent;

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
    _updateConnectionStatus();

    // Listen to accelerometer data
    accelerometerEvents.listen((event) {
      setState(() {
        _accelerometerEvent = event;
      });
    });
  }

  Future<void> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        setState(() {
          deviceModel = androidInfo.model;
          osVersion = 'Android ${androidInfo.version.release}';
          deviceID = androidInfo.id;
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        setState(() {
          deviceModel = iosInfo.name;
          osVersion = 'iOS ${iosInfo.systemVersion}';
          deviceID = iosInfo.identifierForVendor ?? '-';
        });
      }
    } catch (e) {
      debugPrint('Gagal mendapatkan info perangkat: $e');
    }
  }

  Future<void> _updateConnectionStatus() async {
    try {
      final result = await Connectivity().checkConnectivity();

      String status;
      if (result == ConnectivityResult.mobile) {
        status = 'Jaringan Seluler';
      } else if (result == ConnectivityResult.wifi) {
        status = 'Wi-Fi';
      } else if (result == ConnectivityResult.ethernet) {
        status = 'Ethernet';
      } else if (result == ConnectivityResult.none) {
        status = 'Tidak ada koneksi';
      } else {
        status = 'Tidak diketahui';
      }

      setState(() {
        _connectionStatus = status;
      });
    } catch (e) {
      debugPrint('Gagal cek koneksi: $e');
      setState(() {
        _connectionStatus = 'Gagal mendeteksi koneksi';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _infoTile('Model Perangkat', deviceModel),
            _infoTile('Versi OS', osVersion),
            _infoTile('Device ID', deviceID),
            _infoTile('Status Koneksi', _connectionStatus),
            SizedBox(height: 20),
            Text(
              'Akselerometer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'x: ${_accelerometerEvent?.x.toStringAsFixed(2) ?? "-"}\n'
              'y: ${_accelerometerEvent?.y.toStringAsFixed(2) ?? "-"}\n'
              'z: ${_accelerometerEvent?.z.toStringAsFixed(2) ?? "-"}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
