import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:uas_inventory/Component/navigation_bar.dart'; // Import BottomNavigation
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistoryScreenAdmin extends StatelessWidget {
  const HistoryScreenAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.white, // Warna AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('delivery').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Tidak ada riwayat pengiriman.'));
            }

            final deliveryItems = snapshot.data!.docs;

            return ListView.builder(
              itemCount: deliveryItems.length,
              itemBuilder: (context, index) {
                var data = deliveryItems[index].data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    _showDeliveryDetails(context, data);
                  },
                  child: _buildHistoryItem(
                    title: 'Pengiriman: ${data['name'] ?? 'N/A'}',
                    date:
                        'Tanggal: ${data['timestamp']?.toDate().toString().split(' ')[0] ?? 'N/A'}',
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar:
          const BottomNavigation(), // Menambahkan BottomNavigation
    );
  }

  Widget _buildHistoryItem({required String title, required String date}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeliveryDetails(
      BuildContext context, Map<String, dynamic> deliveryData) {
    final items = List<Map<String, dynamic>>.from(deliveryData['items'] ?? []);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Pengiriman',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Alamat:', deliveryData['address'] ?? 'N/A'),
                _buildDetailRow('Kota:', deliveryData['city'] ?? 'N/A'),
                _buildDetailRow('Penerima:', deliveryData['name'] ?? 'N/A'),
                _buildDetailRow('Kode:', deliveryData['selectedCode'] ?? 'N/A'),
                const SizedBox(height: 8),
                const Text('Items:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Nama:', item['name'] ?? 'N/A'),
                            _buildDetailRow('Brand:', item['brand'] ?? 'N/A'),
                            _buildDetailRow(
                                'Kategori:', item['category'] ?? 'N/A'),
                            _buildDetailRow('Kode:', item['code'] ?? 'N/A'),
                            _buildDetailRow(
                                'Jumlah:', item['quantity']?.toString() ?? '0'),
                            _buildDetailRow('Tanggal Ditambahkan:',
                                item['dateAdded'] ?? 'N/A'),
                            _buildDetailRow('Tanggal Kedaluwarsa:',
                                item['expirationDate'] ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                _exportToPDF(deliveryData);
              },
              child: const Text('Export PDF'),
            ),
          ],
        );
      },
    );
  }

  void _exportToPDF(Map<String, dynamic> deliveryData) async {
    final pdf = pw.Document();

    // Pastikan items adalah list
    final items = List<Map<String, dynamic>>.from(deliveryData['items'] ?? []);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Detail Pengiriman', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              _buildPDFDetailRow('Alamat:', deliveryData['address'] ?? 'N/A'),
              _buildPDFDetailRow('Kota:', deliveryData['city'] ?? 'N/A'),
              _buildPDFDetailRow('Penerima:', deliveryData['name'] ?? 'N/A'),
              _buildPDFDetailRow(
                  'Kode:', deliveryData['selectedCode'] ?? 'N/A'),
              pw.SizedBox(height: 20),
              pw.Text('Items:', style: pw.TextStyle(fontSize: 18)),
              pw.Column(
                children: items.map((item) {
                  return pw.Column(
                    children: [
                      _buildPDFDetailRow('Nama:', item['name'] ?? 'N/A'),
                      _buildPDFDetailRow('Brand:', item['brand'] ?? 'N/A'),
                      _buildPDFDetailRow(
                          'Kategori:', item['category'] ?? 'N/A'),
                      _buildPDFDetailRow('Kode:', item['code'] ?? 'N/A'),
                      _buildPDFDetailRow(
                          'Jumlah:', item['quantity']?.toString() ?? '0'),
                      _buildPDFDetailRow(
                          'Tanggal Ditambahkan:', item['dateAdded'] ?? 'N/A'),
                      _buildPDFDetailRow('Tanggal Kedaluwarsa:',
                          item['expirationDate'] ?? 'N/A'),
                      pw.SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _buildPDFDetailRow(String title, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(value),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
