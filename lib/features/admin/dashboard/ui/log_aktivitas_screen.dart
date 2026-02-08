import 'package:flutter/material.dart';

class LogAktivitasScreen extends StatelessWidget {
  const LogAktivitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Log Aktivitas", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 10, // Contoh jumlah data
        itemBuilder: (context, index) {
          bool isPeminjaman = index % 2 == 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
              border: Border.all(color: const Color(0xFFF1F1F1)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(backgroundColor: Color(0xFFE0E0E0), child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Anindya", style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text("Siswa", style: TextStyle(fontSize: 12, color: Colors.blue)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Petugas: Mimi", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPeminjaman ? const Color(0xFFE3F2FD) : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPeminjaman ? "Peminjaman" : "Pengembalian",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPeminjaman ? Colors.blue : Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Waktu Aktivitas", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("10 Jul 2025 | 10.00", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}