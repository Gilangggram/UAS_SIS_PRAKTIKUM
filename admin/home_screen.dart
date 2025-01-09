import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gudangkita_group_a/Component/navigation_bar.dart';
import 'package:gudangkita_group_a/Component/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
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
                  onChanged: _onSearchChanged,
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
              // Removed shopping cart icon
            ],
          ),
        ),
      ),
      body: _ProductList(searchQuery: _searchQuery),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}

class _ProductList extends StatelessWidget {
  final String searchQuery;

  const _ProductList({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('product').snapshots(),
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

        // Filter products based on the search query
        final filteredProducts = productDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name']?.toLowerCase() ?? '';
          final brand = data['brand']?.toLowerCase() ?? '';
          final code = data['code']?.toLowerCase() ?? '';
          return name.contains(searchQuery.toLowerCase()) ||
              brand.contains(searchQuery.toLowerCase()) ||
              code.contains(searchQuery.toLowerCase());
        }).toList();

        if (filteredProducts.isEmpty) {
          return Center(child: Text('No products match your search'));
        }

        return ListView.builder(
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final productId = filteredProducts[index].id;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () => _showProductDetailDialog(context, productId),
                child: ProductCard(productId: productId),
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
                  _buildDetailRow('Name', data['name']),
                  _buildDetailRow('Brand', data['brand']),
                  _buildDetailRow('Category', data['category']),
                  _buildDetailRow('Code', data['code']),
                  _buildDetailRow('Quantity', data['quantity'].toString()),
                  _buildDetailRow('Date Added', data['date_add']),
                  _buildDetailRow('Expiration Date', data['exp']),
                  if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(data['imageUrl'],
                            fit: BoxFit.cover, height: 150),
                      ),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the current dialog
                  _showEditProductDialog(context, productId, data);
                },
              ),
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
    }
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text('$label: ${value ?? 'N/A'}', style: TextStyle(fontSize: 16)),
    );
  }

  void _showEditProductDialog(
      BuildContext context, String productId, Map<String, dynamic> data) {
    final TextEditingController nameController =
        TextEditingController(text: data['name']);
    final TextEditingController brandController =
        TextEditingController(text: data['brand']);
    final TextEditingController categoryController =
        TextEditingController(text: data['category']);
    final TextEditingController codeController =
        TextEditingController(text: data['code']);
    final TextEditingController quantityController =
        TextEditingController(text: data['quantity'].toString());
    final TextEditingController dateAddController =
        TextEditingController(text: data['date_add']);
    final TextEditingController expController =
        TextEditingController(text: data['exp']);
    final TextEditingController imageUrlController =
        TextEditingController(text: data['imageUrl']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(
              child: Text('Edit Product',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildTextField('Name', nameController),
                _buildTextField('Brand', brandController),
                _buildTextField('Category', categoryController),
                _buildTextField('Code', codeController),
                _buildTextField('Quantity', quantityController, isNumber: true),
                _buildTextField('Date Added', dateAddController),
                _buildTextField('Expiration Date', expController),
                _buildTextField('Image URL', imageUrlController),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('product')
                    .doc(productId)
                    .update({
                  'name': nameController.text,
                  'brand': brandController.text,
                  'category': categoryController.text,
                  'code': codeController.text,
                  'quantity': int.tryParse(quantityController.text) ?? 0,
                  'date_add': dateAddController.text,
                  'exp': expController.text,
                  'imageUrl': imageUrlController.text,
                });
                Navigator.of(context).pop(); // Close edit dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product updated successfully')),
                );
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      ),
    );
  }
}
