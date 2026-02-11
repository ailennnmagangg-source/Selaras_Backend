import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selaras_backend/features/shared/widgets/peminjam_detail_alat_screen.dart';
import '../aktivitas_controller.dart';
import '../widgets/edit_tanggal_dialog.dart';
import '../widgets/hapus_konfirmasi_dialog.dart';
import '../../../../shared/models/peminjaman_model.dart';

class AdminPengembalianTab extends StatelessWidget {
  final AktivitasController controller = AktivitasController();

  AdminPengembalianTab({super.key});

  // Fungsi Helper untuk menentukan Header Tanggal (Berdasarkan tglPengembalian)
  String _getGroupHeader(DateTime? date) {
    if (date == null) return "Belum Dikembalikan";
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return "Hari Ini";
    if (checkDate == yesterday) return "Kemarin";
    
    if (date.year == now.year) {
      return DateFormat('dd MMMM').format(date);
    }
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PeminjamanModel>>(
      future: controller.getAktivitas(true), // Mengambil status 'selesai' & 'denda'
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4EB7D9)));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Tidak ada riwayat pengembalian", style: TextStyle(color: Colors.grey)));
        }

        // --- PROSES GROUPING DATA ---
        final List<PeminjamanModel> rawData = snapshot.data!;
        Map<String, List<PeminjamanModel>> groupedData = {};

        for (var item in rawData) {
          // Kita grouping berdasarkan tanggal pengembalian
          String header = _getGroupHeader(item.tglPengembalian);
          if (groupedData[header] == null) groupedData[header] = [];
          groupedData[header]!.add(item);
        }

        List<String> sortedHeaders = groupedData.keys.toList();
        
        // Sorting header agar yang terbaru (Hari Ini) di atas
        if (sortedHeaders.contains("Hari Ini")) {
          sortedHeaders.remove("Hari Ini");
          sortedHeaders.insert(0, "Hari Ini");
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          itemCount: sortedHeaders.length,
          itemBuilder: (context, index) {
            final header = sortedHeaders[index];
            final items = groupedData[header]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Group
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 15, left: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4, height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9A825), // Oranye untuk pembeda dengan peminjaman
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        header,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: header == "Hari Ini" ? const Color(0xFFF9A825) : const Color(0xFF1A4D7C),
                        ),
                      ),
                    ],
                  ),
                ),
                ...items.map((data) => _buildModernReturnCard(context, data)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildModernReturnCard(BuildContext context, PeminjamanModel data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A4D7C).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.blue.shade50.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header: Profil
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFF0F7F9),
                      child: Text(
                        data.namaPeminjam.isNotEmpty ? data.namaPeminjam[0].toUpperCase() : "?",
                        style: const TextStyle(color: Color(0xFF4EB7D9), fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.namaPeminjam,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1A4D7C)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text("Selesai", style: TextStyle(fontSize: 9, color: Color(0xFF4EB7D9), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    _buildDetailAction(context, data),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 16),
                
                // Info Baris
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDateColumn("Pengambilan", data.tglPengambilan),
                    _buildDateColumn("Jatuh Tempo", data.tenggat),
                    _buildDateColumn("Dikembalikan", data.tglPengembalian, isHighlight: true),
                  ],
                ),
              ],
            ),
          ),
          
          // Footer: Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50.withOpacity(0.8),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_note_outlined, color: Colors.lightBlue, size: 22),
                  onPressed: () => showDialog(context: context, builder: (context) => EditTanggalDialog(idPinjam: data.idPinjam)),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 20),
                  onPressed: () => showDialog(context: context, builder: (context) => HapusDialog()),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailAction(BuildContext context, PeminjamanModel data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PeminjamDetailAlatScreen(idPinjam: data.idPinjam),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "Detail Alat",
          style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildDateColumn(String label, DateTime? date, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          date != null ? DateFormat('dd MMM | HH:mm').format(date) : '-',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: isHighlight ? const Color(0xFFF9A825) : const Color(0xFF1A4D7C),
          ),
        ),
      ],
    );
  }
}