import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import 'package:selaras_backend/features/shared/models/user_model.dart';
import '../../management_alat/logic/user_controller.dart';

class EditPeminjamScreen extends StatefulWidget {
  final UserModel user; // Menerima data user dari halaman list
  const EditPeminjamScreen({super.key, required this.user});

  @override
  State<EditPeminjamScreen> createState() => _EditPeminjamScreenState();
}

class _EditPeminjamScreenState extends State<EditPeminjamScreen> {
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  
  // Default value diambil dari data user yang sudah ada
  String _selectedTipe = 'Siswa'; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // DATA LANGSUNG MUNCUL: Inisialisasi controller dengan data lama
    _namaController = TextEditingController(text: widget.user.namaUsers);
    _emailController = TextEditingController(text: widget.user.email);
    
    // Set tipe peminjam sesuai data di database (Siswa/Guru)
    if (widget.user.tipeUser != null) {
      // Memastikan huruf pertama kapital agar cocok dengan list dropdown
      _selectedTipe = widget.user.tipeUser![0].toUpperCase() + widget.user.tipeUser!.substring(1);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateData() async {
    if (_namaController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan email tidak boleh kosong")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Memanggil fungsi updateUser yang sudah diperbaiki untuk Supabase
      await UserController().updateUser(
        id: widget.user.id,
        nama: _namaController.text.trim(),
        email: _emailController.text.trim(),
        role: 'peminjam',
        tipeUser: _selectedTipe.toLowerCase(),
      );
      
      if (mounted) {
        Navigator.pop(context, true); // Kembali ke list dan beri sinyal untuk refresh
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Peminjam", 
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFDDEFF5),
                child: Icon(Icons.person, size: 70, color: AppColors.primaryBlue.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: 30),

            _buildLabel("Nama Pengguna"),
            _buildTextField(_namaController, "Masukkan nama peminjam"),

            const SizedBox(height: 20),
            _buildLabel("Email Pengguna"),
            _buildTextField(_emailController, "Masukkan email peminjam"),

            const SizedBox(height: 20),
            _buildLabel("Tipe Peminjam"), 
            _buildTipeDropdown(), 

            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Simpan Perubahan", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS (SAMA DENGAN TAMBAH PEMINJAM) ---

  Widget _buildTipeDropdown() {
    return Container(
      // Memberikan bayangan agar terlihat melayang sesuai gambar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15), // Lebih membulat
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Bagian Box Utama Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTipe,
                isExpanded: true,
                // Ikon panah ke atas warna biru sesuai image_819487.png
                icon: const Icon(
                  Icons.arrow_drop_up, 
                  color: AppColors.primaryBlue, 
                  size: 35,
                ),
                // Hint teks agar muncul "Masukkan tipe peminjam" jika value null
                hint: const Text(
                  "Masukkan tipe peminjam",
                  style: TextStyle(color: Color(0xFF9EAFC0), fontSize: 15),
                ),
                // Mengatur tampilan menu item saat diklik
                borderRadius: BorderRadius.circular(15),
                dropdownColor: Colors.white,
                elevation: 8,
                items: ['Siswa', 'Guru'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF7A8D9F), // Warna teks abu kebiruan
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedTipe = val!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(text, style: const TextStyle(
        color: AppColors.textPrimary, 
        fontWeight: FontWeight.w600, 
        fontSize: 14)),
    );
  }
}