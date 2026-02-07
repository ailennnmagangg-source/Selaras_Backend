import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import '../../../management_alat/logic/user_controller.dart';

class TambahPeminjamScreen extends StatefulWidget {
  const TambahPeminjamScreen({super.key});

  @override
  State<TambahPeminjamScreen> createState() => _TambahPeminjamScreenState();
}

class _TambahPeminjamScreenState extends State<TambahPeminjamScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  
  // Default value untuk tipe peminjam
  String _selectedTipe = 'Siswa'; 
  bool _isObscure = true;
  bool _isLoading = false;

  void _simpanData() async {
    setState(() => _isLoading = true);
    try {
      await UserController().tambahAkun(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
        nama: _namaController.text.trim(),
        role: 'peminjam', // Role otomatis diset sebagai peminjam
        tipeUser: _selectedTipe, // guru atau siswa
      );
      if (mounted) {
        Navigator.pop(context, true);
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
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Tambah Peminjam", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
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
            _buildTextField(_namaController, "Masukkan nama pengguna"),

            const SizedBox(height: 20),
            _buildLabel("Email Pengguna"),
            _buildTextField(_emailController, "Masukkan email pengguna"),

            const SizedBox(height: 20),
            _buildLabel("Tipe Peminjam"), // Label diganti
            _buildTipeDropdown(), // Dropdown khusus Tipe Peminjam

            const SizedBox(height: 20),
            _buildLabel("Kata Sandi"),
            _buildPasswordField(),

            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dropdown khusus Guru & Siswa sesuai gambar 2
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

  // Menggunakan style yang sama dengan Staf (Tanpa border saat diam)
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
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passController,
      obscureText: _isObscure,
      decoration: InputDecoration(
        hintText: "Masukkan kata sandi",
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(_isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.primaryBlue),
          onPressed: () => setState(() => _isObscure = !_isObscure),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(text, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }
}