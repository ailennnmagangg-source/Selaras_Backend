import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahKategoriPage extends StatefulWidget {
  const TambahKategoriPage({super.key});

  @override
  State<TambahKategoriPage> createState() => _TambahKategoriPageState();
}

class _TambahKategoriPageState extends State<TambahKategoriPage> {
  // 1. Definisikan Controller di dalam State
  final TextEditingController _kategoriController = TextEditingController();
  final supabase = Supabase.instance.client;

  // 2. Fungsi Tambah Kategori ke Supabase
  Future<void> _tambahKategori() async {
  final String namaKategori = _kategoriController.text.trim();
  if (namaKategori.isEmpty) return;

  try {
    // 1. Tambah ke tabel kategori
    await supabase.from('kategori').insert({
      'nama_kategori': namaKategori,
    });

    // 2. Tambah ke log_aktivitas (Tanpa kolom keterangan sesuai tabel Anda)
    await supabase.from('log_aktivitas').insert({
      'aksi': 'Tambah Kategori',
      // Kolom 'keterangan' dihapus agar tidak error
      'petugas_id': supabase.auth.currentUser?.id, 
    });

    _kategoriController.clear();
    if (mounted) Navigator.pop(context); // Tutup dialog setelah berhasil

  } catch (e) {
    debugPrint("Error: $e");
    // Tampilkan pesan error jika masih ada masalah skema database
  }
}

 // pop up tambah kategori
  void _showTambahDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Tambah Kategori",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Nama Kategori",
                style: TextStyle(
                  fontSize: 14, 
                  color: AppColors.textPrimary, 
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _kategoriController, // Menghubungkan controller
                decoration: InputDecoration(
                  hintText: "Masukkan nama kategori baru...",
                  hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          _kategoriController.clear();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _tambahKategori, // Panggil fungsi Supabase
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          "Iya",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //POP UP EDIT KATEGORI
  // Tambahkan Fungsi Update ini di dalam State
    Future<void> _updateKategori(int id, String namaLama) async {
      final String namaBaru = _kategoriController.text.trim();
      
      // Validasi jika kosong atau tidak ada perubahan
      if (namaBaru.isEmpty || namaBaru == namaLama) {
        Navigator.pop(context);
        return;
      }

      try {
        // 1. Update data di tabel kategori
        await supabase.from('kategori').update({
          'nama_kategori': namaBaru,
        }).match({'id_kategori': id});

        // 2. Tambahkan log aktivitas
        await supabase.from('log_aktivitas').insert({
          'aksi': 'Edit Kategori',
          'petugas_id': supabase.auth.currentUser?.id,
        });

        _kategoriController.clear();
        if (mounted) Navigator.pop(context);
        
      } catch (e) {
        debugPrint("Error Update: $e");
      }
    }
    // UI EDIT
    void _showEditDialog(int idKategori, String namaLama) {
      // Set teks di TextField agar muncul nama kategori yang ingin diedit
      _kategoriController.text = namaLama;

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul berubah menjadi "Edit Kategori"
                const Center(
                  child: Text(
                    "Edit Kategori", 
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Nama Kategori",
                  style: TextStyle(
                    fontSize: 14, 
                    color: AppColors.textPrimary, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _kategoriController,
                  decoration: InputDecoration(
                    hintText: "Ubah nama kategori...", // Hint disesuaikan
                    hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            _kategoriController.clear(); // Bersihkan controller saat batal
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5F5F5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          // Memanggil fungsi Update Supabase
                          onPressed: () => _updateKategori(idKategori, namaLama), 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            "Iya",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // POP HAPUS
    Future<void> _hapusKategori(int id) async {
    try {
      // 1. Hapus data di tabel kategori berdasarkan ID
      await supabase.from('kategori').delete().match({'id_kategori': id});

      // 2. Tambah ke log_aktivitas (Tanpa kolom keterangan sesuai tabel Anda)
      await supabase.from('log_aktivitas').insert({
        'aksi': 'Hapus Kategori ID: $id',
        'petugas_id': supabase.auth.currentUser?.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kategori berhasil dihapus"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error Hapus: $e");
    }
  }

  void _showHapusDialog(int id, String nama) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                "Hapus",
                style: TextStyle(
                  color: Colors.red, // Warna merah sesuai gambar
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              "Apakah anda yakin menghapus kategori '$nama'? Jika dihapus, maka alat dengan kategori ini akan ikut ke hapus.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _hapusKategori(id); // Panggil fungsi hapus
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "Iya",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
    

    

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background, // Warna latar belakang sesuai gambar 1
    appBar: AppBar(
      centerTitle: true,
      title: const Text(
        "Tambah Kategori",
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryBlue, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Memastikan semua isi Column rata kiri
      children: [
        // Teks Kategori di atas Card
        const Padding(
          padding: EdgeInsets.fromLTRB(25, 20, 25, 10), // Jarak kiri 25 agar sejajar dengan card
          child: Text(
            "Kategori",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary, // Menggunakan warna biru sesuai tema
            ),
          ),
        ),
        
        // List Kategori dari Supabase
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('kategori').stream(primaryKey: ['id_kategori']).order('nama_kategori'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final kategoriList = snapshot.data ?? [];
              
              if (kategoriList.isEmpty) {
                return const Center(child: Text("Belum ada kategori"));
              }
              //card kategori
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: kategoriList.length,
                itemBuilder: (context, index) {
                  final item = kategoriList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1) , // Biru muda transparan sesuai gambar 1
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: ListTile(
                      title: Text(
                        item['nama_kategori'],
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Di bagian trailing ListTile
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _showEditDialog(
                              item['id_kategori'], // Ambil ID untuk filter update
                              item['nama_kategori'] // Kirim nama lama agar muncul di TextField
                            ),
                            icon: Icon(Icons.edit, color: AppColors.primaryBlue.withOpacity(0.6), size: 18),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              // Memanggil dialog hapus dengan mengirim ID dan Nama Kategori
                              _showHapusDialog(item['id_kategori'], item['nama_kategori']);
                            },
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
    // FloatingActionButton yang sudah dinaikkan posisinya
    floatingActionButton: Padding(
      padding: const EdgeInsets.only(bottom: 80, right: 10),
      child: FloatingActionButton(
        onPressed: _showTambahDialog,
        backgroundColor: AppColors.primaryBlue,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    ),
  );
}
}