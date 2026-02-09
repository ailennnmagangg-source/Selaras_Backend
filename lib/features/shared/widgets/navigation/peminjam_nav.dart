// peminjam_nav.dart
import 'package:flutter/material.dart';
import 'package:selaras_backend/features/peminjam/katalog/ui/katalog_screen.dart';
import 'package:selaras_backend/features/peminjam/riwayat_saya/peminjam_riwayat_screen.dart';
import 'package:selaras_backend/features/shared/widgets/profile_screen.dart';

class PeminjamNav extends StatefulWidget {
  const PeminjamNav({super.key});

  @override
  State<PeminjamNav> createState() => _PeminjamNavState();
}

class _PeminjamNavState extends State<PeminjamNav> {
  int _selectedIndex = 0;

  // Pastikan class ini sudah di-import dengan benar
  final List<Widget> _pages = [
    const KatalogScreen(),
    const PeminjamRiwayatScreen(),
    const ProfileScreen(roleLabel: "Peminjam")
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hapus extendBody: true jika navbar tertutup
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        // Gunakan margin atau padding jika perlu memastikan posisi
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
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
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded),
                label: 'Alat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_rounded),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}