class PeminjamanModel {
  final int idPinjam;
  final String namaPeminjam;
  final String emailPeminjam;
  final DateTime? tglPengambilan;
  final DateTime? tenggat;
  final DateTime? tglPengembalian;
  final String status;
  final String? alasanPenolakan;
  final List<DetailItem> items;

  PeminjamanModel({
    required this.idPinjam,
    required this.namaPeminjam,
    required this.emailPeminjam,
    this.tglPengambilan,
    this.tenggat,
    this.tglPengembalian,
    required this.status,
    this.alasanPenolakan,
    required this.items,
  });

  factory PeminjamanModel.fromMap(Map<String, dynamic> map) {
    // 1. Ambil data user dari alias 'peminjam' (hasil join spesifik)
    final userData = map['peminjam'] as Map<String, dynamic>?;
    
    // 2. Ambil list detail barang
    final detailData = map['detail_peminjaman'] as List<dynamic>? ?? [];

    return PeminjamanModel(
      idPinjam: map['id_pinjam'] ?? 0,
      namaPeminjam: userData?['nama_users'] ?? 'User Tidak Dikenal',
      emailPeminjam: userData?['email'] ?? '-',
      tglPengambilan: map['tgl_pengambilan'] != null 
          ? DateTime.parse(map['tgl_pengambilan']) 
          : null,
      tenggat: map['tenggat'] != null 
          ? DateTime.parse(map['tenggat']) 
          : null,
      tglPengembalian: map['tgl_pengembalian'] != null 
          ? DateTime.parse(map['tgl_pengembalian']) 
          : null,
      status: map['status_transaksi'] ?? 'menunggu persetujuan',
      alasanPenolakan: map['alasan_penolakan'],
      items: detailData.map((d) => DetailItem.fromMap(d)).toList(),
    );
  }
}

class DetailItem {
  final String namaAlat;
  final int jumlah;

  DetailItem({required this.namaAlat, required this.jumlah});

  factory DetailItem.fromMap(Map<String, dynamic> map) {
    // Parsing nested data dari tabel 'alat'
    final alatData = map['alat'] as Map<String, dynamic>?;
    return DetailItem(
      namaAlat: alatData?['nama_alat'] ?? 'Alat Dihapus',
      jumlah: map['jumlah_pinjam'] ?? 0,
    );
  }
}