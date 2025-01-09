import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Mengimpor Firestore
import 'package:uas_inventory/Component/navigation_bar.dart'; // Mengimpor BottomNavigation
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:uas_inventory/ComponentUser/navigation_bar_user.dart';

class HistoryScreenUser extends StatelessWidget {
  const HistoryScreenUser({Key? key}) : super(key: key);

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
          // Mengambil data pengiriman dari Firestore secara real-time
          stream: FirebaseFirestore.instance.collection('delivery').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CircularProgressIndicator()); // Menampilkan indikator loading
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                  child: Text(
                      'Tidak ada riwayat pengiriman.')); // Menampilkan pesan jika tidak ada data
            }

            final deliveryItems =
                snapshot.data!.docs; // Mengambil item pengiriman

            return ListView.builder(
              itemCount: deliveryItems.length,
              itemBuilder: (context, index) {
                var data = deliveryItems[index].data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    _showDeliveryDetails(context,
                        data); // Menampilkan detail pengiriman saat item ditekan
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
          const BottomNavigationUser(), // Menambahkan BottomNavigation
    );
  }

  // Fungsi untuk membangun item riwayat pengiriman
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

  // Fungsi untuk menampilkan detail pengiriman dalam dialog
  void _showDeliveryDetails(
      BuildContext context, Map<String, dynamic> deliveryData) {
    final items = List<Map<String, dynamic>>.from(
        deliveryData['items'] ?? []); // Mengambil daftar item dari pengiriman

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
                _buildDetailRow('Alamat:',
                    deliveryData['address'] ?? 'N/A'), // Menampilkan alamat
                _buildDetailRow(
                    'Kota:', deliveryData['city'] ?? 'N/A'), // Menampilkan kota
                _buildDetailRow('Penerima:',
                    deliveryData['name'] ?? 'N/A'), // Menampilkan nama penerima
                _buildDetailRow('Kode:',
                    deliveryData['selectedCode'] ?? 'N/A'), // Menampilkan kode
                const SizedBox(height: 8),
                const Text('Items:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16)), // Judul untuk daftar barang
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
                            _buildDetailRow('Nama:',
                                item['name'] ?? 'N/A'), // Menampilkan nama item
                            _buildDetailRow('Brand:',
                                item['brand'] ?? 'N/A'), // Menampilkan brand
                            _buildDetailRow(
                                'Kategori:',
                                item['category'] ??
                                    'N/A'), // Menampilkan kategori
                            _buildDetailRow('Kode:',
                                item['code'] ?? 'N/A'), // Menampilkan kode item
                            _buildDetailRow(
                                'Jumlah:',
                                item['quantity']?.toString() ??
                                    '0'), // Menampilkan jumlah
                            _buildDetailRow(
                                'Tanggal Ditambahkan:',
                                item['dateAdded'] ??
                                    'N/A'), // Menampilkan tanggal ditambahkan
                            _buildDetailRow(
                                'Tanggal Kedaluwarsa:',
                                item['expirationDate'] ??
                                    'N/A'), // Menampilkan tanggal kedaluwarsa
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
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                _exportToPDF(
                    deliveryData); // Mengekspor detail pengiriman ke PDF
              },
              child: const Text('Export PDF'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mengekspor detail pengiriman ke PDF
  void _exportToPDF(Map<String, dynamic> deliveryData) async {
    final pdf = pw.Document(); // Membuat dokumen PDF

    // Pastikan items adalah list
    final items = List<Map<String, dynamic>>.from(deliveryData['items'] ?? []);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Detail Pengiriman',
                  style: pw.TextStyle(fontSize: 24)), // Judul PDF
              pw.SizedBox(height: 20),
              _buildPDFDetailRow(
                  'Alamat:',
                  deliveryData['address'] ??
                      'N/A'), // Menampilkan alamat di PDF
              _buildPDFDetailRow('Kota:',
                  deliveryData['city'] ?? 'N/A'), // Menampilkan kota di PDF
              _buildPDFDetailRow(
                  'Penerima:',
                  deliveryData['name'] ??
                      'N/A'), // Menampilkan nama penerima di PDF
              _buildPDFDetailRow(
                  'Kode:',
                  deliveryData['selectedCode'] ??
                      'N/A'), // Menampilkan kode di PDF
              pw.SizedBox(height: 20),
              pw.Text('Items:',
                  style: pw.TextStyle(
                      fontSize: 18)), // Judul untuk daftar item di PDF
              pw.Column(
                children: items.map((item) {
                  return pw.Column(
                    children: [
                      _buildPDFDetailRow(
                          'Nama:',
                          item['name'] ??
                              'N/A'), // Menampilkan nama item di PDF
                      _buildPDFDetailRow('Brand:',
                          item['brand'] ?? 'N/A'), // Menampilkan brand di PDF
                      _buildPDFDetailRow(
                          'Kategori:',
                          item['category'] ??
                              'N/A'), // Menampilkan kategori di PDF
                      _buildPDFDetailRow(
                          'Kode:',
                          item['code'] ??
                              'N/A'), // Menampilkan kode item di PDF
                      _buildPDFDetailRow(
                          'Jumlah:',
                          item['quantity']?.toString() ??
                              '0'), // Menampilkan jumlah di PDF
                      _buildPDFDetailRow(
                          'Tanggal Ditambahkan:',
                          item['dateAdded'] ??
                              'N/A'), // Menampilkan tanggal ditambahkan di PDF
                      _buildPDFDetailRow(
                          'Tanggal Kedaluwarsa:',
                          item['expirationDate'] ??
                              'N/A'), // Menampilkan tanggal kedaluwarsa di PDF
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
        onLayout: (PdfPageFormat format) async =>
            pdf.save()); // Mencetak layout PDF
  }

  // Fungsi untuk membangun baris detail di PDF
  pw.Widget _buildPDFDetailRow(String title, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold)), // Menampilkan judul di PDF
        pw.Text(value), // Menampilkan nilai di PDF
      ],
    );
  }

  // Fungsi untuk membangun baris detail di dialog
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold))), // Menampilkan judul
          Expanded(
              child:
                  Text(value, textAlign: TextAlign.end)), // Menampilkan nilai
        ],
      ),
    );
  }
}
