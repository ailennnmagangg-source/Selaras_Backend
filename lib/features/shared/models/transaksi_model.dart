class PeminjamanModel {
  final int? idPinjam;
  final String namaPeminjam;
  final DateTime tglPengambilan;
  final DateTime tenggat;
  final String statusTransaksi; // 'menunggu', 'disetujui', dll

  PeminjamanModel({
    this.idPinjam,
    required this.namaPeminjam,
    required this.tglPengambilan,
    required this.tenggat,
    this.statusTransaksi = 'menunggu',
  });

  Map<String, dynamic> toMap() {
    return {
      'nama_peminjam': namaPeminjam,
      'tgl_pengambilan': tglPengambilan.toIso8601String(),
      'tenggat': tenggat.toIso8601String(),
      'status_transaksi': statusTransaksi,
    };
  }
}