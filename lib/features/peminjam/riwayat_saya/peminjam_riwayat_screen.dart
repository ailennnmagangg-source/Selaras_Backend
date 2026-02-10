import 'package:flutter/material.dart';
import 'status_peminjaman_tab.dart';
import 'riwayat_peminjaman_tab.dart';

class PeminjamRiwayatScreen extends StatelessWidget {
  const PeminjamRiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        appBar: AppBar(
          title: const Text(
            "Riwayat", 
            style: TextStyle(color: Color(0xFF2D4379), fontWeight: FontWeight.bold)
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF5AB9D5),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF5AB9D5),
            tabs: [
              Tab(child: Text("Status Peminjaman")),
              Tab(child: Text("Riwayat Peminjaman")),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StatusPeminjamanTab(), // Konten Tab 1
            RiwayatPeminjamanTab(), // Konten Tab 2
          ],
        ),
      ),
    );
  }
}