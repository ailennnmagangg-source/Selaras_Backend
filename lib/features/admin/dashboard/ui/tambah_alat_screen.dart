import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selaras_backend/features/admin/management_alat/logic/alat_controller.dart';

class TambahAlatScreen extends StatefulWidget {
  const TambahAlatScreen({super.key});

  @override
  State<TambahAlatScreen> createState() => _TambahAlatScreenState();
}


class _TambahAlatScreenState extends State<TambahAlatScreen> {
  // GUNAKAN SATU VARIABEL SAJA AGAR KONSISTEN
  XFile? _pickedImage; 

  final _controller = AlatController();
  final _namaController = TextEditingController();
  final _stokController = TextEditingController();
  
  int? _selectedKategoriId;
  List<Map<String, dynamic>> _kategoriList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  void _loadKategori() async {
    final data = await _controller.fetchKategori();
    setState(() => _kategoriList = data);
  }
  

  // FUNGSI PICK IMAGE
  Future<void> _pickImage() async {
    debugPrint("Mencoba membuka galeri..."); // Untuk cek di console
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
        debugPrint("Gambar berhasil dipilih: ${image.path}");
      }
    } catch (e) {
      debugPrint("Gagal membuka galeri: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Izin galeri ditolak atau error: $e")),
      );
    }
  }

  void _simpanAlat() async {
    // Validasi menggunakan _pickedImage
    if (_pickedImage == null || _selectedKategoriId == null || _namaController.text.isEmpty || _stokController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua data dan foto!")),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await _controller.tambahAlat(
        nama: _namaController.text,
        idKategori: _selectedKategoriId!,
        stok: int.parse(_stokController.text),
        imageFile: _pickedImage!, // Kirim XFile
      );
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data alat berhasil disimpan!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.cyan.withOpacity(0.3), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyan, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Tambah Alat", 
          style: TextStyle(color: Color(0xFF2D4379), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.cyan, size: 20), 
          onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        // Tambahkan behavior pada ScrollView agar tidak memakan event klik
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // BOX UPLOAD FILE
            Center(
              child: InkWell( // Menggunakan InkWell agar ada efek klik (feedback visual)
                onTap: () {
                   debugPrint("Kotak Upload diklik");
                   _pickImage();
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 140, 
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E4E9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _pickedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.upload_rounded, color: Color(0xFF3D7E91), size: 40),
                            SizedBox(height: 5),
                            Text("Upload File", 
                              style: TextStyle(color: Color(0xFF3D7E91), fontWeight: FontWeight.bold)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: kIsWeb 
                              ? Image.network(_pickedImage!.path, fit: BoxFit.cover) 
                              : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            _buildLabel("Nama Alat"),
            TextField(
              controller: _namaController, 
              decoration: _buildInputDecoration("Masukkan nama alat")
            ),
            
            const SizedBox(height: 20),

            _buildLabel("Kategori"),
            DropdownButtonFormField<int>(
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.cyan, size: 30),
              decoration: _buildInputDecoration("Masukkan kategori"),
              dropdownColor: Colors.white,
              elevation: 8, // Memberikan bayangan seperti di gambar referensi
              borderRadius: BorderRadius.circular(12), // Border melengkung pada menu pop-up
              items: _kategoriList.map((kat) {
                return DropdownMenuItem<int>(
                  value: kat['id_kategori'],
                  child: Text(kat['nama_kategori'], style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedKategoriId = val),
            ),

            const SizedBox(height: 20),

            _buildLabel("Stok"),
            TextField(
              controller: _stokController, 
              keyboardType: TextInputType.number, 
              decoration: _buildInputDecoration("Masukkan stok produk")
            ),

            const SizedBox(height: 60),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanAlat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32B0C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Simpan", 
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, 
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D4379), fontSize: 14)),
    );
  }
}