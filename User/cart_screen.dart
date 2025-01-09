import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart'; // Mengimpor model keranjang

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<String> cargoCodes = []; // Daftar untuk menyimpan kode cargo
  String? selectedCode; // Kode cargo yang dipilih

  // Kontroler untuk kolom formulir
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController streetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCargoCodes(); // Mengambil kode cargo saat layar diinisialisasi
  }

  // Fungsi untuk mengambil kode cargo dari Firestore
  Future<void> _fetchCargoCodes() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('cargo').get();
    final List<String> codes =
        snapshot.docs.map((doc) => doc['code'].toString()).toList();

    setState(() {
      cargoCodes = codes; // Memperbarui state dengan kode cargo yang diambil
    });
  }

  // Fungsi untuk memproses pengiriman
  Future<void> _processDelivery(Cart cart) async {
    // Menyiapkan data pengiriman dari item keranjang
    final deliveryData = cart.items.map((item) {
      return {
        'name': item.name,
        'code': item.code,
        'quantity': item.quantity,
        'brand': item.brand,
        'category': item.category,
        'dateAdded': item.dateAdd,
        'expirationDate': item.exp,
      };
    }).toList();

    // Menyertakan data formulir dan kode yang dipilih
    final deliveryInfo = {
      'items': deliveryData,
      'address': addressController.text,
      'city': cityController.text,
      'name': nameController.text,
      'postalCode': postalCodeController.text,
      'street': streetController.text,
      'selectedCode': selectedCode,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      // Menambahkan informasi pengiriman ke Firestore
      await FirebaseFirestore.instance.collection('delivery').add(deliveryInfo);
      cart.clearCart(); // Mengosongkan keranjang setelah memproses

      // Menampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proses pengiriman selesai!')),
      );
    } catch (e) {
      // Menampilkan pesan kesalahan jika pemrosesan gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memproses pengiriman: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart =
        Provider.of<Cart>(context); // Mendapatkan keranjang dari provider

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Keranjang Belanja',
          style: TextStyle(color: Colors.grey[700]),
        ),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Text(
                'Keranjang Anda kosong',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(item.name ?? 'N/A'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Brand: ${item.brand ?? 'N/A'}'),
                                Text('Code: ${item.code ?? 'N/A'}'),
                                Text('Quantity: ${item.quantity}'),
                              ],
                            ),
                            leading: (item.imageUrl != null &&
                                    item.imageUrl!.isNotEmpty)
                                ? Image.network(
                                    item.imageUrl!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    'https://via.placeholder.com/50',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmationDialog(context, cart,
                                    item); // Menampilkan dialog konfirmasi penghapusan
                              },
                            ),
                            onTap: () {
                              _showProductDetailDialog(context,
                                  item); // Menampilkan dialog detail produk
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showProcessDialog(
                      context, cart), // Menampilkan dialog proses
                  child: Text('Proses'),
                ),
              ],
            ),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi penghapusan
  void _showDeleteConfirmationDialog(
      BuildContext context, Cart cart, CartItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Item'),
          content: Text(
              'Apakah Anda yakin ingin menghapus item ini dari keranjang?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                cart.removeItem(item.id); // Menghapus item dari keranjang
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog detail produk
  void _showProductDetailDialog(BuildContext context, CartItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.name ?? 'Detail Produk'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Brand: ${item.brand ?? 'N/A'}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Category: ${item.category ?? 'N/A'}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Code: ${item.code ?? 'N/A'}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Quantity: ${item.quantity}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Date Added: ${item.dateAdd ?? 'N/A'}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Expiration Date: ${item.exp ?? 'N/A'}'),
                ),
                if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      height: 150, // Menampilkan gambar produk
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog proses pengiriman
  void _showProcessDialog(BuildContext context, Cart cart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Proses Pengiriman'),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Code',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    value: selectedCode,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCode =
                            newValue; // Memperbarui kode yang dipilih
                      });
                    },
                    items: cargoCodes.map((code) {
                      return DropdownMenuItem(
                        value: code,
                        child: Text(code),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: postalCodeController,
                    decoration: InputDecoration(
                      labelText: 'Postal Code',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: streetController,
                    decoration: InputDecoration(
                      labelText: 'Street',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Data Produk:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Column(
                    children: cart.items.map((item) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nama: ${item.name ?? 'N/A'}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Code: ${item.code ?? 'N/A'}'),
                              SizedBox(height: 4),
                              Text('Quantity: ${item.quantity}'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
            TextButton(
              child: Text('Kirim'),
              onPressed: () {
                _processDelivery(cart); // Memproses pengiriman
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
          ],
        );
      },
    );
  }
}
