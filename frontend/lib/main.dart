import 'package:flutter/material.dart';
import 'package:frontend/home_screen.dart';
import 'package:frontend/login_screen.dart';
import 'package:frontend/register_screen.dart';
import 'package:frontend/spash_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('wisataBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Info Wisata',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login':
            (context) => LoginScreen(
              onLoginSuccess: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
