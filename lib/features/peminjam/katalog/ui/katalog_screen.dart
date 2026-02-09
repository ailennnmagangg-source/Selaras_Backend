import 'package:flutter/material.dart';
import 'package:selaras_backend/features/peminjam/katalog/widgets/alat_card.dart';
import 'package:selaras_backend/features/peminjam/keranjang/peminjaman_form_screen.dart';
import 'package:selaras_backend/features/shared/models/alat_model.dart'; // Pastikan import ini benar
import '../../../../core/constants/app_colors.dart';
import '../logic/katalog_controller.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  final KatalogController _controller = KatalogController();
  Map<int, String> kategoriMap = {};

  Future<void> _loadKategori() async {
  final data = await _controller.fetchKategori();

  setState(() {
    kategoriMap = {
      for (var item in data)
        item['id_kategori']: item['nama_kategori']
    };
  });
}

  
  List<AlatModel> cart = [];
  int selectedKategoriId = 0;
  String searchQuery = "";
  late Future<List<Map<String, dynamic>>> _kategoriFuture;

  @override
  void initState() {
    super.initState();
    _loadKategori();
    _kategoriFuture = _controller.fetchKategori();
  }

  void _addToCart(AlatModel alat) {
    // Validasi Stok Real-time dari Database
    if (alat.stokTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Maaf, stok ${alat.namaAlat} sedang kosong"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      cart.add(alat);
    });
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${alat.namaAlat} ditambah ke keranjang"),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Katalog Alat",
          style: TextStyle(
            color: Color(0xFF1A4D7C), 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
              _buildDynamicKategori(),
              Expanded(
                child: FutureBuilder<List<AlatModel>>(
                  // Menarik data alat berdasarkan kategori yang dipilih
                  future: _controller.fetchAlat(idKategori: selectedKategoriId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF5AB9D5)));
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
                    }

                    final allAlat = snapshot.data ?? [];
                    // Filtering client-side untuk pencarian nama
                    final filteredData = allAlat.where((alat) {
                      return alat.namaAlat.toLowerCase().contains(searchQuery.toLowerCase());
                    }).toList();

                    if (filteredData.isEmpty) {
                      return _buildEmptyState();
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final alat = filteredData[index];

                        return AlatCard(
                          alat: alat,
                          namaKategori: kategoriMap[alat.idKategori] ?? "Tidak diketahui",
                          onAdd: () => _addToCart(alat),
                        );
                      },

                    );
                  },
                ),
              ),
            ],
          ),
          
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF5AB9D5).withOpacity(0.5)),
        ),
        child: TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: const InputDecoration(
            hintText: "Cari produk disini...",
            prefixIcon: Icon(Icons.search, color: Color(0xFF5AB9D5)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicKategori() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _kategoriFuture,
      builder: (context, snapshot) {
        List<Map<String, dynamic>> kategoriList = [
          {'id_kategori': 0, 'nama_kategori': 'Semua'}
        ];
        if (snapshot.hasData) {
          kategoriList.addAll(snapshot.data!);
        }

        return SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kategoriList.length,
            itemBuilder: (context, index) {
              final item = kategoriList[index];
              int id = item['id_kategori'];
              bool isSelected = selectedKategoriId == id;

              return GestureDetector(
                onTap: () => setState(() => selectedKategoriId = id),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF5AB9D5) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isSelected ? const Color(0xFF5AB9D5) : Colors.grey.shade300),
                  ),
                  child: Text(
                    item['nama_kategori'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFloatingCartCard() {
    return Hero(
      tag: 'cart_floating',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => PeminjamanFormScreen(selectedItems: cart)
              )
            );
          },
          child: Container(
            height: 65,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                Badge(
                  label: Text("${cart.length}"),
                  child: Icon(Icons.shopping_basket_outlined, color: Color(0xFF5AB9D5), size: 30),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Keranjang Peminjaman", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Lanjutkan ke formulir", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF5AB9D5), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          Text("Alat tidak ditemukan", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}