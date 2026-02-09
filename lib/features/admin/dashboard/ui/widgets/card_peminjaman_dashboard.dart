import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';

class TransactionCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const TransactionCard({super.key, required this.data});

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final details = widget.data['detail_peminjaman'] as List;
    // Menghitung total item yang dipinjam dalam satu transaksi
    int totalBarang = details.fold(0, (sum, item) => sum + (item['jumlah_pinjam'] as int));
    
    // Format Tanggal
    String tanggal = widget.data['tgl_pengambilan'].toString().split('T')[0];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: const CircleAvatar(
              backgroundColor: AppColors.lightBlueBg,
              child: Icon(Icons.person, color: AppColors.primaryBlue),
            ),
            title: Text(
              // Mengambil nama dari objek 'users' hasil join
              widget.data['users']?['nama_users'] ?? "Peminjam Tidak Dikenal", 
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(tanggal, style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue)),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Dipinjam $totalBarang",
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.primaryBlue),
              ],
            ),
            onTap: () => setState(() => isExpanded = !isExpanded),
          ),
          
          // Bagian yang muncul saat Dropdown diklik
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.scaffoldBg, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Alat", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 10),
                  ...details.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['alat']['nama_alat'], 
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text("${item['jumlah_pinjam']} unit", 
                            style: const TextStyle(color: AppColors.textPrimary)),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}