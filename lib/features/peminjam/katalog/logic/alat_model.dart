
class AlatModel {
  final int idAlat;
  final String namaAlat;
  final String namaKategori;
  final String? fotoUrl;
  final int stokTotal;

  AlatModel({
    required this.idAlat,
    required this.namaAlat,
    required this.namaKategori,
    this.fotoUrl,
    this.stokTotal = 0, 
  });
}