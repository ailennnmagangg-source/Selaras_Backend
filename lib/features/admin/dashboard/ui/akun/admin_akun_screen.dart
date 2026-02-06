import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/akun/tambah_peminjam_screen.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/widgets/user_list_widget.dart';


import 'tambah_staff_screen.dart';

class AdminAkunScreen extends StatefulWidget {
  const AdminAkunScreen({super.key});

  @override
  State<AdminAkunScreen> createState() => _AdminAkunScreenState();
}

class _AdminAkunScreenState extends State<AdminAkunScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Dua tab: Staf dan Peminjam
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "Daftar Akun Pengguna",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),

          automaticallyImplyLeading: false, //panah
          elevation: 0, // Menghilangkan garis bawah appBar agar menyatu dengan background
          bottom: const TabBar(
            // Warna teks/icon saat Tab dipilih (Aktif)
            labelColor: AppColors.primaryBlue,

            // Warna teks/icon saat Tab TIDAK dipilih
            unselectedLabelColor: AppColors.textPlaceholder,

            // Warna garis bawah (indicator) saat aktif
            indicatorColor: AppColors.primaryBlue,

            // Ketebalan garis indikator (opsional agar lebih mirip gambar)
            indicatorWeight: 3,

            // --- TAMBAHKAN INI UNTUK TEKS TEBAL ---
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, // Teks jadi tebal saat aktif
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal, // Teks biasa saat tidak aktif
              fontSize: 14,
            ),

            tabs: [
              Tab(text: "Manajemen Staf"),
              Tab(text: "Manajemen Peminjam"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Menampilkan Admin & Petugas
            UserListWidget(filterRole: ['admin', 'petugas']),
            // Tab 2: Menampilkan Peminjam (Siswa & Guru)
            UserListWidget(filterRole: ['peminjam']),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 80.0, right: 10.0),
              child: FloatingActionButton(
                onPressed: () async {
                  // Mengambil index tab yang sedang aktif (0 untuk Staf, 1 untuk Peminjam)
                  final currentTab = DefaultTabController.of(context).index;
                  
                  dynamic screen;
                  if (currentTab == 0) {
                    screen = const TambahStafScreen();
                  } else {
                    screen = const TambahPeminjamScreen();
                  }

                  // Tunggu hasil (true) dari halaman tambah
                  final shouldRefresh = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => screen),
                  );

                  // Jika kembali membawa 'true', jalankan setState
                  if (shouldRefresh == true) {
                    setState(() {
                      // Kosong tidak apa-apa, ini memicu build ulang
                    });
                  }
                },
                backgroundColor: AppColors.primaryBlue,
                shape: CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 30,),
              ),
            );
          }
        ),
      ),
    );
  }
}