import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardController {
  final _supabase = Supabase.instance.client;

  // --- AMBIL TOTAL DENDA BULAN INI (Untuk Dashboard) ---
  Future<double> getTotalDendaBulanIni() async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

      final response = await _supabase
          .from('denda')
          .select('total_denda')
          .gte('created_at', firstDayOfMonth);

      final List data = response as List;
      
      return data.fold<double>(0.0, (previousValue, item) {
        final currentDenda = (item['total_denda'] ?? 0).toDouble();
        return previousValue + currentDenda;
      });
    } catch (e) {
      debugPrint("Error Total Denda Bulan Ini: $e");
      return 0.0;
    }
  }

  // --- AMBIL DETAIL DENDA MINGGU INI (Untuk Halaman Detail) ---
  Future<List<Map<String, dynamic>>> getDetailDendaMingguan() async {
    try {
      final now = DateTime.now();
      // Mencari hari Senin di minggu ini
      final awalMinggu = now.subtract(Duration(days: now.weekday - 1));
      final formatAwalMinggu = DateTime(awalMinggu.year, awalMinggu.month, awalMinggu.day).toIso8601String();

      // Query dengan Join ke tabel Peminjaman dan Users
      final response = await _supabase
          .from('denda')
          .select('''
            total_denda,
            created_at,
            peminjaman:id_kembali!inner (
              id_pinjam,
              status_transaksi,
              users:peminjam_id!inner (
                nama_users
              )
            )
          ''')
          .gte('created_at', formatAwalMinggu)
          .order('created_at', ascending: true);

      if (response == null) return [];

      // Cast response menjadi List of Maps agar aman digunakan di UI
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error Detail Denda Mingguan: $e");
      return [];
    }
  }
}