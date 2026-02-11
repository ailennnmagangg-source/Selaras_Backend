import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:selaras_backend/features/shared/widgets/peminjam_detail_alat_screen.dart';

class RiwayatPeminjamanTab extends StatelessWidget {
  const RiwayatPeminjamanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('peminjaman')
          .stream(primaryKey: ['id_pinjam'])
          .order('tgl_pengambilan', ascending: false)
          .map((maps) => maps
              .where((item) =>
                  item['peminjam_id'] == userId &&
                  ['selesai', 'ditolak', 'denda'].contains(item['status_transaksi']?.toString().toLowerCase()))
              .toList()),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? [];
        if (data.isEmpty) return const Center(child: Text("Belum ada riwayat"));

        // 1. Kelompokkan data berdasarkan tanggal
        Map<String, List<Map<String, dynamic>>> groupedData = {};
        for (var item in data) {
          if (item['tgl_pengambilan'] != null) {
            DateTime date = DateTime.parse(item['tgl_pengambilan']);
            String dateKey = _getGroupHeader(date);
            if (groupedData[dateKey] == null) groupedData[dateKey] = [];
            groupedData[dateKey]!.add(item);
          }
        }

        // 2. LOGIKA AGAR "HARI INI" DI ATAS
        // Ambil semua kunci tanggal yang ada
        List<String> sortedKeys = groupedData.keys.toList();
        
        // Periksa jika ada grup "Hari Ini", pindahkan secara manual ke index 0
        if (sortedKeys.contains("Hari Ini")) {
          sortedKeys.remove("Hari Ini");
          sortedKeys.insert(0, "Hari Ini");
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            String dateHeader = sortedKeys[index];
            List<Map<String, dynamic>> items = groupedData[dateHeader]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
                  child: Text(
                    dateHeader,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Warna berbeda untuk "Hari Ini" agar lebih menonjol
                      color: dateHeader == "Hari Ini" ? const Color(0xFF5AB9D5) : const Color(0xFF234F68),
                    ),
                  ),
                ),
                ...items.map((item) => _buildRiwayatCard(context, item)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRiwayatCard(BuildContext context, Map<String, dynamic> item) {
    final String status = item['status_transaksi']?.toString().toLowerCase() ?? '';
    
    Color mainColor;
    Color bgColor;
    String statusText;
    bool showButton = false;
    String buttonLabel = "";
    VoidCallback? onButtonTap;

    switch (status) {
      case 'ditolak':
        mainColor = const Color(0xFFF77D8E); 
        bgColor = const Color(0xFFF77D8E).withOpacity(0.1);
        statusText = "Ditolak";
        showButton = true;
        buttonLabel = "Alasan";
        onButtonTap = () => _showAlasanDitolakDialog(context, item['alasan_penolakan']);
        break;
      case 'denda':
        mainColor = const Color(0xFFFFB74D); 
        bgColor = const Color(0xFFFFB74D).withOpacity(0.1);
        statusText = "Denda!";
        showButton = true;
        buttonLabel = "Detail Denda";
        onButtonTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => PeminjamDetailAlatScreen(idPinjam: item['id_pinjam'])));
        break;
      default: 
        mainColor = const Color(0xFF5AB9D5); 
        bgColor = const Color(0xFFE3F2FD);
        statusText = "Selesai";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: mainColor, shape: BoxShape.circle),
                    child: const Icon(Icons.priority_high, color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      statusText,
                      style: TextStyle(color: mainColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PeminjamDetailAlatScreen(idPinjam: item['id_pinjam']))),
                child: const Row(
                  children: [
                    Text("Detail Alat ", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F1F1)),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateInfo("Pengambilan", item['tgl_pengambilan']),
              _buildDateInfo("Tenggat", item['tenggat']),
              _buildDateInfo("Dikembalikan", item['tgl_pengembalian'], color: status == 'denda' ? Colors.red : Colors.orange),
            ],
          ),

          if (showButton) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 140, // Ukuran tombol lebih kecil/proporsional
                height: 38,
                child: ElevatedButton(
                  onPressed: onButtonTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: Text(buttonLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String? dateStr, {Color? color}) {
    String formattedDate = "-";
    String formattedTime = "00.00";
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(dateStr);
        formattedDate = DateFormat('dd MMM yyyy').format(dt);
        formattedTime = DateFormat('HH.mm').format(dt);
      } catch (e) {
        debugPrint("Error parsing: $e");
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 6),
        Text(formattedDate, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2D4379))),
        Text(formattedTime, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color ?? const Color(0xFF2D4379))),
      ],
    );
  }

  String _getGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return "Hari Ini";
    if (checkDate == yesterday) return "Kemarin";
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _showAlasanDitolakDialog(BuildContext context, String? alasan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Alasan Ditolak", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(alasan ?? "Data tidak valid atau stok alat sedang kosong."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup")),
        ],
      ),
    );
  }
}