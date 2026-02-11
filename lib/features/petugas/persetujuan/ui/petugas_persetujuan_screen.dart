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

  Future<void> _prosesPersetujuan(int idPinjam, String statusBaru, {String? alasan}) async {
    try {
      final petugasId = supabase.auth.currentUser?.id;
      Map<String, dynamic> updateData = {
        'status_transaksi': statusBaru,
        'petugas_id': petugasId,
      };

      if (alasan != null) {
        updateData['alasan_penolakan'] = alasan;
      }

      await supabase.from('peminjaman').update(updateData).eq('id_pinjam', idPinjam);
      setState(() {});

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Alasan Ditolak!", 
            textAlign: TextAlign.center, 
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Catatan:", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _alasanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Ketik alasan ditolak...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_alasanController.text.isNotEmpty) {
                    Navigator.pop(context);
                    _prosesPersetujuan(idPinjam, 'ditolak', alasan: _alasanController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Alasan tidak boleh kosong!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5AB9D5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(180, 45)
                ),
                child: const Text("Kirim Perolakan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
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
          title: const Text("Persetujuan", style: TextStyle(color: Color(0xFF234F68), fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF5AB9D5),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF5AB9D5),
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Belum Diproses"),
              Tab(text: "Riwayat Persetujuan"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildListPersetujuan(true),
            const PetugasRiwayatPersetujuanScreen(),
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
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        
        final list = snapshot.data ?? [];
        if (list.isEmpty) return const Center(child: Text("Tidak ada data pengajuan"));

        // --- LOGIKA GROUPING ---
        Map<String, List<Map<String, dynamic>>> groupedData = {};
        for (var item in list) {
          String header = _getGroupHeader(item['tgl_pengambilan']);
          if (groupedData[header] == null) groupedData[header] = [];
          groupedData[header]!.add(item);
        }

        List<String> sortedHeaders = groupedData.keys.toList();
        // Sorting "Hari Ini" ke paling atas
        if (sortedHeaders.contains("Hari Ini")) {
          sortedHeaders.remove("Hari Ini");
          sortedHeaders.insert(0, "Hari Ini");
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: sortedHeaders.length,
            itemBuilder: (context, index) {
              final header = sortedHeaders[index];
              final items = groupedData[header]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 15, left: 4),
                    child: Text(
                      header,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF234F68)),
                    ),
                  ),
                  ...items.map((data) => _buildCardPersetujuan(data, isPending)).toList(),
                ],
              );
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
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF1F4F8),
                child: Text(namaPeminjam[0].toUpperCase(), style: const TextStyle(color: Color(0xFF5AB9D5), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(namaPeminjam, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF234F68))),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF5AB9D5).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(tipeUser.toUpperCase(), style: const TextStyle(fontSize: 9, color: Color(0xFF5AB9D5), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Spacer(),
              if (!isPending) _buildBadgeStatus(data['status_transaksi'])
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F4F8)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateInfo("Pengambilan", data['tgl_pengambilan']),
              _buildDateInfo("Tenggat", data['tenggat']),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PeminjamDetailAlatScreen(idPinjam: data['id_pinjam'])),
                  );
                },
                child: const Text("Detail Alat", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.underline)),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(data['id_pinjam']), 
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red, 
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                    child: const Text("Tolak", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _prosesPersetujuan(data['id_pinjam'], 'dipinjam'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5AB9D5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0
                    ),
                    child: const Text("Setujui", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String dateStr) {
    final date = DateTime.parse(dateStr).toLocal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(DateFormat('dd MMM | HH:mm').format(date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF234F68))),
      ],
    );
  }

  Widget _buildBadgeStatus(String status) {
    Color color = status == 'dipinjam' ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
    );
  }
}