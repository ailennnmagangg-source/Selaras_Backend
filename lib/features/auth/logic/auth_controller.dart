import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final _client = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }
}