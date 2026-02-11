import 'package:flutter/material.dart';
import 'package:selaras_backend/features/petugas/pengembalian/ui/petugas_proses_pengembalian_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/peminjam_detail_alat_screen.dart';

class BelumDiprosesTab extends StatefulWidget {
  const BelumDiprosesTab({super.key});

  @override
  State<BelumDiprosesTab> createState() => _BelumDiprosesTabState();
}

class _BelumDiprosesTabState extends State<BelumDiprosesTab> {
  final supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> _getPengembalianStream() {
    return supabase
        .from('peminjaman')
        .stream(primaryKey: ['id_pinjam'])
        .order('tgl_pengambilan', ascending: false)
        .map((list) => list
            .where((item) => item['status_transaksi']?.toString().toLowerCase() == 'menunggu pengecekan')
            .toList())
        .asyncMap((list) async {
          final newList = <Map<String, dynamic>>[];
          for (var item in list) {
            try {
              final userData = await supabase
                  .from('users')
                  .select('nama_users, tipe_user')
                  .eq('id', item['peminjam_id'])
                  .single();
              
              newList.add({
                ...item,
                'nama_users': userData['nama_users'],
                'tipe_user': userData['tipe_user'],
              });
            } catch (e) {
              newList.add(item);
            }
          }
          return newList;
        });
  }

  // Fungsi Helper Header Tanggal
  String _getGroupHeader(String? dateStr) {
    if (dateStr == null) return "Lainnya";
    final DateTime date = DateTime.parse(dateStr).toLocal();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return "Hari Ini";
    if (checkDate == yesterday) return "Kemarin";
    return DateFormat('dd MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getPengembalianStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        
        final data = snapshot.data ?? [];
        if (data.isEmpty) return const Center(child: Text("Tidak ada pengembalian baru"));

        // --- LOGIKA GROUPING ---
        Map<String, List<Map<String, dynamic>>> groupedData = {};
        for (var item in data) {
          String header = _getGroupHeader(item['tgl_pengambilan']);
          if (groupedData[header] == null) groupedData[header] = [];
          groupedData[header]!.add(item);
        }

        // Pastikan "Hari Ini" muncul paling atas jika ada
        List<String> sortedHeaders = groupedData.keys.toList();
        if (sortedHeaders.contains("Hari Ini")) {
          sortedHeaders.remove("Hari Ini");
          sortedHeaders.insert(0, "Hari Ini");
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: sortedHeaders.length,
          itemBuilder: (context, index) {
            final header = sortedHeaders[index];
            final items = groupedData[header]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Tanggal Modern
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 15, left: 4),
                  child: Text(
                    header,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF234F68),
                    ),
                  ),
                ),
                // Item Card
                ...items.map((item) => _buildPetugasCard(item)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPetugasCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFF1F4F8), 
                child: Icon(Icons.person, color: Color(0xFF5AB9D5))
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nama_users'] ?? "Peminjam",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF234F68)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5AB9D5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)
                    ),
                    child: Text(
                      item['tipe_user']?.toUpperCase() ?? "-",
                      style: const TextStyle(fontSize: 9, color: Color(0xFF5AB9D5), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildBadge("Menunggu"),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F4F8)),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateInfo("Pinjam", item['tgl_pengambilan']),
              _buildDateInfo("Tenggat", item['tenggat']),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PeminjamDetailAlatScreen(
                        idPinjam: item['id_pinjam'] ?? 0, 
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Detail Alat",
                  style: TextStyle(
                    color: Colors.orange,
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PetugasProsesPengembalianScreen(item: item),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5AB9D5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text(
                "Proses Pengembalian", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            )
          )
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(10)
      ),
      child: Text(
        label.toUpperCase(), 
        style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w800)
      ),
    );
  }

  Widget _buildDateInfo(String label, String? dateStr) {
    DateTime? date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    String formatted = date != null ? DateFormat('dd MMM yyyy').format(date.toLocal()) : '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(formatted, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF234F68))),
      ],
    );
  }
}