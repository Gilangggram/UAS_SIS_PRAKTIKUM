import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uas_inventory/ComponentUser/navigation_bar_user.dart';
import 'package:uas_inventory/ComponentUser/product_card_user.dart';
import 'package:uas_inventory/User/cart_screen.dart'; // Import CartScreen
import 'package:provider/provider.dart';
import 'cart_model.dart'; // Import model cart

class CategoryScreenUser extends StatefulWidget {
  const CategoryScreenUser({Key? key}) : super(key: key);

  @override
  _CategoryScreenUserState createState() => _CategoryScreenUserState();
}

class _CategoryScreenUserState extends State<CategoryScreenUser> {
  String _selectedCategory = 'Makanan'; // Default category

  void _updateCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _CategoryCard(
                    title: 'Makanan',
                    context: context,
                    onTap: () => _updateCategory('Makanan'),
                  ),
                ),
                const SizedBox(width: 16), // Space between categories
                Expanded(
                  child: _CategoryCard(
                    title: 'Minuman',
                    context: context,
                    onTap: () => _updateCategory('Minuman'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Space between categories and products
            Expanded(
              child: _ProductList(
                  category:
                      _selectedCategory), // Update products based on selected category
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationUser(),
    );
  }

  Widget _CategoryCard({
    required String title,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.orange[400],
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.orange[300]!, Colors.orange[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final String category;

  const _ProductList({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('product')
          .where('category', isEqualTo: category) // Filter by category
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No products found in this category'));
        }

        final productDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: productDocs.length,
          itemBuilder: (context, index) {
            final productId = productDocs[index].id; // Get the product ID
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () => _showProductDetailDialog(context, productId),
                child: ProductCardUser(productId: productId), // Pass productId
              ),
            );
          },
        );
      },
    );
  }

  void _showProductDetailDialog(BuildContext context, String productId) async {
    final productData = await FirebaseFirestore.instance
        .collection('product')
        .doc(productId)
        .get();

    if (productData.exists) {
      final data = productData.data() as Map<String, dynamic>;
      final cart =
          Provider.of<Cart>(context, listen: false); // Ambil instance cart
      final TextEditingController quantityController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Center(
              child: Text(data['name'] ?? 'Product Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Name: ${data['name'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Brand: ${data['brand'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Category: ${data['category'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Code: ${data['code'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Available Quantity: ${data['quantity'] ?? 0}',
                        style: TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Date Added: ${data['date_add'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Expiration Date: ${data['exp'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16)),
                  ),
                  if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(data['imageUrl'],
                            fit: BoxFit.cover, height: 150),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Input untuk quantity
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Ikon Add to Cart
                  ElevatedButton(
                    onPressed: () {
                      // Validasi quantity sebelum menambahkan
                      int quantity = int.tryParse(quantityController.text) ?? 0;

                      if (quantity <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Please enter a valid quantity.')),
                        );
                        return;
                      }

                      if (quantity > (data['quantity'] ?? 0)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Requested quantity exceeds available stock.')),
                        );
                        return;
                      }

                      // Menambahkan produk ke keranjang
                      cart.addItem(CartItem(
                        id: productId,
                        name: data['name'] ?? 'N/A',
                        brand: data['brand'] ?? 'N/A',
                        category: data['category'] ?? 'N/A',
                        code: data['code'] ?? 'N/A',
                        dateAdd: data['date_add'] ?? 'N/A',
                        exp: data['exp'] ?? 'N/A',
                        imageUrl: data['imageUrl'] ?? '',
                        quantity: quantity, // Ambil quantity dari input
                      ));
                      Navigator.of(context)
                          .pop(); // Tutup dialog setelah menambahkan
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${data['name']} ditambahkan ke keranjang')),
                      );
                    },
                    child: const Text('Add to Cart'),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product not found.')),
      );
    }
  }
}
