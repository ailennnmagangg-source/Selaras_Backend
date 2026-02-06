import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAlatScreen extends StatefulWidget {
  final Map<String, dynamic> alatData;
  const EditAlatScreen({super.key, required this.alatData});

  @override
  State<EditAlatScreen> createState() => _EditAlatScreenState();
}

class _EditAlatScreenState extends State<EditAlatScreen> {
  // 1. Deklarasi Controller & Variabel
  late TextEditingController _namaController;
  late TextEditingController _stokController;

  File? _selectedImage; 
  final ImagePicker _picker = ImagePicker();
  
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data awal
    _namaController = TextEditingController(text: widget.alatData['nama_alat']);
    _stokController = TextEditingController(text: widget.alatData['stok_total'].toString());
    _selectedCategoryId = widget.alatData['id_kategori']?.toString();
    _imageUrl = widget.alatData['foto_url'];
    
    // Ambil daftar kategori dari database
    _fetchCategories();
  }

  // Ambil data kategori untuk Dropdown
  Future<void> _fetchCategories() async {
    try {
      final data = await Supabase.instance.client.from('kategori').select();
      setState(() {
        _categories = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint("Error kategori: $e");
    }
  }

  // Update data ke Supabase
  Future<void> _updateData() async {
    // 1. Validasi input (opsional tapi disarankan)
    if (_namaController.text.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan Kategori tidak boleh kosong")),
      );
      return;
    }

    setState(() => _isLoading = true); // Tampilkan loading

    try {
      // --- DI SINI TEMPAT KODE TERSEBUT ---
      await Supabase.instance.client
          .from('alat')
          .update({
            'nama_alat': _namaController.text,
            'stok_total': int.parse(_stokController.text),
            'id_kategori': int.parse(_selectedCategoryId!),
            'foto_url': _imageUrl, 
          })
          .eq('id_alat', widget.alatData['id_alat']);
      // ------------------------------------

      if (mounted) {
        // Kembali ke halaman sebelumnya dan beri tahu bahwa data berhasil diupdate
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui!")),
        );
      }
    } catch (e) {
      // Tangani jika terjadi error (misal: koneksi terputus)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false); // Matikan loading
    }
  }

  //Fungsi Pilih & Unggah Gambar
  Future<void> _pickAndUploadImage() async {
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    setState(() => _isLoading = true);
    
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final path = 'foto_alat/$fileName';
      
      // Ambil bytes gambar (Cara ini bekerja di Web & Mobile)
      final Uint8List fileBytes = await pickedFile.readAsBytes();

      // 1. Upload ke Supabase Storage menggunakan bytes
      await Supabase.instance.client.storage
          .from('foto_alat') 
          .uploadBinary(path, fileBytes); // Gunakan uploadBinary untuk Web compatibility

      // 2. Ambil URL Publik
      final String publicUrl = Supabase.instance.client.storage
          .from('foto_alat')
          .getPublicUrl(path);

      // 3. Update UI
      setState(() {
        _imageUrl = publicUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gambar berhasil diganti!")),
      );
    } catch (e) {
      print("Error detail: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal unggah: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  void dispose() {
    _namaController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Edit Produk", style: TextStyle(color: Color(0xFF1E3A8A))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.cyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Gambar Produk
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
  
                    child: ClipRRect(
                        // 2. TAMBAHKAN ClipRRect agar gambar yang "cover" tetap melengkung di pojok
                        borderRadius: BorderRadius.circular(20),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover) // 3. Ganti ke BoxFit.cover
                            : (_imageUrl != null
                                ? Image.network(
                                    _imageUrl!, 
                                    fit: BoxFit.cover, // 3. Ganti ke BoxFit.cover
                                    key: ValueKey(_imageUrl),
                                  ) 
                                : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                      ),
  
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.cyan,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                        onPressed: _pickAndUploadImage, // Panggil fungsi pilih gambar
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Form Nama Produk
            _buildLabel("Nama Produk"),
            _buildTextField(_namaController, "Masukkan nama produk"),
            const SizedBox(height: 20),

            // Form Kategori (Dropdown)
            _buildLabel("Kategori"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategoryId,
                  isExpanded: true,
                  hint: const Text("Pilih Kategori"),
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['id_kategori'].toString(),
                      child: Text(cat['nama_kategori']),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form Stok
            _buildLabel("Stok"),
            _buildTextField(_stokController, "0", isNumber: true),
            const SizedBox(height: 40),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _updateData,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.cyan, width: 1.5),
        ),
      ),
    );
  }
}