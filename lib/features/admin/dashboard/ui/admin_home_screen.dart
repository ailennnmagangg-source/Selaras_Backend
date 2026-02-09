import 'package:flutter/material.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/akun/admin_akun_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'alat/admin_alat_screen.dart';
import 'log_aktivitas_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  // Tambahkan variabel email
  final String userEmail;

  const AdminHomeScreen({
    super.key, 
    this.userEmail = "mimi@email.com" // Contoh default
  });

  @override
  Widget build(BuildContext context) {
    // Ambil email user yang sedang login dari Supabase
  final user = Supabase.instance.client.auth.currentUser;
  final String displayEmail = user?.email ?? "User"; // Jika null, tampilkan "User"

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Background Biru Utama
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4FA8C5), // Biru sesuai desain
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Halo, $displayEmail ",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Yuk, pantau stok alat dan kelola akun\nuser hari ini!",
                            style: TextStyle(fontSize: 16, color: Colors.white, height: 1.4, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // 2. Efek Lengkungan Putih (Wave effect)
                Positioned(
                  bottom: -1,
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                  ),
                ),

                // 3. Card Ringkasan (Floating/Overlap)
                Positioned(
                  bottom: -40,
                  left: 25,
                  right: 25,
                  child: _buildSummaryCard(),
                ),
              ],
            ),

            // Konten di bawah Stack
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 85), // Jarak untuk Card yang overlap

                  // Row Manajemen Alat & Akun
                  Row(
                    children: [
                      Expanded(
                        child: _buildMenuTile(
                          icon: Icons.inventory_2_outlined,
                          label: "Manajemen Alat",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminAlatScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildMenuTile(
                          icon: Icons.sync,
                          label: "Manajemen Akun",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminAkunScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),
                  const Text(
                    "Log Aktivitas",
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF2D4356)
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Item Log Preview
                  _buildLogItem("Anindya", "Peminjaman", "Petugas: Mimi", isPeminjaman: true),
                  _buildLogItem("Anindya", "Pengembalian", "Petugas: Mimi", isPeminjaman: false),
                  _buildLogItem("Anindya", "Pengembalian", "Petugas: Mimi", isPeminjaman: false),

                  const SizedBox(height: 25),

                  // Tombol Log Aktivitas (Biru Muda)
                  _buildLogNavButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Ringkasan Hari Ini!", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D4356))
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem("Total Alat", "50"),
              _buildSummaryItem("Dipinjam", "30"),
              _buildSummaryItem("Akun Aktif", "25"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(
          value, 
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2D4356))
        ),
      ],
    );
  }

  Widget _buildMenuTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F9FB), // Biru sangat muda
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE1F1F6), width: 1.5),
              ),
              child: Icon(icon, size: 30, color: const Color(0xFF4FA8C5)),
            ),
            const SizedBox(height: 12),
            Text(
              label, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2D4356))
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(String name, String type, String petugas, {required bool isPeminjaman}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE0E0E0), 
            child: Icon(Icons.person, color: Colors.white)
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D4356))),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPeminjaman ? const Color(0xFFE3F2FD) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type, 
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                      color: isPeminjaman ? Colors.blue : Colors.orange
                    )
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(petugas, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogNavButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const LogAktivitasScreen())
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFE1F1F6), // Biru muda tombol nav
          borderRadius: BorderRadius.circular(35),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white, 
              radius: 18,
              child: Icon(Icons.history, color: Color(0xFF4FA8C5), size: 20)
            ),
            SizedBox(width: 15),
            Text(
              "Log Aktivitas", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4FA8C5))
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF4FA8C5)),
          ],
        ),
      ),
    );
  }
}