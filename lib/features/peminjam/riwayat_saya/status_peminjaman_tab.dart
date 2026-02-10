import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:selaras_backend/features/shared/widgets/peminjam_detail_alat_screen.dart';

class StatusPeminjamanTab extends StatefulWidget {
  const StatusPeminjamanTab({super.key});

  @override
  State<StatusPeminjamanTab> createState() => _StatusPeminjamanTabState();
}

class _StatusPeminjamanTabState extends State<StatusPeminjamanTab> {
  final supabase = Supabase.instance.client;
  bool _isUpdating = false;

  Stream<List<Map<String, dynamic>>> _getStatusStream() {
    final userId = supabase.auth.currentUser?.id;
    return supabase
        .from('peminjaman')
        .stream(primaryKey: ['id_pinjam'])
        .order('tgl_pengambilan', ascending: false)
        .map((list) => list
            .where((item) =>
                item['peminjam_id'] == userId &&
                [
                  'menunggu persetujuan',
                  'dipinjam',
                  'terlambat',
                  'menunggu pengecekan'
                ].contains(item['status_transaksi']?.toString().toLowerCase()))
            .toList());
  }

  Future<void> _updateStatus(int idPinjam) async {
    setState(() => _isUpdating = true); // Mulai loading
    try {
      await supabase
          .from('peminjaman')
          .update({'status_transaksi': 'menunggu pengecekan'})
          .eq('id_pinjam', idPinjam);
          
      // Beri sedikit delay agar database punya waktu untuk broadcast stream
      await Future.delayed(const Duration(milliseconds: 500)); 
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isUpdating = false); // Berhenti loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getStatusStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final data = snapshot.data!;
        if (data.isEmpty) return const Center(child: Text("Tidak ada peminjaman aktif", style: TextStyle(color: Colors.grey)));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: data.length,
          itemBuilder: (context, index) => _buildModernCard(data[index]),
        );
      },
    );
  }

  Widget _buildModernCard(Map<String, dynamic> item) {
    final String statusRaw = item['status_transaksi']?.toString().toLowerCase() ?? '';
    final bool isWaitingCheck = statusRaw == 'menunggu pengecekan';
    final bool isPendingApproval = statusRaw == 'menunggu persetujuan';
    final int idPinjam = item['id_pinjam'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Garis vertikal indikator warna di sisi kiri (Aksen Modern)
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: _getStatusColor(statusRaw),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Icon + Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_rounded, color: _getStatusColor(statusRaw), size: 22),
                            const SizedBox(width: 8),
                            _buildModernBadge(statusRaw),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF1F4F8)),
                    const SizedBox(height: 16),
                    
                    // Info Row: Pengambilan, Tenggat, Detail Alat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateInfo("Pengambilan", item['tgl_pengambilan']),
                        _buildDateInfo("Tenggat", item['tenggat']),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Alat", style: TextStyle(color: Colors.grey, fontSize: 11)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (context) => PeminjamDetailAlatScreen(idPinjam: idPinjam),
                              )),
                              child: const Text(
                                "Detail Alat",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Button Action
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        // Tombol hanya "disabled" jika sedang menunggu pengecekan atau persetujuan
                        onPressed: (isWaitingCheck || isPendingApproval) 
                            ? null 
                            : () => _updateStatus(idPinjam),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5AB9D5),
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: Text(
                          isWaitingCheck 
                              ? "Menunggu Pengecekan" 
                              : isPendingApproval 
                                  ? "Menunggu Persetujuan" 
                                  : "Ajukan Pengembalian",
                          style: TextStyle(
                            color: (isWaitingCheck || isPendingApproval) ? Colors.grey[600] : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Widget _buildModernBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'dipinjam': return Colors.green;
      case 'terlambat': return Colors.red;
      case 'menunggu pengecekan': return Colors.orange;
      case 'menunggu persetujuan': return Colors.blueGrey;
      default: return const Color(0xFF5AB9D5);
    }
  }

  Widget _buildDateInfo(String label, String? dateStr) {
    DateTime? date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    String formatted = date != null ? DateFormat('dd MMM yyyy | HH.mm').format(date) : '-';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          formatted,
          style: const TextStyle(color: Color(0xFF2D4379), fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}