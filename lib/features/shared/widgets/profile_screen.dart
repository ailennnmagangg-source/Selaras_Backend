import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:selaras_backend/features/auth/logic/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  final String roleLabel;

  const ProfileScreen({
    super.key,
    required this.roleLabel,
  });

  void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      // Padding diatur agar kotak lebih jenjang/tinggi (tidak bantet)
      insetPadding: const EdgeInsets.symmetric(horizontal: 40), 
      contentPadding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Mengikuti isi agar tidak terlalu lebar
        children: [
          const Text(
            "Keluar",
            style: TextStyle(
                color: Colors.red, // Merah sesuai gambar
                fontWeight: FontWeight.bold,
                fontSize: 22),
          ),
          const SizedBox(height: 20),
          const Text(
            "Sebelum Anda pergi...\nPeriksa kembali, yakin ingin keluar?",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              // Tombol Batal (Warna Putih/Abu Terang)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9), 
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal",
                      style: TextStyle(color: Color(0xFF4FA8C5))),
                ),
              ),
              const SizedBox(width: 12),
              // Tombol Iya (Warna Biru Solid)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FA8C5), 
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    await AuthController().logout();
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                  },
                  child: const Text("Iya", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final String displayName = user?.userMetadata?['full_name'] ??
        user?.email?.split('@')[0] ??
        "Mimi Lili";
    final String displayEmail = user?.email ?? "MimiLili@gmail.com";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profil",
          style: TextStyle(
              color: Color(0xFF2D5A70), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D5A70)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Avatar
            const Center(
              child: CircleAvatar(
                radius: 70,
                backgroundColor: AppColors.secondaryBlue,
                child: Icon(Icons.person, size: 100, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              displayName,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A70)),
            ),
            Text(
              displayEmail,
              style: const TextStyle(color: Color(0xFF8A9EAD), fontSize: 16),
            ),
            const SizedBox(height: 30),

            // KOTAK BIRU LATAR BELAKANG (Sesuai Gambar 2)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD0E8F0), // Biru latar belakang
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _buildWhiteInfoCard(Icons.badge_outlined, "Akun", roleLabel),
                  const SizedBox(width: 12),
                  _buildWhiteInfoCard(Icons.location_on_outlined, "Ruang Pengambilan", 
                    "R. 3.1.7 | Kampus 3\nSMK Brantas Karangkates"),
                ],
              ),
            ),

            const SizedBox(height: 30),
            // Garis Biru Tipis (Sesuai Gambar 2)
            const Divider(thickness: 1.5, color: Color(0xFFD0E8F0)),
            const SizedBox(height: 10),
            
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pengaturan",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A70),
                    fontSize: 15),
              ),
            ),
            const SizedBox(height: 15),
            
            // Tombol Keluar
            _buildLogoutTile(context),
          ],
        ),
      ),
    );
  }

  // Widget Kartu Putih yang menumpuk di atas kotak biru
  Widget _buildWhiteInfoCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        height: 85, // Tinggi disamakan agar sejajar
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F9FB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF4FA8C5), size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 9, color: Color(0xFF8A9EAD)),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A70),
                        height: 1.2),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutDialog(context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F9FB),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFD0E8F0)),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFF4FA8C5), size: 24),
            SizedBox(width: 15),
            Text(
              "Keluar",
              style: TextStyle(
                color: Color(0xFF4FA8C5),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Color(0xFF4FA8C5)),
          ],
        ),
      ),
    );
  }
}