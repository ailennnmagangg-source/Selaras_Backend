import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import 'package:selaras_backend/features/admin/management_alat/logic/alat_controller.dart';

class TambahAlatScreen extends StatefulWidget {
  const TambahAlatScreen({super.key});

  @override
  State<TambahAlatScreen> createState() => _TambahAlatScreenState();
}

class _TambahAlatScreenState extends State<TambahAlatScreen> {
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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() => _pickedImage = image);
      }
    } catch (e) {
      debugPrint("Gagal membuka galeri: $e");
    }
  }

  // MODIFIKASI: Border lebih halus sesuai Gambar 3
  InputDecoration _buildInputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      // Border saat diam (lebih tipis dan abu-abu kebiruan)
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue.withOpacity(0.1), width: 1),
      ),
      // Border saat diklik (Cyan sesuai tema)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF32B0C7), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Tambah Alat", 
          style: TextStyle(color: Color(0xFF2D4379), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF32B0C7), size: 20), 
          onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // BOX UPLOAD FILE (Gambar 3)
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2F6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _pickedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.upload_rounded, color: Color(0xFF3D7E91), size: 35),
                            SizedBox(height: 8),
                            Text("Upload File", 
                              style: TextStyle(color: Color(0xFF3D7E91), fontWeight: FontWeight.w600, fontSize: 12)),
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
            // DROPDOWN DENGAN STYLE SESUAI GAMBAR (Elevation & Menu Padding)
            DropdownButtonFormField<int>(
              value: _selectedKategoriId,
              icon: const Icon(Icons.arrow_drop_up_rounded, color: Color(0xFF32B0C7), size: 30),
              decoration: _buildInputDecoration("Masukkan kategori"),
              dropdownColor: Colors.white,
              // MODIFIKASI: Sudut menu yang melengkung & Bayangan (Gambar 3 Kiri)
              borderRadius: BorderRadius.circular(15),
              elevation: 4,
              hint: Text("Masukkan kategori", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              items: _kategoriList.map((kat) {
                return DropdownMenuItem<int>(
                  value: kat['id_kategori'],
                  child: Text(kat['nama_kategori'], 
                    style: const TextStyle(fontSize: 14, color: Color(0xFF2D4379))),
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

            // TOMBOL SIMPAN (Gambar 3)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanAlat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32B0C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, 
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D4379), fontSize: 14)),
    );
  }

  void _simpanAlat() async {
    if (_pickedImage == null || _selectedKategoriId == null || _namaController.text.isEmpty || _stokController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap lengkapi semua data!")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _controller.tambahAlat(
        nama: _namaController.text,
        idKategori: _selectedKategoriId!,
        stok: int.parse(_stokController.text),
        imageFile: _pickedImage!,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}