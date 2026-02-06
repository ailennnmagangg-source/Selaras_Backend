import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/aktivitas/admin_aktivitas_screen.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/akun/admin_akun_screen.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/alat/admin_alat_screen.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/admin_home_screen.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/admin_profile_screen.dart';
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
    const AdminHomeScreen(), // Ganti dengan AdminHomeScreen()
    const AdminAlatScreen(),
    const AdminAkunScreen(),
    const AdminAktivitasScreen(),
    const AdminProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Menampilkan halaman sesuai indeks
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // Penting agar lebih dari 3 menu tidak bergeser
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.primaryBlue, // Warna biru saat diklik
            unselectedItemColor: AppColors.textSecondary, // Warna abu-abu saat tidak aktif
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
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