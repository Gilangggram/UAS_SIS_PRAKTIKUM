import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CargoListAdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargo List'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cargo').snapshots(),
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

          return ListView.builder(
            itemCount: cargoDocs.length,
            itemBuilder: (context, index) {
              final cargoData = cargoDocs[index].data() as Map<String, dynamic>;
              final docId = cargoDocs[index].id; // Get the document ID

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CargoCard(
                  courierName: cargoData['courier_name'] ?? 'Unknown',
                  code: cargoData['code'] ?? 'N/A',
                  type: cargoData['type'] ?? 'N/A',
                  onDelete: () {
                    _showDeleteConfirmationDialog(context, docId);
                  },
                ),
              );
            },
          );
        },
      ),
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
}

class CargoCard extends StatelessWidget {
  const CargoCard({
    Key? key,
    required this.courierName,
    required this.code,
    required this.type,
    required this.onDelete,
  }) : super(key: key);

  final String courierName;
  final String code;
  final String type;
  final VoidCallback onDelete; // Add onDelete callback

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space between elements
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courierName.isNotEmpty ? courierName : 'Unknown',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Code: ${code.isNotEmpty ? code : 'N/A'}"),
                  Text("Type: ${type.isNotEmpty ? type : 'N/A'}"),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete, // Call the onDelete function
            ),
          ],
        ),
      ),
    );
  }
}
