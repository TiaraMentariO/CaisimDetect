import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugasakhirsawihijau/views/dashboard.dart'; // menyediakan widget UI material desain

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MySplashScreen(),
    );
  }
}

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();

    _checkFirstSeen();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isNavigated) {
        _isNavigated = true;
        _navigateToHomeDelayed();
      }
    });
  }

  Future<void> _checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      _navigateToHome();
    } else {
      await prefs.setBool('seen', true);
    }
  }

  void _navigateToHome() {
    if (!_isNavigated) {
      _isNavigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardView()),
      );
    }
  }

  void _navigateToHomeDelayed() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: AnimatedContainer(
                duration: const Duration(seconds: 2),
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.8,
                curve: Curves.easeInOut,
                child: Image.asset(
                  'assets/images/sawiHijau_desain2.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
