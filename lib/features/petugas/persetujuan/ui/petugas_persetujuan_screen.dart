import 'package:flutter/material.dart';
import 'package:selaras_backend/features/shared/widgets/peminjam_detail_alat_screen.dart';
import 'package:selaras_backend/features/petugas/persetujuan/ui/petugas_riwayat_persetujuan_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PetugasPersetujuanScreen extends StatefulWidget {
  const PetugasPersetujuanScreen({super.key});

  @override
  State<PetugasPersetujuanScreen> createState() => _PetugasPersetujuanScreenState();
}

class _PetugasPersetujuanScreenState extends State<PetugasPersetujuanScreen> {
  final supabase = Supabase.instance.client;

  // 1. Fungsi Fetch Data dengan Join ke Tabel Users
  Future<List<Map<String, dynamic>>> _fetchData(bool isPending) async {
    var query = supabase.from('peminjaman').select('''
        *,
        users!peminjam_id (
          nama_users,
          tipe_user
        )
      ''');

    if (isPending) {
      query = query.eq('status_transaksi', 'menunggu persetujuan');
    } else {
      query = query.neq('status_transaksi', 'menunggu persetujuan');
    }

    final response = await query.order('tgl_pengambilan', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // 2. Fungsi Update Status (Trigger DB akan otomatis jalan)
  Future<void> _prosesPersetujuan(int idPinjam, String statusBaru, {String? alasan}) async {
  try {
    final petugasId = supabase.auth.currentUser?.id;

    // Data yang akan di-update
    Map<String, dynamic> updateData = {
      'status_transaksi': statusBaru,
      'petugas_id': petugasId,
    };

    // Jika ada alasan penolakan, masukkan ke dalam payload update
    if (alasan != null) {
      updateData['alasan_penolakan'] = alasan;
    }

    await supabase.from('peminjaman').update(updateData).eq('id_pinjam', idPinjam);

    setState(() {}); // Refresh UI

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil: Pengajuan telah $statusBaru")),
      );
    }
  } catch (e) {
    debugPrint("Gagal update: $e");
  }
}

void _showRejectDialog(int idPinjam) {
  final TextEditingController _alasanController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Alasan Ditolak!", 
          textAlign: TextAlign.center, 
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Catatan:"),
            const SizedBox(height: 8),
            TextField(
              controller: _alasanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Ketik alasan ditolak...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_alasanController.text.isNotEmpty) {
                  Navigator.pop(context); // Tutup dialog
                  _prosesPersetujuan(idPinjam, 'ditolak', alasan: _alasanController.text);
                } else {
                  // Validasi jika alasan kosong
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Alasan tidak boleh kosong!")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5AB9D5),
                minimumSize: const Size(150, 40)
              ),
              child: const Text("Oke", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        appBar: AppBar(
          title: const Text("Persetujuan", style: TextStyle(color: Color(0xFF2D4379), fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF5AB9D5),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF5AB9D5),
            tabs: [
              Tab(text: "Belum Diproses"),
              Tab(text: "Riwayat Persetujuan"),
            ],
          ),
        ),
        // 3. Gunakan _buildListPersetujuan agar data terbagi sesuai Tab
        body: TabBarView(
          children: [
            _buildListPersetujuan(true),           // Tab Belum Diproses (dari file lama)
            const PetugasRiwayatPersetujuanScreen(), // Tab Riwayat (panggil file baru)
          ],
        ),
      ),
    );
  }

  Widget _buildListPersetujuan(bool isPending) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchData(isPending),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final list = snapshot.data ?? [];

        if (list.isEmpty) {
          return const Center(child: Text("Tidak ada data pengajuan"));
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _buildCardPersetujuan(list[index], isPending);
            },
          ),
        );
      },
    );
  }

  Widget _buildCardPersetujuan(Map<String, dynamic> data, bool isPending) {
    final userData = data['users'];
    final String namaPeminjam = userData?['nama_users'] ?? 'Tanpa Nama';
    final String tipeUser = userData?['tipe_user'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFE8F1FF),
                child: Text(namaPeminjam[0].toUpperCase(), style: const TextStyle(color: Color(0xFF5AB9D5))),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(namaPeminjam, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D4379))),
                  Text(tipeUser, style: const TextStyle(fontSize: 12, color: Color(0xFF5AB9D5))),
                ],
              ),
              const Spacer(),
              if (!isPending) _buildBadgeStatus(data['status_transaksi'])
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateInfo("Pengambilan", data['tgl_pengambilan']),
              _buildDateInfo("Tenggat", data['tenggat']),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PeminjamDetailAlatScreen(idPinjam: data['id_pinjam'])),
                  );
                },
                child: const Text("Detail Alat", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                // Di dalam Row tombol kartu persetujuan
                Expanded(
                  child: OutlinedButton(
                    // Panggil fungsi dialog, bukan langsung proses update
                    onPressed: () => _showRejectDialog(data['id_pinjam']), 
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red, 
                      side: const BorderSide(color: Colors.red)
                    ),
                    child: const Text("Tolak"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _prosesPersetujuan(data['id_pinjam'], 'dipinjam'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5AB9D5)),
                    child: const Text("Disetujui", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  // --- Widget Kecil Pembantu ---
  Widget _buildDateInfo(String label, String dateStr) {
    final date = DateTime.parse(dateStr);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(DateFormat('dd MMM | HH:mm').format(date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBadgeStatus(String status) {
    Color color = status == 'dipinjam' ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}