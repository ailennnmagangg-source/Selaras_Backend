import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatController {
  final _supabase = Supabase.instance.client;

  // 1. Ambil data alat (Mendukung Search & Filter Kategori)
  Future<List<Map<String, dynamic>>> fetchAlat({String? query, String? kategori}) async {
    try {
      var request = _supabase.from('alat').select('''
        *,
        kategori:id_kategori (
          nama_kategori
        )
      ''');

      // Filter Pencarian Nama
      if (query != null && query.isNotEmpty) {
        request = request.ilike('nama_alat', '%$query%');
      }

      // Filter Kategori (Berdasarkan nama kategori di tabel relasi)
      if (kategori != null && kategori != "Semua") {
        request = request.eq('kategori.nama_kategori', kategori);
      }

      final response = await request.order('nama_alat', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetchAlat: $e");
      return [];
    }
  }

  // 2. Ambil kategori untuk Dropdown & Filter Chips
  Future<List<Map<String, dynamic>>> fetchKategori() async {
    try {
      final response = await _supabase
          .from('kategori')
          .select()
          .order('nama_kategori', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetchKategori: $e");
      return [];
    }
  }

  // 3. Tambah Alat (Mendukung XFile & Web)
  Future<void> tambahAlat({
    required String nama,
    required int idKategori,
    required int stok,
    required XFile imageFile,
  }) async {
    // Upload gambar dan dapatkan URL-nya
    String imageUrl = await _uploadImage(imageFile);

    // Simpan ke Database
    await _supabase.from('alat').insert({
      'nama_alat': nama,
      'id_kategori': idKategori,
      'stok_total': stok,
      'foto_url': imageUrl,
    });
  }

  // 4. Update Alat (PENTING: Digunakan di EditAlatScreen)
  Future<void> updateAlat({
    required int idAlat,
    required String nama,
    required int idKategori,
    required int stok,
    XFile? newImageFile, // Opsional jika user tidak ganti gambar
    required String oldImageUrl,
  }) async {
    String imageUrl = oldImageUrl;

    // Jika ada gambar baru, upload gambar tersebut
    if (newImageFile != null) {
      imageUrl = await _uploadImage(newImageFile);
    }

    await _supabase.from('alat').update({
      'nama_alat': nama,
      'id_kategori': idKategori,
      'stok_total': stok,
      'foto_url': imageUrl,
    }).eq('id_alat', idAlat);
  }

  // 5. Fungsi Helper Upload Gambar (Web & Mobile)
  Future<String> _uploadImage(XFile imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'public/$fileName';

    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      await _supabase.storage.from('foto_alat').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
    } else {
      await _supabase.storage.from('foto_alat').upload(
            path,
            File(imageFile.path),
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
    }

    return _supabase.storage.from('foto_alat').getPublicUrl(path);
  }

  // 6. Hapus Alat
  Future<void> deleteAlat(int id) async {
    await _supabase.from('alat').delete().eq('id_alat', id);
  }
}