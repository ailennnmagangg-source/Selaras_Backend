import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DendaPerMingguScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dataDenda;

  // Default value as empty list to prevent the null subtype error
  const DendaPerMingguScreen({super.key, this.dataDenda = const []});

  Color _getStatusColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s == 'terlambat') return Colors.orange;
    if (s == 'selesai') return Colors.green;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id_ID', null);

    // Langsung cegah jika data kosong
    if (dataDenda.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detail Denda Mingguan")),
        body: const Center(child: Text("Data denda minggu ini kosong.")),
      );
    }

    // Kelompokkan data
    Map<String, List<Map<String, dynamic>>> groupedData = {
      'Senin': [], 'Selasa': [], 'Rabu': [], 'Kamis': [],
      'Jumat': [], 'Sabtu': [], 'Minggu': []
    };

    for (var item in dataDenda) {
      try {
        final rawDate = item['created_at'];
        if (rawDate != null) {
          DateTime date = DateTime.parse(rawDate.toString());
          String hari = DateFormat('EEEE', 'id_ID').format(date);
          if (groupedData.containsKey(hari)) {
            groupedData[hari]!.add(item);
          }
        }
      } catch (e) {
        debugPrint("Skip data denda karena tanggal error: $e");
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Laporan Denda Harian", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A4D7C),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: groupedData.keys.map((hari) {
          final items = groupedData[hari]!;
          if (items.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hari, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A4D7C))),
              const SizedBox(height: 12),
              ...items.map((item) {
                // Pengecekan null bertingkat sesuai skema image_573577.png
                final peminjaman = item['peminjaman'] as Map<String, dynamic>?;
                final user = peminjaman?['users'] as Map<String, dynamic>?;
                
                final String nama = user?['nama_users']?.toString() ?? "Tanpa Nama";
                final String status = peminjaman?['status_transaksi']?.toString() ?? "N/A";
                final int denda = item['total_denda'] ?? 0;
                
                String jam = "--:--";
                if (item['created_at'] != null) {
                  jam = DateFormat('HH:mm').format(DateTime.parse(item['created_at']));
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(status).withOpacity(0.1),
                      child: Icon(Icons.money_off, color: _getStatusColor(status)),
                    ),
                    title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [
                        Text(status.toUpperCase(), style: TextStyle(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text("• $jam", style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: Text("Rp $denda", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
              const Divider(height: 30),
            ],
          );
        }).toList(),
      ),
    );
  }
}