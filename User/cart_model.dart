import 'package:flutter/material.dart';

// Model CartItem
class CartItem {
  final String id; // ID produk
  final String name; // Nama produk
  final String brand; // Merek produk
  final String category; // Kategori produk
  final String code; // Kode produk
  final String dateAdd; // Tanggal ditambahkan
  final String exp; // Tanggal kedaluwarsa
  final String imageUrl; // URL gambar produk
  final int quantity; // Jumlah produk

  CartItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.code,
    required this.dateAdd,
    required this.exp,
    required this.imageUrl,
    required this.quantity,
  });
}

// Model Cart
class Cart with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners(); // Notifikasi untuk pembaruan UI
  }

  void clearCart() {
    _items.clear();
    notifyListeners(); // Notifikasi untuk pembaruan UI
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id); // Hapus item berdasarkan ID
    notifyListeners(); // Notifikasi untuk pembaruan UI
  }
}
