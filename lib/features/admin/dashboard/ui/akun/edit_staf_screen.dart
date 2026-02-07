import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import 'package:selaras_backend/features/shared/models/user_model.dart';
import '../../../management_alat/logic/user_controller.dart';

class EditStafScreen extends StatefulWidget {
  final UserModel user; // Menerima data user yang diklik dari list
  const EditStafScreen({super.key, required this.user});

  @override
  State<EditStafScreen> createState() => _EditStafScreenState();
}

class _EditStafScreenState extends State<EditStafScreen> {
  // Controller dideklarasikan tanpa nilai awal dulu
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  
  String _selectedPeran = 'Petugas'; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 1. DATA LANGSUNG MUNCUL: Inisialisasi controller dengan data dari widget.user
    _namaController = TextEditingController(text: widget.user.namaUsers);
    _emailController = TextEditingController(text: widget.user.email);
    
    // Set peran awal (pastikan format huruf besar di awal agar cocok dengan item dropdown)
    String roleFromDB = widget.user.role.toLowerCase();
    _selectedPeran = roleFromDB == 'admin' ? 'Admin' : 'Petugas';
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
        const SnackBar(content: Text("Nama dan Email tidak boleh kosong"))
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Pastikan fungsi updateUser tersedia di UserController kamu
      await UserController().updateUser(
        id: widget.user.id,
        nama: _namaController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedPeran.toLowerCase(),
        tipeUser: null, // Staf tidak memiliki tipe
      );
      
      if (mounted) {
        Navigator.pop(context, true); // Kirim true untuk refresh list
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
        title: const Text("Edit Staf", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
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

            _buildLabel("Nama Staf"),
            _buildTextField(_namaController, "Masukkan nama pengguna"),

            const SizedBox(height: 20),
            _buildLabel("Email Staf"),
            _buildTextField(_emailController, "Masukkan email pengguna"),

            const SizedBox(height: 20),
            _buildLabel("Peran Staf"), 
            _buildPeranDropdown(), 

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
                  : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 100), // Padding agar tidak tertutup navbar jika extendBody: true
          ],
        ),
      ),
    );
  }

  // --- REUSABLE UI COMPONENTS (Persis seperti TambahStaf) ---

  Widget _buildPeranDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Menggunakan fill color sesuai permintaan sebelumnya
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedPeran,
            isExpanded: true,
            icon: const Icon(
              Icons.arrow_drop_up, 
              color: AppColors.primaryBlue, 
              size: 35,
            ),
            borderRadius: BorderRadius.circular(15),
            dropdownColor: Colors.white,
            items: ['Petugas', 'Admin'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF7A8D9F),
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedPeran = val!;
              });
            },
          ),
        ),
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
      child: Text(text, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }
}