import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini
import 'package:flutter/material.dart';
import 'package:gudangkita_group_a/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance; // Tambahkan ini
  final _formKey = GlobalKey<FormState>();
  late String email = '';
  late String password = '';
  late String username = '';

  // Warna tema
  final Color primaryColor = const Color(0xFFF4A261);
  final Color accentColor = const Color(0xFFE9C46A);
  final Color backgroundColor = const Color(0xFFFFF1E6);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Row(
        children: [
          // Bagian kiri untuk login
          Expanded(
            flex: 1,
            child: Container(
              color: primaryColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    'Login ke akun admin untuk mengakses\ndashboard dan alat admin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.03,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.1,
                        vertical: 10.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: size.width * 0.04,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bagian kanan untuk register
          Expanded(
            flex: 2,
            child: Container(
              color: backgroundColor,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/gudang.png',
                          height: size.height * 0.2,
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Field Username
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Username',
                            prefixIcon: Icon(Icons.person, color: Colors.black87),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          onChanged: (value) {
                            username = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),

                        // Field Email
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email, color: Colors.black87),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
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
                        const SizedBox(height: 16.0),

                        // Field Password
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock, color: Colors.black87),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
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
                        const SizedBox(height: 24.0),

                        // Tombol Register
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                // Mendaftar pengguna baru
                                final newUser = await _auth.createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );

                                // Jika pendaftaran berhasil, simpan data pengguna ke Firestore
                                if (newUser.user != null) {
                                  await _firestore.collection('users').doc(newUser.user!.uid).set({
                                    'username': username,
                                    'email': email,
                                    'password': password, // Pastikan untuk tidak menyimpan password
                                  });
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginPage()),
                                  );
                                }
                              } catch (e) {
                                print(e);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.1,
                              vertical: 10.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}