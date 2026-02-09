import 'package:flutter/material.dart';
import 'package:selaras_backend/features/shared/models/alat_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KatalogController {
  // Menggunakan underscore (_) untuk variabel private agar lebih aman
  final _supabase = Supabase.instance.client;

  // --- FUNGSI AMBIL KATEGORI ---
  // Berfungsi untuk mengisi menu filter "Semua", "Masak", "Musik", dll
  Future<List<Map<String, dynamic>>> fetchKategori() async {
    try {
      final response = await _supabase
          .from('kategori')
          .select('id_kategori, nama_kategori')
          .order('nama_kategori');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error Fetch Kategori: $e");
      return [];
    }
  }

  // --- FUNGSI AMBIL ALAT ---
  // Fungsi tunggal yang sudah mendukung Join Table untuk mengambil Nama Kategori
  Future<List<AlatModel>> fetchAlat({int? idKategori}) async {
    try {
      // Melakukan Join tabel alat dengan tabel kategori
      // Ini yang membuat 'item.namaKategori' bisa muncul di Form Peminjaman
      var query = _supabase
          .from('alat')
          .select('*, kategori(nama_kategori)');

      // Filter berdasarkan id_kategori jika dipilih (bukan 0/Semua)
      if (idKategori != null && idKategori != 0) {
        query = query.eq('id_kategori', idKategori);
      }

      final response = await query.order('nama_alat');
      
      return (response as List).map((data) => AlatModel.fromMap(data)).toList();
    } catch (e) {
      debugPrint("Error Fetch Alat: $e");
      return [];
    }
  }
}