class AlatModel {
  final int idAlat; // int4 di database
  final int idKategori;
  final String namaAlat;
  final int stokTotal;
  final String? fotoUrl;

  AlatModel({
    required this.idAlat,
    required this.idKategori,
    required this.namaAlat,
    required this.stokTotal,
    this.fotoUrl,
  });

  factory AlatModel.fromMap(Map<String, dynamic> map) {
    return AlatModel(
      idAlat: map['id_alat'],
      idKategori: map['id_kategori'],
      namaAlat: map['nama_alat'] ?? '',
      stokTotal: map['stok_total'] ?? 0,
      fotoUrl: map['foto_url'],
    );
  }
}