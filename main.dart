import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_inventory/pages/login_page.dart';
import 'package:uas_inventory/User/home_screen_user.dart';
import 'package:uas_inventory/Admin/home_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:uas_inventory/User/cart_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => Cart(), // Inisialisasi Cart
      child: MyApp(),
    ),
  );
}

// Splash Screen untuk menampilkan gambar splashscreen
class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 4)); // Menunggu selama 4 detik
    Navigator.pushReplacementNamed(
        context, 'login_page'); // Arahkan ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
            'assets/splashscreen.jpeg'), // Menampilkan gambar splash screen
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'splash_screen', // Arahkan ke SplashScreen
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      routes: {
        'splash_screen': (context) => SplashScreen(), // Rute untuk SplashScreen
        'login_page': (context) => LoginPage(),
        'home_screen_user': (context) => const HomeScreenUser(),
        'home_screen': (context) => const HomeScreen(),
      },
    );
  }
}