import 'package:selaras_backend/features/shared/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserController {
  final supabase = Supabase.instance.client;

  // 1. Mengambil data berdasarkan Role
  Future<List<UserModel>> getUsersByRole(List<String> roles) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .inFilter('role', roles); 

      return (response as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data user: $e');
    }
  }

  // 2. Fungsi Tambah Akun (Perbaikan Sign Up)
    Future<void> tambahAkun({
      required String email,
      required String password,
      required String nama,
      required String role, 
      String? tipeUser, 
    }) async {
      try {
        final String cleanEmail = email.trim();
        final String cleanPassword = password.trim();

        // 1. Cek apakah user sudah ada di Auth (Opsional tapi disarankan)
        // 2. Proses Sign Up ke Supabase Auth
        final AuthResponse res = await supabase.auth.signUp(
          email: cleanEmail,
          password: cleanPassword,
        );

        final String? userId = res.user?.id;

        if (userId != null) {
          // 3. Masukkan ke tabel profil (users)
          // Gunakan 'upsert' alih-alih 'insert' untuk menghindari error duplikat
          await supabase.from('users').upsert({
            'id': userId, 
            'nama_users': nama,
            'email': cleanEmail,
            'role': role.toLowerCase(),
            // Pastikan nama kolom di DB adalah 'tipe_user' sesuai desain image_74d33d.png
            'tipe_user': role.toLowerCase() == 'peminjam' ? tipeUser?.toLowerCase() : null,
          });
        }
      } on AuthException catch (e) {
        throw Exception('Email sudah terdaftar atau format salah: ${e.message}');
      } catch (e) {
        // Menangani error 'duplicate key' atau error database lainnya
        throw Exception('Gagal menyimpan profil: $e');
      }
    }

    // Tambahkan fungsi ini di dalam class UserController
  Future<void> hapusUser(String id) async {
    try {
      // Menghapus data dari tabel 'users' berdasarkan ID
      await supabase
          .from('users')
          .delete()
          .eq('id', id);
          
      print("User berhasil dihapus dari database");
    } catch (e) {
      // Melempar error agar bisa ditangkap oleh Dialog UI untuk ditampilkan ke user
      print("Error hapusUser: $e");
      throw Exception("Gagal menghapus akun: $e");
    }
  }

  Future<void> updateUser({
    required String id,
    required String nama,
    required String email,
    String? role,
    String? tipeUser,
  }) async {
    try {
      // Menggunakan Supabase .update() alih-alih Firestore
      await supabase
          .from('users')
          .update({
            'nama_users': nama, // Pastikan nama kolom sesuai tabel Supabase kamu
            'email': email,
            if (role != null) 'role': role.toLowerCase(),
            'tipe_user': role?.toLowerCase() == 'peminjam' ? tipeUser : null,
          })
          .eq('id', id); // Filter berdasarkan ID user
          
    } catch (e) {
      print("Error updateUser: $e");
      throw Exception("Gagal memperbarui data: $e");
    }
  }
}