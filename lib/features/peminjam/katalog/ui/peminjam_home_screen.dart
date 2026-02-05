import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PeminjamHomeScreen extends StatelessWidget {
  const PeminjamHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peminjam Dashboard"),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const Center(child: Text("Selamat Datang, Peminjam!")),
    );
  }
}