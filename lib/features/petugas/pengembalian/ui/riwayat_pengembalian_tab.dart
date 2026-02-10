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

        // Filter status Selesai dan Denda saja
        final filteredData = allData.where((item) {
          final status = item['status_transaksi']?.toString().toLowerCase() ?? '';
          return status == 'selesai' || status == 'denda';
        }).toList();

        if (filteredData.isEmpty) {
          return const Center(child: Text("Belum ada riwayat pengembalian"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            final item = filteredData[index];
            return _buildRiwayatCard(context, item, supabase);
          },
        );
      },
    );
  }

  Widget _buildRiwayatCard(BuildContext context, Map<String, dynamic> item, SupabaseClient supabase) {
    final String status = item['status_transaksi']?.toString().toLowerCase() ?? '';
    final bool isDenda = status == 'denda';
    
    // Warna sesuai mockup
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
            // Garis vertikal di sisi kiri sesuai gambar
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
                    // Header: Profil & Detail Alat Link
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
                                  idPinjam: item['id_pinjam'], // Pastikan id_pinjam dikirim ke screen tujuan
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
                              SizedBox(width: 4), // Jarak kecil antara teks dan ikon
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
                    
                    // Info Tanggal Row
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
                    
                    // Status Badge dengan Icon Tanda Seru
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
          ? supabase.from('profiles').select('username, role').eq('id', userId).maybeSingle()
          : Future.value(null),
      builder: (context, snapshot) {
        final profile = snapshot.data as Map<String, dynamic>?;
        final String name = profile?['username'] ?? "User";
        final String role = profile?['role'] ?? "Siswa";

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
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF234F68))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                  child: Text(role.toUpperCase(), style: const TextStyle(fontSize: 9, color: Color(0xFF4EB7D9), fontWeight: FontWeight.bold)),
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