import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uas_inventory/ComponentUser/navigation_bar_user.dart';
import 'package:uas_inventory/ComponentUser/product_card_user.dart';
import 'package:uas_inventory/User/cart_screen.dart'; // Import CartScreen
import 'package:provider/provider.dart';
import 'cart_model.dart'; // Import model cart

class HomeScreenUser extends StatefulWidget {
  const HomeScreenUser({Key? key}) : super(key: key);

  @override
  _HomeScreenUserState createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateSearchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search by name, brand, or code...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    filled: true,
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CartScreen()), // Navigasi ke CartScreen
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(Icons.shopping_cart,
                      size: 30, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _ProductList(searchQuery: _searchQuery), // Pass the search query
      bottomNavigationBar: const BottomNavigationUser(),
    );
  }
}

class _ProductList extends StatelessWidget {
  final String searchQuery;

  const _ProductList({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('product')
          .get(), // Fetch all products
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No products available'));
        }

        final productDocs = snapshot.data!.docs;

        // Filter products based on search query
        final filteredProductDocs = productDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name']?.toLowerCase() ?? '';
          final brand = data['brand']?.toLowerCase() ?? '';
          final code = data['code']?.toLowerCase() ?? '';
          return name.contains(searchQuery) ||
              brand.contains(searchQuery) ||
              code.contains(searchQuery);
        }).toList();

        if (filteredProductDocs.isEmpty) {
          return Center(child: Text('No products match your search'));
        }

        return ListView.builder(
          itemCount: filteredProductDocs.length,
          itemBuilder: (context, index) {
            final productId =
                filteredProductDocs[index].id; // Get the product ID
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
