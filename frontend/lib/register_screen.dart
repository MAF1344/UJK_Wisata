import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMsg = '';

  Future<void> _register() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context); // kembali ke login
    } else {
      final error = jsonDecode(response.body);
      setState(() {
        errorMsg = error['errors']?.toString() ?? 'Gagal register';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (errorMsg.isNotEmpty)
              Text(errorMsg, style: TextStyle(color: Colors.red)),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(onPressed: _register, child: Text('Daftar')),
          ],
        ),
      ),
    );
  }
}
