import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardController {
  // Gunakan getter untuk akses client yang lebih bersih
  final _supabase = Supabase.instance.client;

    Future<double> getTotalDendaBulanIni() async {
    try {
      final sekarang = DateTime.now();
      // Ambil awal bulan ini
      final awalBulan = DateTime(sekarang.year, sekarang.month, 1);

      final response = await _supabase
          .from('denda') // Ganti ke tabel denda
          .select('total_denda') // Nama kolom sesuai gambar
          .gte('created_at', awalBulan.toIso8601String()); // Gunakan created_at

      if (response == null || (response as List).isEmpty) {
        return 0.0;
      }

      double total = 0;
      for (var item in response) {
        // Ambil data dari kolom total_denda
        final dendaRaw = item['total_denda'];
        if (dendaRaw != null) {
          total += (dendaRaw as num).toDouble();
        }
      }

      debugPrint("Total denda bulan ini: $total");
      return total;
    } catch (e) {
      debugPrint("Error Total Denda: $e");
      return 0.0;
    }
  }

    //PEMINJAMAN
   Future<List<Map<String, dynamic>>> getRecentTransactions({String filter = 'Semua'}) async {
      try {
        DateTime now = DateTime.now();
        DateTime? startDate;

        if (filter == 'Minggu ini') {
          startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
        } else if (filter == 'Bulan ini') {
          startDate = DateTime(now.year, now.month, 1);
        } else if (filter == 'Hari ini') {
          startDate = DateTime(now.year, now.month, now.day);
        } else {
          startDate = null;
        }

        // Mulai Query
        var query = _supabase
            .from('peminjaman')
            .select('''
              id_pinjam,
              tgl_pengambilan,
              status_transaksi,
              users:peminjam_id (nama_users),
              detail_peminjaman (
                jumlah_pinjam,
                alat (nama_alat, foto_url)
              )
            ''')
            // TAMBAHKAN FILTER INI:
            .eq('status_transaksi', 'dipinjam'); 

        // Filter tanggal tetap berlaku jika startDate tidak null
        if (startDate != null) {
          query = query.gte('tgl_pengambilan', startDate.toIso8601String());
        }

        final response = await query.order('tgl_pengambilan', ascending: false);

        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        debugPrint("Error: $e");
        return [];
      }
    }
 
    //DONAT /PIE CHART
    Future<List<Map<String, dynamic>>> getMostBorrowedAlat() async {
  try {
    final List<dynamic> response = await _supabase
        .from('detail_peminjaman')
        .select('id_alat, alat(nama_alat)');

    if (response.isEmpty) return [];

    // 1. Hitung frekuensi semua alat
    Map<String, int> counts = {};
    for (var item in response) {
      final alatData = item['alat'] as Map<String, dynamic>?;
      if (alatData != null) {
        String name = alatData['nama_alat'] ?? 'Tanpa Nama';
        counts[name] = (counts[name] ?? 0) + 1;
      }
    }

    // 2. Urutkan berdasarkan jumlah pinjam terbanyak
    var sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 3. Ambil Top 5 dan gabungkan sisanya ke "Lainnya"
    List<Map<String, dynamic>> finalData = [];
    int sisanya = 0;

    for (int i = 0; i < sortedEntries.length; i++) {
      if (i < 5) {
        finalData.add({
          'name': sortedEntries[i].key,
          'value': sortedEntries[i].value,
        });
      } else {
        sisanya += sortedEntries[i].value;
      }
    }

    // 4. Tambahkan kategori "Lainnya" jika ada sisa
    if (sisanya > 0) {
      finalData.add({
        'name': 'Lainnya',
        'value': sisanya,
      });
    }

    return finalData;
  } catch (e) {
    debugPrint("Error fetching chart data: $e");
    return [];
  }
}

  getTotalDendaMingguIni() {}

  getDetailDendaMingguan() {}
}