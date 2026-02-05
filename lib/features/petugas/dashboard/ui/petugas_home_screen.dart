import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetugasHomeScreen extends StatelessWidget {
  const PetugasHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Petugas Dashboard"),
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
      body: const Center(child: Text("Selamat Datang, Petugas!")),
    );
  }
}