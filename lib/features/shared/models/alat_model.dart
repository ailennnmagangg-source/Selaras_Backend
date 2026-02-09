class AlatModel {
  final int idAlat;
  final String namaAlat;
  final String? fotoUrl;
  final int stokTotal;
  final int idKategori;
  final String? namaKategori; // Tambahkan variabel ini

  AlatModel({
    required this.idAlat,
    required this.namaAlat,
    this.fotoUrl,
    required this.stokTotal,
    required this.idKategori,
    this.namaKategori, // Tambahkan di sini
  });

  factory AlatModel.fromMap(Map<String, dynamic> map) {
    return AlatModel(
      idAlat: map['id_alat'] ?? 0,
      namaAlat: map['nama_alat'] ?? '',
      fotoUrl: map['foto_url'],
      stokTotal: map['stok_total'] ?? 0,
      idKategori: map['id_kategori'] ?? 0,
      // Ambil nama dari join table kategori
      namaKategori: map['kategori']?['nama_kategori'], 
    );
  }
}