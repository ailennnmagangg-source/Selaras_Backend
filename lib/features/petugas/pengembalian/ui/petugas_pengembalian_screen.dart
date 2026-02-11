import 'package:flutter/material.dart';
import 'belum_diproses_tab.dart';
import 'riwayat_pengembalian_tab.dart';

class PetugasPengembalianScreen extends StatelessWidget {
  const PetugasPengembalianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        appBar: AppBar(
          title: const Text(
            "Pengembalian", 
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
              Tab(child: Text("Belum Diproses")),
              Tab(child: Text("Riwayat Pengembalian")),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BelumDiprosesTab(),      // Tab Status 'menunggu pengecekan'
            RiwayatPengembalianTab(), // Tab Status 'selesai'
          ],
        ),
      ),
    );
  }
}