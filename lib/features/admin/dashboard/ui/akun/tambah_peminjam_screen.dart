import 'package:flutter/material.dart';
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

  final Color primaryBlue = const Color(0xFF4FA8C5);
  final Color labelColor = const Color(0xFF2D6A82);

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
        Navigator.pop(context);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Tambah Peminjam", style: TextStyle(color: labelColor, fontWeight: FontWeight.bold)),
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
                child: Icon(Icons.person, size: 70, color: primaryBlue.withOpacity(0.5)),
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
                  backgroundColor: primaryBlue,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Sesuai permintaan: Border muncul hanya jika diklik (Focused), 
        // namun untuk dropdown kita beri border tipis agar terlihat batasnya
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTipe,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_up, color: primaryBlue, size: 30),
          items: ['Guru', 'Siswa'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedTipe = val!),
        ),
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
          borderSide: BorderSide(color: primaryBlue, width: 1.5),
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
          icon: Icon(_isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: primaryBlue),
          onPressed: () => setState(() => _isObscure = !_isObscure),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(text, style: TextStyle(color: labelColor, fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }
}