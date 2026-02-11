import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:selaras_backend/features/shared/models/peminjaman_model.dart';

class AktivitasController {
  final supabase = Supabase.instance.client;

  Future<List<PeminjamanModel>> getAktivitas(bool isPengembalian) async {
    try {
      // 1. Tentukan filter sesuai permintaan halaman
      final List<String> statusFilter = isPengembalian 
          ? ['selesai', 'denda'] // Halaman Pengembalian
          : ['dipinjam', 'terlambat']; // Halaman Peminjaman

      // 2. Query ke Supabase
      final response = await supabase
          .from('peminjaman')
          .select('''
            *,
            peminjam:users!peminjam_id ( 
              nama_users, 
              email,
              tipe_user
            ),
            detail_peminjaman (
              jumlah_pinjam,
              alat (nama_alat)
            )
          ''') 
          .inFilter('status_transaksi', statusFilter)
          .order('id_pinjam', ascending: false);

      // 3. Mapping ke Model
      return (response as List).map((e) => PeminjamanModel.fromMap(e)).toList();
    } catch (e) {
      print("Error fetching peminjaman: $e");
      return [];
    }
  }
}