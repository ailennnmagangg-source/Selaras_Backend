import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import 'package:selaras_backend/features/admin/dashboard/logic/admin_dashboard_controller.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/widgets/card_peminjaman_dashboard.dart';
import 'package:selaras_backend/features/admin/widgets/alat_pie_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // 1. Definisikan variabel ini di sini agar bisa diakses di seluruh widget build
  final controller = AdminDashboardController();
  String selectedFilter = 'Semua'; // Ganti default ke 'Semua'
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Beranda",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 2. Section Pie Chart
              FutureBuilder<List<Map<String, dynamic>>>(
                future: controller.getMostBorrowedAlat(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return AlatPieChart(data: snapshot.data!);
                  }
                  return const Text("Gagal memuat chart atau data kosong");
                },
              ),

              const SizedBox(height: 25),

              // 3. WIDGET TOTAL DENDA
              FutureBuilder<double>(
                future: controller.getTotalDendaBulanIni(),
                builder: (context, snapshot) {
                  String formattedDenda = snapshot.hasData 
                      ? "Rp ${snapshot.data!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}"
                      : "Rp 0";

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryBlue, 
                          AppColors.primaryBlue.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Denda Bulan Ini",
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formattedDenda,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 35),

              // 4. Header & Filter Chips
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Peminjaman",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Row untuk tombol filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: ['Semua', 'Hari ini', 'Minggu ini', 'Bulan ini'].map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => selectedFilter = filter);
                          },
                          // Warna saat terpilih: Biru Utama
                          selectedColor: AppColors.primaryBlue,
                          // Warna latar belakang saat tidak terpilih: Putih Bersih
                          backgroundColor: Colors.white,
                          // Menghilangkan bayangan default agar terlihat flat & clean
                          elevation: isSelected ? 2 : 0,
                          pressElevation: 0,
                          // Membuat sudut lebih halus (rounded)
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          // Menghilangkan centang default bawaan Flutter agar lebih minimalis
                          showCheckmark: false, 
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // 5. Section List Transaksi (Menggunakan Card Baru)
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: controller.getRecentTransactions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Belum ada transaksi."));
                    }

                    return Column(
                      // PANGGIL TransactionCard yang sudah mendukung dropdown
                      children: snapshot.data!.map((data) {
                        return TransactionCard(data: data);
                      }).toList(),
                    );
                   },
                 ),
               ],
              ),
            ]
          ),
        )
      )
    );
  }
}