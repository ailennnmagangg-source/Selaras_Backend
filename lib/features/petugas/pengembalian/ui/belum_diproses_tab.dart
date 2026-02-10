import 'package:flutter/material.dart';
import 'package:selaras_backend/features/petugas/pengembalian/ui/petugas_proses_pengembalian_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BelumDiprosesTab extends StatefulWidget {
  const BelumDiprosesTab({super.key});

  @override
  State<BelumDiprosesTab> createState() => _BelumDiprosesTabState();
}

class _BelumDiprosesTabState extends State<BelumDiprosesTab> {
  final supabase = Supabase.instance.client;

  // Menggunakan Stream biasa dari query select untuk mendapatkan relasi
  // Kita akan menggabungkan stream tabel 'peminjaman' dengan data dari 'users'
  Stream<List<Map<String, dynamic>>> _getPengembalianStream() {
    return supabase
        .from('peminjaman')
        // Query select ini mengambil semua kolom peminjaman (*) 
        // DAN data dari tabel users yang berelasi melalui peminjam_id
        .stream(primaryKey: ['id_pinjam'])
        .order('tgl_pengambilan', ascending: false)
        .map((list) => list
            .where((item) => item['status_transaksi']?.toString().toLowerCase() == 'menunggu pengecekan')
            .toList())
        .asyncMap((list) async {
          // Karena .stream() standar tidak melakukan JOIN, 
          // kita lakukan fetch data user manual untuk setiap item dalam list
          final newList = <Map<String, dynamic>>[];
          for (var item in list) {
            final userData = await supabase
                .from('users')
                .select('nama_users, tipe_user')
                .eq('id', item['peminjam_id'])
                .single();
            
            // Gabungkan data peminjaman dengan data user
            newList.add({
              ...item,
              'nama_users': userData['nama_users'],
              'tipe_user': userData['tipe_user'],
            });
          }
          return newList;
        });
  }

  Future<void> _konfirmasiSelesai(int idPinjam) async {
    try {
      await supabase
          .from('peminjaman')
          .update({'status_transaksi': 'selesai'})
          .eq('id_pinjam', idPinjam);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getPengembalianStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        
        final data = snapshot.data ?? [];
        if (data.isEmpty) return const Center(child: Text("Tidak ada pengembalian baru"));

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: data.length,
          itemBuilder: (context, index) => _buildPetugasCard(data[index]),
        );
      },
    );
  }

  Widget _buildPetugasCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFF1F4F8), 
                child: Icon(Icons.person, color: Colors.blueGrey)
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAMA USERS DARI TABEL USERS
                  Text(
                    item['nama_users'] ?? "Peminjam",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  // TIPE USER DARI TABEL USERS
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5AB9D5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text(
                      item['tipe_user'] ?? "-",
                      style: const TextStyle(fontSize: 10, color: Color(0xFF5AB9D5), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildBadge("Menunggu"),
            ],
          ),
          const Divider(height: 32),
          // Info Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateInfo("Pinjam", item['tgl_pengambilan']),
              _buildDateInfo("Tenggat", item['tenggat']),
              const Text("Detail Alat", style: TextStyle(color: Colors.orange, decoration: TextDecoration.underline, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: // Di dalam Widget _buildPetugasCard
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PetugasProsesPengembalianScreen(item: item),
                  ),
                );
              },
              child: const Text("Pengembalian"), // Ubah teks sesuai gambar
            )
          )
        ],
      ),
    );
  }

  // Widget pendukung Badge & DateInfo tetap sama seperti sebelumnya...
  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(label.toUpperCase(), style: const TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDateInfo(String label, String? dateStr) {
    DateTime? date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    String formatted = date != null ? DateFormat('dd MMM yyyy').format(date) : '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(formatted, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2D4379))),
      ],
    );
  }
}