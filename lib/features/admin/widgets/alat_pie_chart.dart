import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:selaras_backend/core/constants/app_colors.dart'; // Sesuaikan path AppColors kamu

class AlatPieChart extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const AlatPieChart({super.key, required this.data});

  @override
  State<AlatPieChart> createState() => _AlatPieChartState();
}

class _AlatPieChartState extends State<AlatPieChart> {
  int touchedIndex = -1; // Menyimpan indeks yang sedang diklik

  @override
  Widget build(BuildContext context) {
    // Menghitung total peminjaman untuk tampilan default
    int totalDefault = widget.data.fold(0, (sum, item) => sum + (item['value'] as int));

    // Palet warna biru sesuai AppColors
    List<Color> chartColors = [
      AppColors.primaryBlue,
      AppColors.secondaryBlue,
      const Color(0xFF64B5F6),
      const Color(0xFF90CAF9),
      const Color(0xFFBBDEFB),
      AppColors.abumuda, // Untuk "Lainnya"
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Agar teks rata kiri
        children: [
          // Bagian Chart
          // --- TAMBAHKAN TEKS JUDUL DI SINI ---
          const Text(
            "Alat yang sering dipinjam",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary, // Menggunakan warna dari palet kamu
            ),
          ),
          const SizedBox(height: 20), // Memberi jarak antara judul dan chart
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sectionsSpace: 4,
                    centerSpaceRadius: 75,
                    sections: List.generate(widget.data.length, (i) {
                      final isTouched = i == touchedIndex;
                      final fontSize = isTouched ? 20.0 : 16.0;
                      final radius = isTouched ? 25.0 : 18.0; // Memperbesar bagian yang diklik

                      return PieChartSectionData(
                        color: chartColors[i % chartColors.length],
                        value: widget.data[i]['value'].toDouble(),
                        radius: radius,
                        showTitle: false,
                      );
                    }),
                  ),
                ),
                // LOGIKA TEKS TENGAH: Berubah saat diklik
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      touchedIndex == -1
                          ? "$totalDefault" // Tampilkan total jika tidak ada yang diklik
                          : "${widget.data[touchedIndex]['value']}", // Tampilkan jumlah alat yang diklik
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      touchedIndex == -1 ? "Total Dipinjam" : widget.data[touchedIndex]['name'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Legend (Keterangan)
          Wrap(
            spacing: 15,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(widget.data.length, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: chartColors[i % chartColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.data[i]['name'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}