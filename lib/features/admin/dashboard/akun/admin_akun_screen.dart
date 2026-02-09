import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import 'package:selaras_backend/features/admin/dashboard/akun/tambah_peminjam_screen.dart';
import 'package:selaras_backend/features/admin/dashboard/alat/widgets/user_list_widget.dart';
import 'package:selaras_backend/features/shared/widgets/navigation/admin_nav.dart';
import 'tambah_staff_screen.dart';

class AdminAkunScreen extends StatefulWidget {
  const AdminAkunScreen({super.key});

  @override
  State<AdminAkunScreen> createState() => _AdminAkunScreenState();
}

class _AdminAkunScreenState extends State<AdminAkunScreen> {
  // Variabel penampung teks pencarian
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminMainShell()),
        );
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlue),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminMainShell()),
                );
              },
            ),
            centerTitle: true,
            title: const Text(
              "Daftar Akun Pengguna",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false,
            // --- PERBAIKAN STRUKTUR BOTTOM APPBAR ---
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(115), // Sedikit lebih tinggi agar bayangan tidak terpotong
              child: Column(
                children: [
                  // UI SEARCH BAR PREMIUM VERSION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30), // Membuat bentuk stadium/bulat sempurna
                        border: Border.all(color: AppColors.primaryBlue, width: 1.5), // Border biru tegas
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "Cari nama pengguna...",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: AppColors.primaryBlue),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  // TabBar diletakkan di dalam Column yang sama
                  const TabBar(
                    labelColor: AppColors.primaryBlue,
                    unselectedLabelColor: AppColors.textPlaceholder,
                    indicatorColor: AppColors.primaryBlue,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                    tabs: [
                      Tab(text: "Manajemen Staf"),
                      Tab(text: "Manajemen Peminjam"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              // Jangan lupa teruskan searchQuery ke widget list
              UserListWidget(
                filterRole: const ['admin', 'petugas'],
                query: searchQuery,
              ),
              UserListWidget(
                filterRole: const ['peminjam'],
                query: searchQuery,
              ),
            ],
          ),
          floatingActionButton: Builder(builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 80.0, right: 10.0),
              child: FloatingActionButton(
                onPressed: () async {
                  final currentTab = DefaultTabController.of(context).index;

                  Widget screen = currentTab == 0
                      ? const TambahStafScreen()
                      : const TambahPeminjamScreen();

                  final shouldRefresh = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => screen),
                  );

                  if (shouldRefresh == true) {
                    setState(() {});
                  }
                },
                backgroundColor: AppColors.primaryBlue,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            );
          }),
        ),
      ),
    );
  }
}