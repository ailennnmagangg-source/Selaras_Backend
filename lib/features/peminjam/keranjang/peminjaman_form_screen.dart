import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selaras_backend/core/constants/app_colors.dart';
import 'package:selaras_backend/features/peminjam/riwayat_saya/peminjam_riwayat_screen.dart';
import 'package:selaras_backend/features/shared/models/alat_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class PeminjamanFormScreen extends StatefulWidget {
  final List<AlatModel> selectedItems;
  const PeminjamanFormScreen({super.key, required this.selectedItems});

  @override
  State<PeminjamanFormScreen> createState() => _PeminjamanFormScreenState();
}

class _PeminjamanFormScreenState extends State<PeminjamanFormScreen> {
  final TextEditingController _namaController = TextEditingController();
  
  
  DateTime? _tglAmbil;
  String? _jamAmbil; // Diubah jadi String untuk menyimpan hasil seleksi list
  DateTime? _tglTenggat;
  String? _jamTenggat;

  void _showSuccessPopup() {
  showDialog(
    context: context,
    barrierDismissible: false, // User harus klik tombol 'Oke'
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Dialog mengikuti ukuran konten
            children: [
              const Text(
                "Menunggu Persetujuan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D4379),
                ),
              ),
              const SizedBox(height: 20),

             Image.asset(
                'assets/images/image_verifikasi.png',
                height: 140,
                errorBuilder: (context, error, stackTrace) {
                  // Jika asset masih error, munculkan icon sebagai cadangan
                  return const Icon(Icons.mark_email_read_outlined, size: 100, color: Color(0xFF5AB9D5));
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Pengajuan berhasil dikirim!\nPantau status persetujuan Anda secara berkala di halaman Riwayat.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const PeminjamRiwayatScreen()),
                    );
                  },
                  child: const Text("Oke"),
                )
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // --- FORMATTER HELPER ---
  String formatDate(DateTime? date) => 
      date != null ? DateFormat('dd/MM/yyyy').format(date) : "Tgl/Bln/Thn";

  // --- LOGIC GROUPING ITEM (Hanya untuk Tampilan) ---
  Map<int, int> get groupedItems {
    Map<int, int> counts = {};
    for (var item in widget.selectedItems) {
      counts[item.idAlat] = (counts[item.idAlat] ?? 0) + 1;
    }
    return counts;
  }

  List<AlatModel> get uniqueItems {
    final seen = <int>{};
    return widget.selectedItems.where((item) => seen.add(item.idAlat)).toList();
  }

