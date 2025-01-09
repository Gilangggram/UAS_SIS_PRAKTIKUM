import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gudangkita_group_a/Component/navigation_bar.dart';
import 'package:gudangkita_group_a/Component/cargo_card.dart'; // Ensure you have CargoCard defined

class CargoScreen extends StatefulWidget {
  const CargoScreen({Key? key}) : super(key: key);

  @override
  _CargoScreenState createState() => _CargoScreenState();
}

class _CargoScreenState extends State<CargoScreen> {
  String selectedType = 'Pick-Up'; // Default type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Cargo',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20), // Top spacing
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Horizontal scrolling
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _CargoCard(title: 'Pick-Up', context: context),
                  const SizedBox(width: 16), // Spacing between categories
                  _CargoCard(title: 'Box', context: context),
                  const SizedBox(width: 16), // Spacing between categories
                  _CargoCard(title: 'Container', context: context),
                ],
              ),
            ),
            const SizedBox(
                height: 20), // Spacing between categories and products
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('cargo').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No cargo found'));
                  }

                  final cargoDocs = snapshot.data!.docs;

                  // Filter cargo based on the selected type
                  final filteredCargoDocs = cargoDocs.where((doc) {
                    final cargoData = doc.data() as Map<String, dynamic>;
                    return cargoData['type'] == selectedType;
                  }).toList();

                  if (filteredCargoDocs.isEmpty) {
                    return Center(
                        child: Text('No cargo items for $selectedType'));
                  }

                  return ListView.builder(
                    itemCount: filteredCargoDocs.length,
                    itemBuilder: (context, index) {
                      final cargoData = filteredCargoDocs[index].data()
                          as Map<String, dynamic>;
                      final docId =
                          filteredCargoDocs[index].id; // Get the document ID

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            // Show detail dialog
                            _showDetailDialog(context, docId, cargoData);
                          },
                          child: CargoCard(
                            courierName: cargoData['courier'] ?? 'Unknown',
                            code: cargoData['code'] ?? 'N/A',
                            type: cargoData['type'] ?? 'N/A',
                            onDelete: () {
                              _showDeleteConfirmationDialog(context, docId);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  void _showDetailDialog(
      BuildContext context, String docId, Map<String, dynamic> cargoData) {
    final TextEditingController courierController =
        TextEditingController(text: cargoData['courier']);
    final TextEditingController codeController =
        TextEditingController(text: cargoData['code']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cargo Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: courierController,
                  decoration: const InputDecoration(labelText: 'Courier'),
                ),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Code'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Pick-Up', 'Box', 'Container'].map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value; // Update selected type
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save updated details to Firestore
                FirebaseFirestore.instance
                    .collection('cargo')
                    .doc(docId)
                    .update({
                  'courier': courierController.text,
                  'code': codeController.text,
                  'type': selectedType,
                });
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cargo updated')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this cargo item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('cargo')
                    .doc(docId)
                    .delete();
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cargo deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _CargoCard({required String title, required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = title; // Update selected type when card is tapped
        });
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.orange[400],
        child: Container(
          width: 160,
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
