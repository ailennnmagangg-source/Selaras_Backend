import 'package:flutter/material.dart';
import 'package:selaras_backend/features/shared/widgets/peminjam_detail_alat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PetugasRiwayatPersetujuanScreen extends StatefulWidget {
  const PetugasRiwayatPersetujuanScreen({super.key});

  @override
  State<PetugasRiwayatPersetujuanScreen> createState() => _PetugasRiwayatPersetujuanScreenState();
}

class _PetugasRiwayatPersetujuanScreenState extends State<PetugasRiwayatPersetujuanScreen> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _fetchRiwayat() async {
    final response = await supabase
        .from('peminjaman')
        .select('*, users!peminjam_id (nama_users, tipe_user)')
        .neq('status_transaksi', 'menunggu persetujuan')
        .order('tgl_pengambilan', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  String _getGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return "Hari Ini";
    if (checkDate == yesterday) return "Kemarin";
    return DateFormat('dd MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchRiwayat(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF5AB9D5)));
        }
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        
        final data = snapshot.data ?? [];
        if (data.isEmpty) return const Center(child: Text("Belum ada riwayat", style: TextStyle(color: Colors.grey)));

        Map<String, List<Map<String, dynamic>>> groupedData = {};
        for (var item in data) {
          if (item['tgl_pengambilan'] != null) {
            DateTime date = DateTime.parse(item['tgl_pengambilan']);
            String header = _getGroupHeader(date);
            if (groupedData[header] == null) groupedData[header] = [];
            groupedData[header]!.add(item);
          }
        }

        List<String> sortedKeys = groupedData.keys.toList();
        if (sortedKeys.contains("Hari Ini")) {
          sortedKeys.remove("Hari Ini");
          sortedKeys.insert(0, "Hari Ini");
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            String header = sortedKeys[index];
            List<Map<String, dynamic>> items = groupedData[header]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
                  child: Row(
                    children: [
                      Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF5AB9D5), borderRadius: BorderRadius.circular(10))),
                      const SizedBox(width: 10),
                      Text(
                        header,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: header == "Hari Ini" ? const Color(0xFF5AB9D5) : const Color(0xFF234F68),
                          letterSpacing: 0.5
                        ),
                      ),
                    ],
                  ),
                ),
                ...items.map((item) => _buildEnhancedRiwayatCard(item)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedRiwayatCard(Map<String, dynamic> item) {
    final userData = item['users'] as Map<String, dynamic>?;
    final String namaUser = userData?['nama_users'] ?? "User";
    final String tipeUser = userData?['tipe_user'] ?? "Umum";
    final String status = item['status_transaksi']?.toString().toLowerCase() ?? '';
    
    Color accentColor;
    Color lightAccent;
    String statusText;

    if (status == 'ditolak') {
      accentColor = const Color(0xFFE57373);
      lightAccent = const Color(0xFFFFEBEE);
      statusText = "Ditolak";
    } else if (status == 'denda') {
      accentColor = const Color(0xFFFFB74D);
      lightAccent = const Color(0xFFFFF3E0);
      statusText = "Denda!";
    } else {
      accentColor = const Color(0xFF5AB9D5);
      lightAccent = const Color(0xFFF0FAFD);
      statusText = status == 'dipinjam' ? "Aktif" : "Selesai";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
          BoxShadow(color: accentColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Bagian Atas: Profil & Status
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: lightAccent,
                        child: Text(
                          namaUser.isNotEmpty ? namaUser[0].toUpperCase() : "?",
                          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              namaUser,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D4379), letterSpacing: -0.3),
                            ),
                            Text(
                              tipeUser,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: lightAccent, borderRadius: BorderRadius.circular(14)),
                        child: Text(
                          statusText,
                          style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Baris Informasi Tanggal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDateInfo("Pengambilan", item['tgl_pengambilan']),
                      _buildDateInfo("Tenggat", item['tenggat']),
                      _buildDateInfo("Kembali", item['tgl_pengembalian'], color: status == 'denda' ? Colors.red : const Color(0xFF5AB9D5)),
                    ],
                  ),
                ],
              ),
            ),
            // Bagian Bawah: Aksi (Detail Alat & Alasan)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50.withOpacity(0.6),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PeminjamDetailAlatScreen(idPinjam: item['id_pinjam']))),
                    child: Row(
                      children: const [
                        Icon(Icons.inventory_2_outlined, size: 14, color: Colors.orange),
                        SizedBox(width: 6),
                        Text("Detail Alat", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  if (status == 'ditolak')
                    GestureDetector(
                      onTap: () => _showAlasanDitolakDialog(item['alasan_penolakan']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Text("Lihat Alasan", style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, String? dateStr, {Color? color}) {
    String formattedDate = "-";
    String formattedTime = "--:--";
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(dateStr).toLocal();
        formattedDate = DateFormat('dd MMM').format(dt);
        formattedTime = DateFormat('HH:mm').format(dt);
      } catch (e) {
        debugPrint("Error parsing: $e");
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        const SizedBox(height: 4),
        Text(formattedDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D4379))),
        Text(formattedTime, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color?.withOpacity(0.8) ?? Colors.grey.shade500)),
      ],
    );
  }

  void _showAlasanDitolakDialog(String? alasan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: const [
            Icon(Icons.info_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Alasan Penolakan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(alasan ?? "Data tidak valid atau stok alat sedang kosong.", style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Mengerti", style: TextStyle(color: Color(0xFF5AB9D5), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}