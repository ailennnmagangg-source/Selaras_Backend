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
                  // Mengambil status Selesai, Ditolak, dan Denda
                  ['selesai', 'ditolak', 'denda'].contains(item['status_transaksi']?.toString().toLowerCase()))
              .toList()),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? [];
        if (data.isEmpty) return const Center(child: Text("Belum ada riwayat"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return _buildRiwayatCard(context, item);
          },
        );
      },
    );
  }

  Widget _buildRiwayatCard(BuildContext context, Map<String, dynamic> item) {
    final String status = item['status_transaksi']?.toString().toLowerCase() ?? '';
    
    // Konfigurasi Warna & Ikon berdasarkan status sesuai gambar
    Color mainColor;
    Color bgColor;
    String statusText;
    bool showButton = false;
    String buttonLabel = "";
    VoidCallback? onButtonTap;

    switch (status) {
      case 'ditolak':
        mainColor = const Color(0xFFF77D8E); // Pink/Merah Ditolak
        bgColor = const Color(0xFFF77D8E).withOpacity(0.1);
        statusText = "Ditolak";
        showButton = true;
        buttonLabel = "Alasan";
        onButtonTap = () => _showAlasanDitolakDialog(context, item['alasan_penolakan']);
        break;
      case 'denda':
        mainColor = const Color(0xFFFFB74D); // Oranye Denda
        bgColor = const Color(0xFFFFB74D).withOpacity(0.1);
        statusText = "Denda!";
        showButton = true;
        buttonLabel = "Detail Denda";
        onButtonTap = () {
            // Navigasi ke detail alat yang juga menampilkan rincian denda
            Navigator.push(context, MaterialPageRoute(builder: (context) => PeminjamDetailAlatScreen(idPinjam: item['id_pinjam'])));
        };
        break;
      default: // Selesai
        mainColor = const Color(0xFF5AB9D5); // Biru Selesai
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Icon Lingkaran Tanda Seru sesuai Gambar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: mainColor, shape: BoxShape.circle),
                    child: const Icon(Icons.priority_high, color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 12),
                  // Badge Status
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PeminjamDetailAlatScreen(idPinjam: item['id_pinjam'])),
                ),
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
          
          // Tanggal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateInfo("Pengambilan", item['tgl_pengambilan']),
              _buildDateInfo("Tenggat", item['tenggat']),
              _buildDateInfo("Dikembalikan", item['tgl_pengembalian'], color: status == 'denda' ? Colors.red : Colors.orange),
            ],
          ),

          // Tombol Aksi (Hanya muncul jika Ditolak atau Denda)
          if (showButton) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: onButtonTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5AB9D5), // Warna Tombol sesuai mockup
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: Text(buttonLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    if (dateStr != null) {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
      formattedTime = DateFormat('HH.mm').format(dt);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 6),
        Text(
          "$formattedDate | $formattedTime",
          style: TextStyle(
            fontSize: 11, 
            fontWeight: FontWeight.bold, 
            color: color ?? const Color(0xFF2D4379)
          ),
        ),
      ],
    );
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