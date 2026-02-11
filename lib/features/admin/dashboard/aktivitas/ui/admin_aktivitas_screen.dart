import 'package:flutter/material.dart';
import 'package:selaras_backend/features/admin/dashboard/aktivitas/ui/admin_peminjaman_tab.dart';
import 'package:selaras_backend/features/admin/dashboard/aktivitas/ui/admin_pengembalian_tab.dart';


class AktivitasScreen extends StatefulWidget {
  @override
  _AktivitasScreenState createState() => _AktivitasScreenState();
}

class _AktivitasScreenState extends State<AktivitasScreen> {
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
          title: const Text(
            "Aktivitas",
            style: TextStyle(color: Color(0xFF1A4D7C), fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  AdminPeminjamanTab(), // Panggil file PeminjamanTab
                  AdminPengembalianTab(), // Panggil file PengembalianTab
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: "Cari nama pelanggan",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TabBar(
        labelColor: Color(0xFF00A9E0),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xFF00A9E0),
        indicatorSize: TabBarIndicatorSize.label,
        tabs: [
          Tab(text: "Data Peminjaman"),
          Tab(text: "Data Pengembalian"),
        ],
      ),
    );
  }
}