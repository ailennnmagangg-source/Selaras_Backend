import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import 'package:selaras_backend/features/admin/dashboard/logic/admin_dashboard_controller.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/denda_mingguan_screen.dart';
import 'package:selaras_backend/features/admin/dashboard/ui/widgets/card_peminjaman_dashboard.dart';
import 'package:selaras_backend/features/admin/widgets/alat_pie_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final controller = AdminDashboardController();
  String selectedFilter = 'Semua';

  // Helper untuk format rupiah sederhana
  String _formatCurrency(double value) {
    return "Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

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
              // 1. Header
              const Text(
                "Beranda",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A4D7C)),
              ),
              const SizedBox(height: 25),

              // 2. Section Pie Chart
              FutureBuilder<List<Map<String, dynamic>>>(
                future: controller.getMostBorrowedAlat(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return AlatPieChart(data: snapshot.data!);
                  }
                  return const Text("Data chart tidak tersedia");
                },
              ),
              const SizedBox(height: 25),

              // 3. SECTION TOTAL DENDA (BULANAN & MINGGUAN)
              Column(
                children: [
                  // --- Card Total Denda Bulan Ini ---
                  FutureBuilder<double>(
                    future: controller.getTotalDendaBulanIni(),
                    builder: (context, snapshot) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
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
                                const Text("Total Denda Bulan Ini", style: TextStyle(color: Colors.white, fontSize: 14)),
                                const SizedBox(height: 8),
                                Text(
                                  _formatCurrency(snapshot.data ?? 0),
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 15),

                // --- Card Total Denda Minggu Ini ---
FutureBuilder<double>(
  future: controller.getTotalDendaMingguIni(),
  builder: (context, snapshot) {
    String formattedDenda = snapshot.hasData 
        ? _formatCurrency(snapshot.data!)
        : "Rp 0";

    // KUNCI PERBAIKAN: Gunakan Material sebagai pembungkus paling luar
    return Material(
      color: Colors.transparent, // Agar background putih container terlihat
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          // 1. Berikan feedback loading segera
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          final hasil = await controller.getDetailDendaMingguan();
          
          if (context.mounted) {
            Navigator.pop(context); // Tutup loading

            final List<Map<String, dynamic>> dataDendaValid = (hasil as List)
                .map((e) => e as Map<String, dynamic>)
                .toList();

            if (dataDendaValid.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tidak ada denda untuk minggu ini"))
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DendaPerMingguScreen(dataDenda: dataDendaValid),
                ),
              );
            }
          }
        },
        child: Container(
          // Pindahkan decoration ke dalam Container seperti semula
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03), 
                blurRadius: 10, 
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.event_note, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dalam Minggu Ini",
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDenda,
                    style: const TextStyle(
                      color: Color(0xFF1A4D7C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  },
),
                ],
              ),

              const SizedBox(height: 35),

              // 4. Header Peminjaman & Filter
              const Text("Peminjaman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A4D7C))),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Semua', 'Hari ini', 'Minggu ini', 'Bulan ini'].map((filter) {
                    final isSelected = selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (val) { if (val) setState(() => selectedFilter = filter); },
                        selectedColor: AppColors.primaryBlue,
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // 5. List Transaksi
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
                    children: snapshot.data!.map((data) => TransactionCard(data: data)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}