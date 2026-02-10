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

  void _showAlasanDialog(String? alasan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Alasan Ditolak!", 
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)
            ),
            const SizedBox(height: 15),
            Image.asset(
              'assets/images/image_ditolak.png',
              height: 140,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.info_outline, size: 60, color: Colors.red);
              },
            ), 
            const SizedBox(height: 15),
            const Text("Catatan:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D4379))),
            const SizedBox(height: 5),
            
            // Pengamanan Null pada teks alasan
            Text(alasan ?? "Tidak ada alasan spesifik."),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5AB9D5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: const Text("Oke", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchRiwayat(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
        }
        
        final data = snapshot.data ?? [];
        if (data.isEmpty) return const Center(child: Text("Belum ada riwayat"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            
            // --- PERBAIKAN UTAMA: PENGAMANAN DATA NULL ---
            
            // 1. Ambil data user dengan Null Safety (ini penyebab utama error merah Anda)
            final userData = item['users'] as Map<String, dynamic>?;
            final String namaUser = userData?['nama_users'] ?? "User Tidak Dikenal";
            final String tipeUser = userData?['tipe_user'] ?? "Umum";

            // 2. Ambil status dan alasan
            final String statusRaw = item['status_transaksi']?.toString() ?? "selesai";
            final bool isDitolak = statusRaw.toLowerCase() == 'ditolak';
            final String? alasanDitolak = item['alasan_penolakan'] as String?;

            // 3. Ambil tanggal dengan fallback jika null
            final String tglAmbil = item['tgl_pengambilan'] ?? DateTime.now().toIso8601String();
            final String tglTenggat = item['tenggat'] ?? DateTime.now().toIso8601String();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian Atas: Profil Peminjam
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFE8F1FF),
                        child: Text(
                          namaUser.isNotEmpty ? namaUser[0].toUpperCase() : "?", 
                          style: const TextStyle(color: Color(0xFF5AB9D5))
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaUser, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D4379))
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F1FF), 
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: Text(tipeUser, style: const TextStyle(fontSize: 10, color: Color(0xFF5AB9D5))),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Color(0xFFEEEEEE)),
                  
                  // Bagian Tengah: Info Waktu dan Tombol Detail
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn("Pengambilan", tglAmbil),
                      _buildInfoColumn("Tenggat", tglTenggat),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Alat", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PeminjamDetailAlatScreen(
                                    idPinjam: item['id_pinjam'] ?? 0, 
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, 
                              minimumSize: const Size(0, 0),
                            ),
                            child: const Text(
                              "Detail Alat", 
                              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bagian Bawah: Status Badge (Sesuai Mockup image_03a7b4)
                  GestureDetector(
                    onTap: () {
                      if (isDitolak) {
                        _showAlasanDialog(alasanDitolak);
                      }
                    },
                    child: Text(
                      isDitolak ? "Ditolak" : "Disetujui",
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: isDitolak ? Colors.red : const Color(0xFF5AB9D5),
                        decoration: isDitolak ? TextDecoration.underline : TextDecoration.none
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoColumn(String label, String dateStr) {
    // Pengamanan parsing tanggal agar tidak crash jika format salah
    DateTime? date;
    try {
      date = DateTime.parse(dateStr);
    } catch (e) {
      date = DateTime.now();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          DateFormat('dd MMM yyyy | HH.mm').format(date), 
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2D4379))
        ),
      ],
    );
  }
}