import 'package:flutter/material.dart';
import 'package:selaras_backend/features/admin/dashboard/alat/widgets/alat_card_widget.dart';
import 'package:selaras_backend/features/admin/management_alat/logic/alat_controller.dart';
import 'package:selaras_backend/features/shared/widgets/navigation/admin_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import 'edit_alat_screen.dart';
import 'tambah_alat_screen.dart';
import 'tambah_kategori_screen.dart';

class AdminAlatScreen extends StatefulWidget {
  const AdminAlatScreen({super.key});

  @override
  State<AdminAlatScreen> createState() => _AdminAlatScreenState();
}

class _AdminAlatScreenState extends State<AdminAlatScreen> {
  final AlatController _controller = AlatController();
  final supabase = Supabase.instance.client;
  
  String selectedKategori = "Semua";
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // 1. Tambahkan PopScope untuk menangani tombol back fisik HP
    return PopScope(
      canPop: false, // Mencegah aksi back standar
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Paksa kembali ke Shell Utama agar Navbar tetap ada
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminMainShell()),
        );
      },
    child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
           // --- HEADER DENGAN TOMBOL KEMBALI ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlue),
                      onPressed: () {
                        // 2. Arahkan ke AdminMainShell (bukan AdminHomeScreen langsung)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminMainShell()),
                        );
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "Manajemen Alat", 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold, 
                          color: AppColors.textPrimary
                        )
                      ),
                    ),
                    const SizedBox(width: 48), // Penyeimbang agar teks tetap di tengah
                  ],
                ),
              ),
            _buildSearchBar(),
            _buildCategorySection(),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                // Refresh data otomatis saat state berubah
                future: _controller.fetchAlat(query: searchQuery, kategori: selectedKategori),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Alat tidak ditemukan"));
                  }

                  final listAlat = snapshot.data!;

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72, // Sedikit lebih panjang untuk menampung ikon di bawah
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: listAlat.length,
                    itemBuilder: (context, index) {
                      final item = listAlat[index];
                      return AlatCardWidget(
                        data: item,
                        onEdit: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditAlatScreen(alatData: item)),
                          );
                          // Jika edit sukses, refresh list
                          if (result == true) setState(() {});
                        },
                        onDelete: () => _showDeleteDialog(item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      //TOMBOL TAMBAH ALAT
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0, right: 10.0), // Menghindari tabrakan dengan Navbar
        child: FloatingActionButton(
          onPressed: () async {
            final refresh = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TambahAlatScreen()),
            );
            // Melakukan refresh daftar alat jika ada data baru yang ditambah
            if (refresh == true) {
              setState(() {});
            }
          },
          backgroundColor: AppColors.primaryBlue,
          shape: const CircleBorder(), // Menambahkan bentuk bulat sesuai keinginanmu
          elevation: 4, // Memberikan sedikit bayangan agar terlihat melayang
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      )
    ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          // TAMBAHKAN LINE DI BAWAH INI
          border: Border.all(color: AppColors.primaryBlue, width: 1.5), 
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.05), 
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: const InputDecoration(
            hintText: "Cari alat...",
            prefixIcon: Icon(Icons.search, color: Color(0xFF4FA8C5)), // Ikon juga jadi biru agar serasi
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 10),
          child: Text("Kategori", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase.from('kategori').stream(primaryKey: ['id_kategori']).order('nama_kategori'),
          builder: (context, snapshot) {
            final categoriesFromDb = snapshot.data ?? [];
            List<String> displayCategories = ["Semua", ...categoriesFromDb.map((e) => e['nama_kategori'].toString())];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Tombol Tambah Kategori
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahKategoriPage())),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Desain Kategori Kotak (Gambar 1)
                  ...displayCategories.map((kat) {
                    bool isSelected = selectedKategori == kat;
                    return GestureDetector(
                      onTap: () => setState(() => selectedKategori = kat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryBlue : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (isSelected && kat == "Semua") 
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(Icons.check, color: Colors.white, size: 16),
                              ),
                            Text(
                              kat,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _showDeleteDialog(Map<String, dynamic> alat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Hapus Alat"),
        content: Text("Yakin ingin menghapus ${alat['nama_alat']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _controller.deleteAlat(alat['id_alat']);
              setState(() {}); // Refresh UI setelah hapus
            }, 
            child: const Text("Hapus", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }
}