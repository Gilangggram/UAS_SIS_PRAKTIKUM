import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gudangkita_group_a/Component/navigation_bar.dart';
import 'package:gudangkita_group_a/Component/product_card.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String selectedCategory = 'Makanan'; // Default category

  void updateCategory(String category) {
    setState(() {
      selectedCategory = category;
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
                    onTap: () => updateCategory('Makanan'),
                  ),
                ),
                const SizedBox(width: 16), // Space between categories
                Expanded(
                  child: _CategoryCard(
                    title: 'Minuman',
                    context: context,
                    onTap: () => updateCategory('Minuman'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Space between categories and products
            Expanded(
              child: _ProductList(
                  category: selectedCategory), // Use the selected category
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _CategoryCard(
      {required String title,
      required BuildContext context,
      required VoidCallback onTap}) {
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
          return Center(child: Text('No products found'));
        }

        final productDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: productDocs.length,
          itemBuilder: (context, index) {
            final productId = productDocs[index].id; // Get the product ID
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () => _showProductDetailDialog(
                    context, productId), // Show details on tap
                child: ProductCard(
                    productId: productId), // Pass productId to ProductCard
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
    final String selectedCategory = data['category']; // Store current category
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

    // List of categories for dropdown
    final List<String> categories = ['Makanan', 'Minuman'];
    String? currentCategory = selectedCategory; // Current selected category

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
                _buildCategoryDropdown(currentCategory, (newValue) {
                  currentCategory = newValue;
                }, categories),
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
                  'category':
                      currentCategory, // Use selected category from dropdown
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

  Widget _buildCategoryDropdown(String? selectedValue,
      ValueChanged<String?> onChanged, List<String> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
        items: categories.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
