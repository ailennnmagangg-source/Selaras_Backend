import 'package:flutter/material.dart';
import 'package:selaras_backend/features/admin/management_alat/logic/user_controller.dart';

import '../../../../shared/models/user_model.dart';

class UserListWidget extends StatelessWidget {
  final List<String> filterRole;
  const UserListWidget({required this.filterRole, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController();

    return FutureBuilder<List<UserModel>>(
      future: controller.getUsersByRole(filterRole),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final List<UserModel> users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(child: Text("Tidak ada data pengguna"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index]; 

            // --- LOGIKA 4 WARNA BERBEDA ---
            Color mainColor;
            Color bgColor;
            String labelText;

            String roleLower = user.role.toLowerCase();
            // Gunakan null check yang lebih aman
            String tipeLower = (user.tipeUser ?? '').toLowerCase();

            if (roleLower == 'admin') {
              mainColor = const Color(0xFF2D6A82); // Biru Tua
              bgColor = const Color(0xFFDDEFF5);
              labelText = "Admin";
            } else if (roleLower == 'petugas') {
              mainColor = const Color(0xFF4FA8C5); // Biru Cyan
              bgColor = const Color(0xFFE8F4F8);
              labelText = "Petugas";
            } else if (tipeLower == 'guru') {
              mainColor = const Color(0xFF4CAF50); // Hijau (Sesuai image_74d33d.png)
              bgColor = const Color(0xFFE8F5E9);
              labelText = "Guru";
            } else {
              // Default untuk Siswa atau Peminjam umum
              mainColor = const Color(0xFFF3B760); // Oranye
              bgColor = const Color(0xFFFFF4E5);
              labelText = "Siswa";
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    // Gunakan mainColor untuk shadow agar lebih estetik
                    color: mainColor.withOpacity(0.1), 
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Garis samping mengikuti mainColor
                    Container(
                      width: 5,
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: CircleAvatar(
                        radius: 28,
                        // Gunakan bgColor kategori untuk avatar agar senada
                        backgroundColor: bgColor,
                        child: Icon(Icons.person, size: 35, color: mainColor),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.namaUsers,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: Color(0xFF2D5B7A),
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Badge Status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              labelText,
                              style: TextStyle(
                                color: mainColor, 
                                fontSize: 10, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              // Ganti warna icon edit agar tidak terlalu mencolok
                              Icon(Icons.edit, color: Colors.blueGrey.shade300, size: 22),
                              const SizedBox(width: 10),
                              Icon(Icons.delete, color: Colors.red.shade300, size: 22),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}