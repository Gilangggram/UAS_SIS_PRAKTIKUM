import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uas_inventory/ComponentUser/navigation_bar_user.dart';
import 'package:uas_inventory/ComponentUser/cargo_card_user.dart'; // Ensure you have created CargoCard

class CargoScreenUser extends StatefulWidget {
  const CargoScreenUser({Key? key}) : super(key: key);

  @override
  _CargoScreenUserState createState() => _CargoScreenUserState();
}

class _CargoScreenUserState extends State<CargoScreenUser> {
  String _selectedType = 'Pick-Up'; // Default cargo type

  void _updateType(String type) {
    setState(() {
      _selectedType = type;
    });
  }

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
              scrollDirection: Axis.horizontal, // Set scrolling direction
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _CargoCard(
                      title: 'Pick-Up',
                      context: context,
                      onTap: () => _updateType('Pick-Up')),
                  const SizedBox(width: 16), // Space between categories
                  _CargoCard(
                      title: 'Box',
                      context: context,
                      onTap: () => _updateType('Box')),
                  const SizedBox(width: 16), // Space between categories
                  _CargoCard(
                      title: 'Container',
                      context: context,
                      onTap: () => _updateType('Container')),
                ],
              ),
            ),
            const SizedBox(height: 20), // Space between categories and products
            Expanded(
              child: _CargoList(type: _selectedType), // Use the selected type
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationUser(),
    );
  }

  Widget _CargoCard(
      {required String title,
      required BuildContext context,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
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

class _CargoList extends StatelessWidget {
  final String type;

  const _CargoList({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cargo')
          .where('type', isEqualTo: type) // Filter by type
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No cargo found for this type'));
        }

        final cargoDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: cargoDocs.length,
          itemBuilder: (context, index) {
            final cargoData = cargoDocs[index].data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CargoCardUser(
                courier: cargoData['courier'] ?? 'Unknown',
                code: cargoData['code'] ?? 'N/A',
                type: cargoData['type'] ?? 'N/A',
              ),
            );
          },
        );
      },
    );
  }
}
