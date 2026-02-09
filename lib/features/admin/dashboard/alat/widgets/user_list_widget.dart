import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import 'package:selaras_backend/features/admin/dashboard/akun/edit_peminjam_screen.dart';
import 'package:selaras_backend/features/admin/dashboard/akun/edit_staf_screen.dart';
import 'package:selaras_backend/features/admin/management_alat/logic/user_controller.dart';
import '../../../../shared/models/user_model.dart';

class UserListWidget extends StatefulWidget {
  final List<String> filterRole;
  final String query; // Tambahkan variabel ini

  // Tambahkan query ke constructor agar wajib diisi atau default ""
  const UserListWidget({
    required this.filterRole, 
    this.query = "", 
    super.key
  });

  @override
  State<UserListWidget> createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> {
  final UserController _controller = UserController();

  // Fungsi untuk memicu build ulang saat data dihapus
  void _refreshData() {
    setState(() {});
  }

  // --- FUNGSI DIALOG HAPUS (PERSIS GAMBAR) ---
  void _showDeleteDialog(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Hapus",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Apakah anda yakin\nmenghapus akun ini?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F4F6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                                color: Color(0xFF4FA8C5),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              // Panggil fungsi hapus dari controller
                              await UserController().hapusUser(userId);
                              if (context.mounted) {
                                Navigator.pop(context); // Tutup dialog
                                _refreshData(); // Refresh list
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Akun berhasil dihapus")),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FA8C5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Iya",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserController();

    return FutureBuilder<List<UserModel>>(
      // Gunakan widget.filterRole karena sekarang di dalam State
      future: _controller.getUsersByRole(widget.filterRole, query: widget.query),
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
        padding: const EdgeInsets.only(
            left: 20, 
            right: 20, 
            top: 10, 
            bottom: 150, // KUNCINYA DI SINI
          ),          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            // --- LOGIKA WARNA ---
            Color mainColor;
            Color bgColor;
            String labelText;

            String roleLower = user.role.toLowerCase();
            String tipeLower = (user.tipeUser ?? '').toLowerCase();

            if (roleLower == 'admin') {
              mainColor = const Color(0xFF2D6A82);
              bgColor = const Color(0xFFDDEFF5);
              labelText = "Admin";
            } else if (roleLower == 'petugas') {
              mainColor = const Color(0xFF4FA8C5);
              bgColor = const Color(0xFFE8F4F8);
              labelText = "Petugas";
            } else if (tipeLower == 'guru') {
              mainColor = const Color(0xFF4CAF50);
              bgColor = const Color(0xFFE8F5E9);
              labelText = "Guru";
            } else {
              mainColor = const Color(0xFFF3B760);
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
                    color: mainColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
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
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 13),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              labelText,
                              style: TextStyle(
                                  color: mainColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Cek role user untuk menentukan screen edit mana yang dibuka
                                  if (user.role.toLowerCase() == 'peminjam') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditPeminjamScreen(user: user),
                                      ),
                                    ).then((value) => _refreshData()); // Refresh jika ada perubahan
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditStafScreen(user: user),
                                      ),
                                    ).then((value) => _refreshData());
                                  }
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: AppColors.primaryBlue,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // --- TOMBOL SAMPAH DI SINI ---
                              GestureDetector(
                                onTap: () => _showDeleteDialog(
                                    context, user.id, user.namaUsers),
                                child: Icon(Icons.delete,
                                    color: Colors.red.shade300, size: 22),
                              ),
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