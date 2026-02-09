import 'package:flutter/material.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/aktivitas/aktivitas_controller.dart';
import 'package:intl/intl.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/aktivitas/widgets/edit_tanggal_dialog.dart';

import 'package:selaras_backend/features/admin/dashboard/ui/aktivitas/widgets/hapus_konfirmasi_dialog.dart';
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Aktivitas",
            style: TextStyle(
              color: Color(0xFF1A4D7C), // Biru gelap sesuai image_fba720.png
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        body: Column(
          children: [
            // 1. Search Bar (Menambahkan Search Bar sesuai image_fba720.png)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari nama pelanggan",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            // 2. TabBar dengan Styling Khusus
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TabBar(
                labelColor: Color(0xFF00A9E0), // Biru cerah
                unselectedLabelColor: Colors.grey.shade400,
                indicatorColor: Color(0xFF00A9E0),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 20),
                        SizedBox(width: 8),
                        Text("Data Peminjaman"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 20),
                        SizedBox(width: 8),
                        Text("Data Pengembalian"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  _buildListAktivitas(false),
                  _buildListAktivitas(true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListAktivitas(bool isPengembalian) {
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
          padding: EdgeInsets.all(20),
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
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Header User
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(Icons.person, color: Colors.blue, size: 30),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.namaPeminjam,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1A4D7C))),
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text("Siswa", style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // Info Baris
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn("Pengambilan", data.tglPengambilan != null ? DateFormat('dd MMM yyyy | HH.mm').format(data.tglPengambilan!) : '-'),
                _buildInfoColumn("Tenggat", data.tenggat != null ? DateFormat('dd MMM yyyy | HH.mm').format(data.tenggat!) : '-'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Alat", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0)),
                      child: Text("Detail Alat", style: TextStyle(color: Colors.orange.shade400, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            // Icons Edit & Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.lightBlue, size: 22),
                  onPressed: () {
                    // Panggil Dialog Edit
                    showDialog(
                      context: context,
                      builder: (context) => EditTanggalDialog(
                      // Pakai idPinjam sesuai yang tertulis di Model kamu
                        idPinjam: data.idPinjam,
                      ),
                    );
                  },
                ),
                SizedBox(width: 15),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade400, size: 22),
                  onPressed: () {
                    // Panggil Dialog Hapus
                    showDialog(
                      context: context,
                      builder: (context) => HapusDialog(),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 5),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A4D7C))),
      ],
    );
  }
}