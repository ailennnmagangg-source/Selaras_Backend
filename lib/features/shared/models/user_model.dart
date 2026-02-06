class UserModel {
  final String id;
  final String namaUsers;
  final String email;
  final String role;      // admin, petugas, peminjam
  final String? tipeUser; // guru, siswa (hanya untuk role peminjam)

  UserModel({
    required this.id,
    required this.namaUsers,
    required this.email,
    required this.role,
    this.tipeUser,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      namaUsers: json['nama_users'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      tipeUser: json['tipe_user'], // Bisa null untuk admin/petugas
    );
  }
}