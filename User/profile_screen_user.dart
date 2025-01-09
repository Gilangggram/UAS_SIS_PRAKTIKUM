import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uas_inventory/ComponentUser/navigation_bar_user.dart'; // Pastikan Anda mengimpor BottomNavigation
import 'package:uas_inventory/User/profile_detail_screen_user.dart'; // Pastikan Anda mengimpor BottomNavigation
import 'history.dart'; // Import HistoryScreenUser

class ProfileScreenUser extends StatelessWidget {
  const ProfileScreenUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Profile Image
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange, // Mengubah warna menjadi oranye
                ),
              ),
            ),
          ),

          // Menu Items
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailProfileScreenUser(userId: user.uid),
                        ),
                      );
                    } else {
                      // Tampilkan pesan atau navigasi ke halaman login
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User not logged in.')),
                      );
                    }
                  },
                  child: _buildMenuItem(
                    icon: Icons.person,
                    title: 'Profile',
                  ),
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'History',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HistoryScreenUser()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          const BottomNavigationUser(), // Menambahkan BottomNavigation
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
              context, 'login_page'); // Ganti dengan rute yang sesuai
        },
        child: const Icon(Icons.logout), // Ikon logout
        backgroundColor: Colors.red, // Warna tombol
        foregroundColor: Colors.white, // Mengubah warna ikon menjadi putih
      ),
    );
  }

  Widget _buildMenuItem(
      {required IconData icon, required String title, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