  // --- CUSTOM TIME PICKER (VERSI GAMBAR 2: LIST OPERASIONAL) ---
  void _showTimePickerList(bool isAmbil) {
  final List<String> times = [
    "07:00", "08:00", "09:00", "10:00", "11:00", 
    "12:00", "13:00", "14:00"
  ];

  // Variabel lokal untuk menampung pilihan sementara sebelum klik "Pilih"
  String? temporarySelectedTime = isAmbil ? _jamAmbil : _jamTenggat;

  showDialog(
    context: context,
    builder: (context) {
      // Gunakan StatefulBuilder agar list di dalam dialog bisa update warna saat diklik
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            titlePadding: const EdgeInsets.all(0),
            title: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: const Text(
                "Jam Operasional",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D4379)),
              ),
            ),
            backgroundColor: Colors.white,
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: times.length,
                itemBuilder: (context, index) {
                  bool isSelected = temporarySelectedTime == times[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD6EAF8) : Colors.transparent, // Highlight biru muda
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        times[index],
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF5AB9D5) : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setDialogState(() {
                          temporarySelectedTime = times[index];
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (isAmbil) {
                            _jamAmbil = temporarySelectedTime;
                          } else {
                            _jamTenggat = temporarySelectedTime;
                          }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5AB9D5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("Pilih", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}

  // --- DATE PICKER ---
  Future<void> _pickDate(bool isAmbil) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5AB9D5),
              onSurface: Color(0xFF2D4379),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isAmbil) _tglAmbil = picked; else _tglTenggat = picked;
      });
    }
  }


    @override
    void initState() {
      super.initState();
      _loadUserData(); // Panggil fungsi async terpisah
    }

    Future<void> _loadUserData() async {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          // Ambil data nama dari tabel 'users' berdasarkan ID user yang login
          final data = await Supabase.instance.client
              .from('users') // Nama tabel user kamu
              .select('nama_users') // Ganti dengan nama kolom di tabel kamu
              .eq('id', user.id)
              .single();

          if (data != null && data['nama_users'] != null) {
            setState(() {
              _namaController.text = data['nama_users'];
            });
          }
        }
      } catch (e) {
        debugPrint("Error loading user name: $e");
        // Fallback jika error, misalnya pakai email saja
        _namaController.text = "Pengguna"; 
      }
    }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D4379), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Peminjaman",
          style: TextStyle(color: Color(0xFF2D4379), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Alat (${widget.selectedItems.length})", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D4379))),
            const SizedBox(height: 12),

            // LIST ALAT SCROLLL
            ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 250, // Tinggi maksimal area alat sebelum bisa discroll (sekitar 3 item)
              minHeight: 0,
            ),
            child: ListView.builder(
              shrinkWrap: true, // Membiarkan list mengikuti ukuran konten
              physics: const BouncingScrollPhysics(), // Scroll halus di dalam area ini
              itemCount: uniqueItems.length,
              itemBuilder: (context, index) {
                final item = uniqueItems[index];
                final count = groupedItems[item.idAlat] ?? 0;
                return _buildAlatCard(item, count); // Memanggil kartu alat kamu
              },
            ),
          ),
          // --------------------------------------------------

          const SizedBox(height: 12),
          _buildTambahButton(),
          
          const Divider(height: 40, thickness: 1, color: Color(0xFFE0E0E0)),
            _buildLabel("Nama Peminjam"),
            _buildTextField("Masukkan nama peminjam", _namaController, isReadOnly: true),
            
            const SizedBox(height: 20),
            _buildLabel("Pengambilan"),
            Row(
              children: [
                Expanded(child: _buildDateTimePicker(formatDate(_tglAmbil), Icons.calendar_today_outlined, () => _pickDate(true))),
                const SizedBox(width: 15),
                Expanded(child: _buildDateTimePicker(_jamAmbil ?? "00:00", Icons.access_time_rounded, () => _showTimePickerList(true))),
              ],
            ),

            const SizedBox(height: 20),
            _buildLabel("Tenggat"),
            Row(
              children: [
                Expanded(child: _buildDateTimePicker(formatDate(_tglTenggat), Icons.calendar_today_outlined, () => _pickDate(false))),
                const SizedBox(width: 15),
                Expanded(child: _buildDateTimePicker(_jamTenggat ?? "00:00", Icons.access_time_rounded, () => _showTimePickerList(false))),
              ],
            ),

            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildAlatCard(AlatModel item, int count) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
    ),
    child: Row(
      children: [
        // Menampilkan Gambar Alat dari Database
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.fotoUrl != null && item.fotoUrl!.isNotEmpty
                ? Image.network(
                    item.fotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.broken_image, color: Colors.grey),
                  )
                : const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Alat
              Text(
                item.namaAlat, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D4379)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Kategori (Atau Nama Kategori jika Anda mempassingnya)
              Text(
                "${item.namaKategori}", 
                style: const TextStyle(color: Colors.grey, fontSize: 12)
              ),
              const SizedBox(height: 4),
              // Jumlah yang dipilih/dipinjam
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF5AB9D5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "Dipinjam: $count", 
                  style: const TextStyle(color: Color(0xFF5AB9D5), fontWeight: FontWeight.bold, fontSize: 11)
                ),
              ),
            ],
          ),
        ),
        // Tombol hapus item dari list pilihan
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
          onPressed: () {
            setState(() {
              // Menghapus semua item dengan ID yang sama dari list utama
              widget.selectedItems.removeWhere((element) => element.idAlat == item.idAlat);
            });
          },
        ),
      ],
    ),
  );
}

  Widget _buildTextField(String hint, TextEditingController controller, {bool isReadOnly = false}) {
  return TextFormField(
    controller: controller,
    readOnly: isReadOnly, // Jika true, user tidak bisa mengetik
    //text
    style: TextStyle(
      color:  Colors.grey[500],
      fontSize: 16
      ),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white, // Beri warna beda jika readOnly
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryBlue),
      ),
    ),
  );
}

  Widget _buildTambahButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF5AB9D5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("+ Tambah Item Lain", style: TextStyle(color: Color(0xFF5AB9D5))),
      ),
    );
  }

  Widget _buildSubmitButton() {
    
  return SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      onPressed: () async {
        // 1. Validasi Input: Pastikan tanggal dan jam sudah dipilih
        if (_tglAmbil == null || _jamAmbil == null || _tglTenggat == null || _jamTenggat == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Harap lengkapi tanggal dan jam pengambilan/tenggat")),
          );
          return;
        }
        try {
          final user = Supabase.instance.client.auth.currentUser;
          if (user == null) return;

          // 2. Gabungkan Tanggal + Jam menjadi DateTime yang valid
          // Jam di UI berformat "07:00", kita ambil jam dan menitnya
          final jamAmbilParts = _jamAmbil!.split(':');
          final dtAmbil = DateTime(
            _tglAmbil!.year, _tglAmbil!.month, _tglAmbil!.day,
            int.parse(jamAmbilParts[0]), int.parse(jamAmbilParts[1]),
          );

          final jamTenggatParts = _jamTenggat!.split(':');
          final dtTenggat = DateTime(
            _tglTenggat!.year, _tglTenggat!.month, _tglTenggat!.day,
            int.parse(jamTenggatParts[0]), int.parse(jamTenggatParts[1]),
          );

          // 3. Simpan ke Tabel 'peminjaman'
          final dataPeminjaman = await Supabase.instance.client
              .from('peminjaman')
              .insert({
                'peminjam_id': user.id,
                'tgl_pengambilan': dtAmbil.toIso8601String(),
                'tenggat': dtTenggat.toIso8601String(),
                'status_transaksi': 'menunggu persetujuan',
              })
              .select()
              .single();

          final int idPeminjamanBaru = dataPeminjaman['id_pinjam'];

          // 4. Simpan ke Tabel 'detail_peminjaman'
          // Menggunakan 'uniqueItems' dan 'groupedItems' yang sudah Anda buat di atas
          final List<Map<String, dynamic>> batchDetails = uniqueItems.map((item) {
            return {
              'id_pinjam': idPeminjamanBaru,
              'id_alat': item.idAlat,
              'jumlah_pinjam': groupedItems[item.idAlat] ?? 1,
            };
          }).toList();

          await Supabase.instance.client.from('detail_peminjaman').insert(batchDetails);

        if (mounted) {
          _showSuccessPopup(); // <--- Panggil fungsi pop-up di sini
        }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.red),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5AB9D5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("Ajukan Pinjam", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D4379))),
    );
  }


  Widget _buildDateTimePicker(String value, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF5AB9D5)),
            const SizedBox(width: 8),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}