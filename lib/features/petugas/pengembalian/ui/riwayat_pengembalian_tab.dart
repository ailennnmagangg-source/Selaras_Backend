import 'package:flutter/material.dart';
import 'package:selaras_backend/features/shared/widgets/peminjam_detail_alat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class RiwayatPengembalianTab extends StatelessWidget {
  const RiwayatPengembalianTab({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('peminjaman')
          .stream(primaryKey: ['id_pinjam'])
          .order('tgl_pengambilan', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final allData = snapshot.data ?? [];

        // 1. Filter status Selesai dan Denda saja
        final filteredData = allData.where((item) {
          final status = item['status_transaksi']?.toString().toLowerCase() ?? '';
          return status == 'selesai' || status == 'denda';
        }).toList();

        if (filteredData.isEmpty) {
          return const Center(child: Text("Belum ada riwayat pengembalian"));
        }

        // 2. LOGIKA GROUPING
        Map<String, List<Map<String, dynamic>>> groupedData = {};
        for (var item in filteredData) {
          String header = _getGroupHeader(item['tgl_pengambilan']);
          if (groupedData[header] == null) groupedData[header] = [];
          groupedData[header]!.add(item);
        }

        // 3. Pastikan "Hari Ini" selalu di paling atas
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
                // Header Tanggal (Hari Ini / Kemarin / Tanggal)
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
                // Render list card di bawah header tersebut
                ...items.map((item) => _buildRiwayatCard(context, item, supabase)).toList(),
              ],
            );
          },
        );
      },
    );
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

  Widget _buildRiwayatCard(BuildContext context, Map<String, dynamic> item, SupabaseClient supabase) {
    final String status = item['status_transaksi']?.toString().toLowerCase() ?? '';
    final bool isDenda = status == 'denda';
    
    final Color mainColor = isDenda ? const Color(0xFFFFB74D) : const Color(0xFF5AB9D5);
    final Color bgColor = isDenda ? const Color(0xFFFFB74D).withOpacity(0.1) : const Color(0xFFE3F2FD);
    final String statusLabel = isDenda ? "Denda!" : "Selesai";
    final String? userId = item['peminjam_id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildUserProfile(supabase, userId),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PeminjamDetailAlatScreen(
                                  idPinjam: item['id_pinjam'],
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: const [
                              Text(
                                "Detail Alat", 
                                style: TextStyle(
                                  color: Color(0xFF4EB7D9), 
                                  fontSize: 11, 
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios, 
                                size: 10, 
                                color: Color(0xFF4EB7D9),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateItem("Pengambilan", item['tgl_pengambilan']),
                        _buildDateItem("Tenggat", item['tenggat']),
                        _buildDateItem("Dikembalikan", item['tgl_pengembalian'], 
                            highlight: true, 
                            highlightColor: isDenda ? Colors.red : Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: mainColor, shape: BoxShape.circle),
                          child: const Icon(Icons.priority_high, color: Colors.white, size: 12),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            statusLabel,
                            style: TextStyle(color: mainColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(SupabaseClient supabase, String? userId) {
    return FutureBuilder(
      future: userId != null 
          ? supabase.from('users').select('nama_users, tipe_user').eq('id', userId).maybeSingle()
          : Future.value(null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
        }

        final userData = snapshot.data as Map<String, dynamic>?;
        final String namaPeminjam = userData?['nama_users'] ?? "Tidak Diketahui";        
        final String tipeUser = userData?['tipe_user'] ?? "Umum";

        Color labelColor = tipeUser.toLowerCase() == 'guru' ? Colors.orange.shade100 : const Color(0xFFE3F2FD);
        Color textColor = tipeUser.toLowerCase() == 'guru' ? Colors.orange.shade800 : const Color(0xFF4EB7D9);

        return Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFF0F7F9),
              child: Icon(Icons.person, color: Color(0xFF4EB7D9), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaPeminjam, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF234F68))
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: labelColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    tipeUser.toUpperCase(), 
                    style: TextStyle(fontSize: 9, color: textColor, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateItem(String label, String? dateStr, {bool highlight = false, Color? highlightColor}) {
    String formattedDate = "-";
    String formattedTime = "";
    if (dateStr != null) {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
      formattedTime = DateFormat('HH.mm').format(dt);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 4),
        Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF234F68))),
        Text(formattedTime, style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 10, 
          color: highlight ? highlightColor : const Color(0xFF234F68)
        )),
      ],
    );
  }
}