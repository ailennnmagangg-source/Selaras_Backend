import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selaras_backend/features/admin/dashboard/aktivitas/aktivitas_controller.dart';
import 'package:selaras_backend/features/admin/dashboard/aktivitas/widgets/edit_tanggal_dialog.dart';
import 'package:selaras_backend/features/admin/dashboard/aktivitas/widgets/hapus_konfirmasi_dialog.dart';
import 'package:selaras_backend/features/shared/widgets/peminjam_detail_alat_screen.dart';
import '../../../../shared/models/peminjaman_model.dart';

class AdminPeminjamanTab extends StatelessWidget {
  final AktivitasController controller = AktivitasController();

  AdminPeminjamanTab({super.key});

  // Fungsi Helper untuk menentukan Header Tanggal
  String _getGroupHeader(DateTime? date) {
    if (date == null) return "Lainnya";
    
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
    return FutureBuilder<List<PeminjamanModel>>(
      future: controller.getAktivitas(false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Tidak ada data peminjaman"));
        }

        // --- LOGIKA GROUPING DATA ---
        final List<PeminjamanModel> rawData = snapshot.data!;
        Map<String, List<PeminjamanModel>> groupedData = {};

        for (var item in rawData) {
          String header = _getGroupHeader(item.tglPengambilan);
          if (groupedData[header] == null) groupedData[header] = [];
          groupedData[header]!.add(item);
        }

        // Mengambil key (header) dan mengurutkan agar "Hari Ini" tetap di atas
        List<String> sortedHeaders = groupedData.keys.toList();
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
                // Header Group (Hari Ini, Kemarin, dsb)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 15, left: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4EB7D9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        header,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: header == "Hari Ini" 
                              ? const Color(0xFF4EB7D9) 
                              : const Color(0xFF1A4D7C),
                        ),
                      ),
                    ],
                  ),
                ),
                // List kartu dalam grup tersebut
                ...items.map((data) => _buildModernAktivitasCard(context, data)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildModernAktivitasCard(BuildContext context, PeminjamanModel data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFF0F7F9),
                      child: Icon(Icons.person, color: Color(0xFF4EB7D9), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.namaPeminjam,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A4D7C)),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text("Siswa", style: TextStyle(fontSize: 10, color: Color(0xFF4EB7D9), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn("Pengambilan", data.tglPengambilan != null ? DateFormat('dd MMM yyyy | HH.mm').format(data.tglPengambilan!) : '-'),
                    _buildInfoColumn("Tenggat", data.tenggat != null ? DateFormat('dd MMM yyyy | HH.mm').format(data.tenggat!) : '-'),
                    _buildDetailAction(context, data),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.lightBlue, size: 20),
                  onPressed: () => showDialog(context: context, builder: (context) => EditTanggalDialog(idPinjam: data.idPinjam)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                  onPressed: () => showDialog(context: context, builder: (context) =>  HapusDialog()),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailAction(BuildContext context, PeminjamanModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Alat", style: TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PeminjamDetailAlatScreen(idPinjam: data.idPinjam),
              ),
            );
          },
          child: const Text(
            "Detail Alat",
            style: TextStyle(
              color: Color(0xFFF9A825),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1A4D7C)),
        ),
      ],
    );
  }
}