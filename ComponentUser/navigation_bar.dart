import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uas_inventory/Admin/cargo_screen.dart';
import 'package:uas_inventory/Admin/category.dart';
import 'package:uas_inventory/Admin/home_screen.dart';
import 'package:uas_inventory/Admin/profile_screen.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, size: 40),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.grid_view, size: 30),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CategoryScreen()),
              );
            },
          ),
          GestureDetector(
            onTap: () {
              _showOptionsDialog(context);
            },
            child: Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange,
              ),
              child: const Icon(Icons.add, size: 40, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.local_shipping, size: 40),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CargoScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, size: 40),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Opsi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.local_shipping),
                title: const Text('Cargo'),
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog
                  _showAddCargoDialog(context); // Show cargo form
                },
              ),
              ListTile(
                leading: const Icon(Icons.production_quantity_limits),
                title: const Text('Produk'),
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog
                  _showAddProductDialog(context); // Show product form
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddCargoDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    final TextEditingController courierController = TextEditingController();
    String? selectedType; // Variable to hold selected type

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Cargo'),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Code'),
                ),
                TextField(
                  controller: courierController,
                  decoration: const InputDecoration(labelText: 'Courier'),
                ),
                DropdownButtonFormField<String>(
                  hint: const Text('Select Type'),
                  value: selectedType,
                  onChanged: (String? newValue) {
                    selectedType = newValue;
                  },
                  items: <String>['Pick-Up', 'Box', 'Container']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedType == null ||
                    codeController.text.isEmpty ||
                    courierController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                } else {
                  _addCargo(courierController.text, codeController.text,
                      selectedType!);
                  Navigator.of(context).pop(); // Close dialog
                }
              },
              child: const Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final TextEditingController brandController = TextEditingController();
    final TextEditingController codeController = TextEditingController();
    final TextEditingController expController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    String? selectedCategory; // Variable to hold selected category

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Produk'),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: brandController,
                    decoration: const InputDecoration(labelText: 'Brand'),
                  ),
                  DropdownButtonFormField<String>(
                    hint: const Text('Select Category'),
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      selectedCategory = newValue;
                    },
                    items: <String>['Makanan', 'Minuman']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Code'),
                  ),
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Tambah',
                      hintText: DateTime.now()
                          .toString()
                          .split(' ')[0], // Current date
                    ),
                  ),
                  TextField(
                    controller: expController,
                    decoration:
                        const InputDecoration(labelText: 'Tanggal Expired'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        expController.text =
                            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}"; // Format date
                      }
                    },
                  ),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Produk'),
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedCategory == null ||
                    brandController.text.isEmpty ||
                    codeController.text.isEmpty ||
                    expController.text.isEmpty ||
                    imageUrlController.text.isEmpty ||
                    nameController.text.isEmpty ||
                    quantityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                } else {
                  _addProduct(
                    brandController.text,
                    selectedCategory!,
                    codeController.text,
                    DateTime.now()
                        .toString()
                        .split(' ')[0], // Use current date as date_add
                    expController.text,
                    imageUrlController.text,
                    nameController.text,
                    int.tryParse(quantityController.text) ?? 0,
                  );
                  Navigator.of(context).pop(); // Close dialog
                }
              },
              child: const Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addCargo(String courier, String code, String type) async {
    await FirebaseFirestore.instance.collection('cargo').add({
      'courier': courier,
      'code': code,
      'type': type,
    });
  }

  Future<void> _addProduct(
    String brand,
    String category,
    String code,
    String dateAdd,
    String exp,
    String imageUrl,
    String name,
    int quantity,
  ) async {
    await FirebaseFirestore.instance.collection('product').add({
      'brand': brand,
      'category': category,
      'code': code,
      'date_add': dateAdd,
      'exp': exp,
      'imageUrl': imageUrl,
      'name': name,
      'quantity': quantity,
    });
  }
}
