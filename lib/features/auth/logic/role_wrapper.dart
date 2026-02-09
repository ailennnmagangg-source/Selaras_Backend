import 'package:flutter/material.dart';
import 'package:selaras_backend/features/shared/widgets/navigation/admin_nav.dart';
import 'package:selaras_backend/features/shared/widgets/navigation/peminjam_nav.dart';
import 'package:selaras_backend/features/shared/widgets/navigation/petugas_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class RoleWrapper extends StatelessWidget {
  const RoleWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil User ID yang sedang login
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      // Jika tidak ada sesi, paksa kembali ke login
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Query ke tabel 'users' untuk ambil role
    return FutureBuilder(
      future: Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(body: Center(child: Text("Terjadi kesalahan mengambil data role.")));
        }

        final String role = snapshot.data!['role'];

        // 3. Arahkan ke halaman sesuai role
        if (role == 'admin') {
          return const AdminMainShell(); // Sekarang Admin punya Navbar sendiri
        } else if (role == 'petugas') {
          return const PetugasNav();
          // Ganti dengan PetugasHomeScreen() jika sudah buat filenya
        } else {
          return const PeminjamNav();
          // Ganti dengan PeminjamHomeScreen() jika sudah buat filenya
        }
      },
    );
  }
}