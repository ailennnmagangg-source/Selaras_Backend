import 'package:flutter/material.dart';
import 'package:selaras_backend/features/peminjam/katalog/logic/alat_model.dart';
import 'package:selaras_backend/features/peminjam/katalog/widgets/alat_card.dart';
import 'package:selaras_backend/features/peminjam/keranjang/peminjaman_form_screen.dart';
// IMPORT DIPERBAIKI: Menghapus 'hide AlatModel' agar tipe datanya sinkron
import 'package:selaras_backend/features/shared/models/alat_model.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  // --- DATA DUMMY UNTUK UI (Pengganti Database) ---
  final List<Map<String, dynamic>> dummyKategori = [
    {'id_kategori': 0, 'nama_kategori': 'Semua'},
    {'id_kategori': 1, 'nama_kategori': 'Elektronik'},
    {'id_kategori': 2, 'nama_kategori': 'Pertukangan'},
    {'id_kategori': 3, 'nama_kategori': 'Kesehatan'},
  ];

  final List<AlatModel> dummyAlat = [
    AlatModel(idAlat: 1, namaAlat: "Kamera DSLR", namaKategori: "Elektronik", stokTotal: 5),
    AlatModel(idAlat: 2, namaAlat: "Bor Listrik", namaKategori: "Pertukangan", stokTotal: 3),
    AlatModel(idAlat: 3, namaAlat: "Laptop ROG", namaKategori: "Elektronik", stokTotal: 2),
    AlatModel(idAlat: 4, namaAlat: "Tensimeter", namaKategori: "Kesehatan", stokTotal: 10),
    AlatModel(idAlat: 5, namaAlat: "Gergaji Mesin", namaKategori: "Pertukangan", stokTotal: 4),
  ];

  // --- STATE UI ---
  List<AlatModel> cart = [];
  int selectedKategoriId = 0;
  String searchQuery = "";

  void _addToCart(AlatModel alat) {
    setState(() {
      cart.add(alat);
    });
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${alat.namaAlat} ditambah ke keranjang"),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 90, left: 20, right: 20), // Agar tidak tertutup floating cart
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logic Filter Data secara lokal (Client-side filtering)
    final filteredData = dummyAlat.where((alat) {
      final matchSearch = alat.namaAlat.toLowerCase().contains(searchQuery.toLowerCase());
      
      // Filter kategori berdasarkan nama kategori di dummyAlat
      final selectedKategori = dummyKategori.firstWhere((k) => k['id_kategori'] == selectedKategoriId);
      final matchKategori = selectedKategoriId == 0 || alat.namaKategori == selectedKategori['nama_kategori'];
      
      return matchSearch && matchKategori;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Katalog Alat",
          style: TextStyle(color: Color(0xFF2D4379), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF5AB9D5)),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(),
              _buildKategoriList(),
              Expanded(
                child: filteredData.isEmpty 
                  ? _buildEmptyState() 
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        return AlatCard(
                          alat: filteredData[index],
                          onAdd: () => _addToCart(filteredData[index]),
                        );
                      },
                    ),
              ),
            ],
          ),
          
          // Floating Cart (Hanya muncul jika ada item)
          if (cart.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildFloatingCartCard(),
            ),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF5AB9D5).withOpacity(0.3)),
        ),
        child: TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: const InputDecoration(
            hintText: "Cari alat praktikum...",
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Color(0xFF5AB9D5)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildKategoriList() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dummyKategori.length,
        itemBuilder: (context, index) {
          final item = dummyKategori[index];
          bool isSelected = selectedKategoriId == item['id_kategori'];

          return GestureDetector(
            onTap: () => setState(() => selectedKategoriId = item['id_kategori']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5AB9D5) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? const Color(0xFF5AB9D5) : Colors.grey.shade300,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF5AB9D5).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Text(
                item['nama_kategori'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 10),
          const Text(
            "Alat tidak ditemukan", 
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCartCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => PeminjamanFormScreen(selectedItems: cart),
          ),
        );
      },
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), 
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Row(
          children: [
            Badge(
              label: Text("${cart.length}"),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF5AB9D5), 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_basket_outlined, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Keranjang Peminjaman", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    "Ketuk untuk isi formulir", 
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF5AB9D5), size: 18),
          ],
        ),
      ),
    );
  }
}