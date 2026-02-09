import 'package:flutter/material.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/aktivitas/aktivitas_controller.dart';
import 'package:intl/intl.dart';
// Pastikan nama file import ini sesuai dengan nama file barumu
import 'package:selaras_backend/features/shared/models/peminjaman_model.dart'; 

class AktivitasScreen extends StatefulWidget {
  @override
  _AktivitasScreenState createState() => _AktivitasScreenState();
}

class _AktivitasScreenState extends State<AktivitasScreen> {
  final AktivitasController _controller = AktivitasController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50, // Latar belakang lebih lembut
        appBar: AppBar(
          title: Text("Aktivitas", 
            style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Data Peminjaman"),
              Tab(text: "Data Pengembalian"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildListAktivitas(false), // Tab Pinjam
            _buildListAktivitas(true),  // Tab Kembali
          ],
        ),
      ),
    );
  }

  Widget _buildListAktivitas(bool isPengembalian) {
    // Pastikan FutureBuilder menggunakan PeminjamanModel
    return FutureBuilder<List<PeminjamanModel>>(
      future: _controller.getAktivitas(isPengembalian),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Tidak ada data aktivitas"));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final data = snapshot.data![index];
            return _buildAktivitasCard(data);
          },
        );
      },
    );
  }

  Widget _buildAktivitasCard(PeminjamanModel data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nama Peminjam & Role
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.namaPeminjam, 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50, 
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Text("Siswa", // Bisa dinamis dari data.role jika ada
                        style: TextStyle(fontSize: 12, color: Colors.blue)
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Divider(height: 32),
            // Info Baris: Pengambilan & Tenggat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn("Pengambilan", 
                  data.tglPengambilan != null 
                    ? DateFormat('dd MMM yyyy | HH.mm').format(data.tglPengambilan!) 
                    : '-'
                ),
                _buildInfoColumn("Tenggat", 
                  data.tenggat != null 
                    ? DateFormat('dd MMM yyyy | HH.mm').format(data.tenggat!) 
                    : '-'
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Alat", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0)),
                      onPressed: () {
                        // Tampilkan modal daftar alat
                      }, 
                      child: Text("Detail Alat", 
                        style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold)
                      )
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 8),
            // Tombol Aksi (Edit & Hapus)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(Icons.edit, Colors.blue, () {
                  // Logika Edit Status
                }),
                SizedBox(width: 8),
                _buildActionButton(Icons.delete, Colors.red, () {
                  // Logika Hapus
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}