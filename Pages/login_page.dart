import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gudangkita_group_a/Admin/home_screen.dart'; // Pastikan Anda mengimpor HomeScreen
import 'package:gudangkita_group_a/User/home_screen_user.dart'; // Pastikan Anda mengimpor HomeScreenUser
import 'package:gudangkita_group_a/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late String email;
  late String password;

  // Warna tema
  final Color primaryColor = const Color(0xFFF4A261);
  final Color backgroundColor = const Color(0xFFFFF1E6);

  // Fungsi untuk menyimpan status login
  Future<void> _saveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
  }

  // Fungsi untuk menghapus status login
  Future<void> _clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/gudang.png',
                  height: 150,
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Selamat Datang di GudangKita\nLogin Untuk Mengelola Gudang',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 40.0),
                SizedBox(
                  width: 800,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      email = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 800,
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30.0),
                SizedBox(
                  width: 800,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          // Coba untuk sign in dengan email dan password
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          // Jika berhasil, simpan status login
                          await _saveSession();

                          // Arahkan pengguna ke HomeScreen atau HomeScreenUser
                          if (userCredential.user!.email == 'admin@gmail.com') {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                              (Route<dynamic> route) => false,
                            );
                          } else {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreenUser()),
                              (Route<dynamic> route) => false,
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          // Tangani kesalahan jika login gagal
                          String message;
                          if (e.code == 'user-not-found') {
                            message =
                                'Tidak ada pengguna yang ditemukan dengan email tersebut.';
                          } else if (e.code == 'wrong-password') {
                            message = 'Password yang dimasukkan salah.';
                          } else {
                            message = 'Terjadi kesalahan. Silakan coba lagi.';
                          }

                          // Tampilkan pesan kesalahan
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      }
                    },
                    child: Text(
                      'LOGIN',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Don’t have an account? Register here',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
