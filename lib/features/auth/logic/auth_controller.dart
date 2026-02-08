import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final _client = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  // Fungsi baru untuk mengecek apakah email terdaftar di database
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await _client
          .from('users') // Ganti 'users' sesuai nama tabel Anda di Supabase
          .select('email')
          .eq('email', email)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // AuthController.dart
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}