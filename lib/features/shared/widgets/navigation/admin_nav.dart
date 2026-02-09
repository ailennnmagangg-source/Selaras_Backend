import 'package:flutter/material.dart';
import 'package:selaras_backend/features/admin/dashboard/aktivitas/ui/admin_aktivitas_screen.dart';
import 'package:selaras_backend/features/admin/dashboard/akun/admin_akun_screen.dart';
import 'package:selaras_backend/features/admin/dashboard/alat/admin_alat_screen.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/dashboard_screen.dart';
import 'package:selaras_backend/features/shared/widgets/profile_screen.dart';
// Import semua screen admin kamu di sini

class AdminMainShell extends StatefulWidget {
  const AdminMainShell({super.key});

  @override
  State<AdminMainShell> createState() => _AdminMainShellState();
}

class _AdminMainShellState extends State<AdminMainShell> {
  // Indeks halaman yang aktif
  int _selectedIndex = 0;

  // Daftar halaman berdasarkan urutan di Navbar
  final List<Widget> _pages = [
    AdminDashboardScreen(), // Ganti dengan AdminHomeScreen()
    const AdminAlatScreen(),
    const AdminAkunScreen(),
    AktivitasScreen(),
    const ProfileScreen(roleLabel: "Admin"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    extendBody: true, // Agar konten body bisa tampil di belakang lengkungan navbar
    body: _pages[_selectedIndex],
    bottomNavigationBar: Container(
      // HAPUS height statis agar tidak ketinggian
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), // Bayangan halus sesuai gambar
            blurRadius: 20,
            offset: const Offset(0, -5), // Bayangan ke arah atas
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF4FA8C5), 
          unselectedItemColor: const Color(0xFFC0C0C0), 
          elevation: 0, // Penting agar tidak ada garis hitam di atas navbar
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: [
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 0 ? Icons.grid_view_rounded : Icons.grid_view_outlined),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 1 ? Icons.inventory_2 : Icons.inventory_2_outlined),
              label: 'Alat',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 2 ? Icons.people_alt : Icons.people_alt_outlined),
              label: 'Akun',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 3 ? Icons.assignment : Icons.assignment_outlined),
              label: 'Aktivitas',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 4 ? Icons.person : Icons.person_outline),
              label: 'Profil',
            ),
          ],
        ),
      ),
    ),
  );
}
}