import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // Tambahkan ini untuk cek Web
import 'package:image_picker/image_picker.dart'; // Tambahkan ini untuk XFile
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatController {
  final _supabase = Supabase.instance.client;

  // 1. Ambil data alat untuk List Screen
  Future<List<Map<String, dynamic>>> fetchAlat({String? query}) async {
    var request = _supabase.from('alat').select('''
      *,
      kategori:id_kategori (
        nama_kategori
      )
    ''');

    if (query != null && query.isNotEmpty) {
      request = request.ilike('nama_alat', '%$query%');
    }

    final response = await request.order('nama_alat', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // 2. Ambil kategori untuk Dropdown
  Future<List<Map<String, dynamic>>> fetchKategori() async {
    final response = await _supabase.from('kategori').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // 3. Tambah Alat (DIBENARKAN: Mendukung XFile & Web)
  Future<void> tambahAlat({
    required String nama,
    required int idKategori,
    required int stok,
    required XFile imageFile, // PERUBAHAN: Gunakan XFile
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'public/$fileName';
    
    // LOGIKA UPLOAD: Membedakan Web dan Mobile
    if (kIsWeb) {
      // Jika di Laptop/Web, upload menggunakan Bytes
      final bytes = await imageFile.readAsBytes();
      await _supabase.storage.from('foto_alat').uploadBinary(
        path, 
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
    } else {
      // Jika di HP, upload menggunakan File path
      await _supabase.storage.from('foto_alat').upload(
        path, 
        File(imageFile.path),
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
    }

    // Ambil URL publik gambar
    final String publicUrl = _supabase.storage.from('foto_alat').getPublicUrl(path);

    // Masukkan data ke tabel 'alat'
    await _supabase.from('alat').insert({
      'nama_alat': nama,
      'id_kategori': idKategori,
      'stok_total': stok,
      'foto_url': publicUrl,
    });
  }

  // 4. Hapus Alat
  Future<void> deleteAlat(int id) async {
    await _supabase.from('alat').delete().eq('id_alat', id);
  }
}