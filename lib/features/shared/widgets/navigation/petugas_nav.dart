import 'package:flutter/material.dart';
import 'package:selaras_backend/features/petugas/dashboard/ui/petugas_home_screen.dart';
import 'package:selaras_backend/features/petugas/laporan/ui/petugas_laporan_screen.dart';
import 'package:selaras_backend/features/petugas/pengembalian/ui/petugas_pengembalian_screen.dart';
import 'package:selaras_backend/features/petugas/persetujuan/ui/petugas_persetujuan_screen.dart';
import 'package:selaras_backend/features/shared/widgets/profile_screen.dart';

class PetugasNav extends StatefulWidget {
  const PetugasNav({super.key});

  @override
  State<PetugasNav> createState() => _PetugasNavState();
}

class _PetugasNavState extends State<PetugasNav> {
  int _selectedIndex = 0;

  // Daftar halaman berdasarkan urutan di Navbar Petugas
  final List<Widget> _pages = [
    const PetugasHomeScreen(),
    const PetugasPersetujuanScreen(),
    const PetugasPengembalianScreen(),
    const PetugasLaporanScreen(),
    const ProfileScreen(roleLabel: "Petugas"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -5),
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
            selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            items: [
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 0 ? Icons.grid_view_rounded : Icons.grid_view_outlined),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 1 ? Icons.assignment_turned_in : Icons.assignment_turned_in_outlined),
                label: 'Persetujuan',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 2 ? Icons.cached_rounded : Icons.cached_outlined),
                label: 'Pengembalian',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 3 ? Icons.assignment_rounded : Icons.assignment_outlined),
                label: 'Laporan',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 4 ? Icons.person_rounded : Icons.person_outline),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}