import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PeminjamDetailAlatScreen extends StatelessWidget {
  final int idPinjam;

  const PeminjamDetailAlatScreen({super.key, required this.idPinjam});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    const Color primaryBlue = Color(0xFF4EB7D9);
    const Color textPrimary = Color(0xFF234F68);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: const Text("Detail Riwayat",
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        // Menambahkan tipe eksplisit <List<dynamic>> pada FutureBuilder
        future: Future.wait([
          supabase
              .from('detail_peminjaman')
              .select('jumlah_pinjam, alat(nama_alat, foto_url, kategori(nama_kategori))')
              .eq('id_pinjam', idPinjam),
          supabase
              .from('denda')
              .select('*')
              .eq('id_kembali', idPinjam)
              .maybeSingle(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          // Melakukan Casting secara manual agar aman
          final details = snapshot.data![0] as List<dynamic>;
          final dendaData = snapshot.data![1] as Map<String, dynamic>?;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text("Alat yang Dipinjam",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(height: 15),
              
              // Render List Alat
              ...details.map((item) {
                final alat = item['alat'];
                return _buildAlatCard(alat, item['jumlah_pinjam']);
              }).toList(),

              // Render Rincian Denda jika data denda tidak null
              if (dendaData != null) ...[
                const SizedBox(height: 30),
                const Text("Rincian Keterlambatan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
                const SizedBox(height: 15),
                _buildDendaCard(dendaData),
              ],
            ],
          );
        },
      ),
    );
  }

  // Helper Widget Alat Card
  Widget _buildAlatCard(dynamic alat, int jumlah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: const Border(left: BorderSide(color: Color(0xFF4EB7D9), width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              alat['foto_url'] ?? '',
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 60, height: 60, color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alat['nama_alat'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF234F68))),
                Text(alat['kategori']['nama_kategori'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text("Dipinjam: $jumlah",
              style: const TextStyle(color: Color(0xFF4EB7D9), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper Widget Denda Card
  Widget _buildDendaCard(Map<String, dynamic> denda) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF4EB7D9), Color(0xFF2D8FB0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4EB7D9).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          _rowDendaItem("Lama Terlambat", "${denda['jumlah_terlambat']} Hari"),
          _rowDendaItem("Tarif per Hari", currencyFormat.format(denda['tarif_per_hari'])),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.white24),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Denda",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              Text(
                currencyFormat.format(denda['total_denda']),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rowDendaItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}