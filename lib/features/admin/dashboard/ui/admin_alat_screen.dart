import 'package:flutter/material.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/tambah_alat_screen.dart';
import 'package:selaras_backend/features/admin/management_alat/logic/alat_controller.dart';
import 'package:selaras_backend/features/shared/models/alat_model.dart';
import '../../../../core/constants/app_colors.dart';

class AdminAlatScreen extends StatefulWidget {
  const AdminAlatScreen({super.key});

  @override
  State<AdminAlatScreen> createState() => _AdminAlatScreenState();
}

class _AdminAlatScreenState extends State<AdminAlatScreen> {
  final AlatController _controller = AlatController();
  String selectedKategori = "Semua";
  String searchQuery = "";

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Alat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            
            // 1. Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: "Cari produk disini",
                    hintStyle: TextStyle(fontSize: 14, color: AppColors.textPlaceholder),
                    prefixIcon: Icon(Icons.search, color: AppColors.textPlaceholder),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // 2. Kategori Section
            _buildCategorySection(),

            // 3. Grid Alat (Data Asli)
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>( // Ubah jadi Map
                future: _controller.fetchAlat(query: searchQuery),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: listAlat.length,
                    itemBuilder: (context, index) {
                      // Kirim data Map ke fungsi build card
                      return _buildAlatCard(listAlat[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
       onPressed: () async {
          final refresh = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const TambahAlatScreen())
          );
          if (refresh == true) setState(() {}); // Refresh data kalau sukses tambah
        },
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
    );
  }

  Widget _buildCategorySection() {
    final listKategori = ["Semua", "Alat Potong", "Alat Tukar", "Elektronik"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text("Kategori", style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {}, // Tambah Kategori Baru
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              ...listKategori.map((kat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(kat),
                  selected: selectedKategori == kat,
                  onSelected: (s) => setState(() => selectedKategori = kat),
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: TextStyle(color: selectedKategori == kat ? Colors.white : AppColors.textSecondary, fontSize: 12),
                  backgroundColor: Colors.grey[100],
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              )).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlatCard(Map<String, dynamic> data) {
  final String namaKategori = data['kategori'] != null 
      ? data['kategori']['nama_kategori'] 
      : 'Tanpa Kategori';
      
  final String? fotoUrl = data['foto_url'];

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05), 
          blurRadius: 15,
          offset: const Offset(0, 5),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BAGIAN GAMBAR (DIPERBAIKI)
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                // Melengkung hanya di bagian atas saja
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  // Tambahkan timestamp agar gambar selalu fresh
                  "${fotoUrl ?? 'https://via.placeholder.com/150'}?t=${DateTime.now().millisecondsSinceEpoch}", 
                  width: double.infinity, 
                  height: double.infinity,
                  fit: BoxFit.cover, // Memastikan gambar memenuhi kotak tanpa gepeng
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              // IKON EDIT & HAPUS
              Positioned(
                bottom: 8,
                right: 8,
                child: Row(
                  children: [
                    _buildSmallActionIcon(Icons.edit, Colors.cyan, () {
                      // Logika Edit
                    }),
                    const SizedBox(width: 8),
                    _buildSmallActionIcon(Icons.delete, Colors.red, () {
                      _showDeleteDialog(data);
                    }),
                  ],
                ),
              )
            ],
          ),
        ),
        
        // BAGIAN TEKS DETAIL
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['nama_alat'] ?? '-', 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2D4379)),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(namaKategori, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  Text(
                    "Stok ${data['stok_total']}", 
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    ),
  );
}

// Helper untuk Ikon Aksi agar kode lebih bersih
Widget _buildSmallActionIcon(IconData icon, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Icon(icon, size: 18, color: color),
  );
}

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), 
          border: Border.all(color: color.withOpacity(0.2))),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> alat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Hapus",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 15),
            // MODIFIKASI DI SINI:
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                children: [
                  const TextSpan(text: "Apakah anda yakin menghapus "),
                  TextSpan(
                    text: "${alat['nama_alat']}?", // Memanggil nama alat secara dinamis
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.cyan,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _controller.deleteAlat(alat['id_alat']); 
                      if (mounted) {
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${alat['nama_alat']} berhasil dihapus")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DB6D1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Iya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}