import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
// PASTIKAN IMPORT INI ADA:
import 'package:selaras_backend/features/admin/management_alat/logic/user_controller.dart';

class TambahStafScreen extends StatefulWidget {
  const TambahStafScreen({super.key});

  @override
  State<TambahStafScreen> createState() => _TambahStafScreenState();
}

class _TambahStafScreenState extends State<TambahStafScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  
  String _selectedRole = 'Admin';
  bool _isObscure = true;
  bool _isLoading = false; // Tambahkan variabel loading ini

  // Warna tema
  final Color primaryBlue = const Color(0xFF4FA8C5);
  final Color labelColor = const Color(0xFF2D6A82);

  // --- FUNGSI SIMPAN DATA ---
  void _simpanData() async {
    // Validasi input kosong
    if (_namaController.text.isEmpty || _emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua kolom!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final controller = UserController();
      await controller.tambahAkun(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
        nama: _namaController.text.trim(),
        role: _selectedRole.toLowerCase(), // simpan 'admin' atau 'petugas'
        tipeUser: null, // Staf tidak memiliki tipe (Guru/Siswa)
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Akun Staf berhasil dibuat!")),
        );
        Navigator.pop(context, true); // Kembali ke daftar dan refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Tambah Staf",
          style: TextStyle(color: labelColor, fontWeight: FontWeight.bold),
        ),
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
            _buildLabel("Peran"),
            _buildDropdown(),

            const SizedBox(height: 20),
            _buildLabel("Kata Sandi"),
            _buildPasswordField(),

            const SizedBox(height: 50),
            
            // Tombol Simpan dengan Loading State
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanData, // Hubungkan ke fungsi simpan
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(
        text,
        style: TextStyle(color: labelColor, fontWeight: FontWeight.w600, fontSize: 14),
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
          borderSide: BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: primaryBlue, size: 30),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: ['Admin', 'Petugas'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: labelColor)),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _selectedRole = val!);
          },
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
}