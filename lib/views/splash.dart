import 'package:flutter/material.dart';
import 'dashboard.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key})
      : super(key: key); // membedakan widget satu sama lain

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // membuat tampilan splashscreen
  @override
  void initState() {
    super.initState();
    _navigatetodashboard();
  }

  _navigatetodashboard() async {
    // navigasi ke halaman dashboard
    await Future.delayed(Duration(milliseconds: 2000),
        () {}); // menunda navigasi selama waktu yg ditentukan
    Navigator.pushReplacement(
        // menavigasi ke halaman baru
        context,
        MaterialPageRoute(
            builder: (context) => DashboardView())); // membuat route baru
  }

  @override
  Widget build(BuildContext context) {
    // UI membangun splashscreen
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              color: Colors.blue,
            ),
            Container(
              child: Text(
                'Splash Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
