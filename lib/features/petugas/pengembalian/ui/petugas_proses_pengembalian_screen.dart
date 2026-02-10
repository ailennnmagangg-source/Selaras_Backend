import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PetugasProsesPengembalianScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  const PetugasProsesPengembalianScreen({super.key, required this.item});

  @override
  State<PetugasProsesPengembalianScreen> createState() => _PetugasProsesPengembalianScreenState();
}

class _PetugasProsesPengembalianScreenState extends State<PetugasProsesPengembalianScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> listAlat = [];
  bool isLoading = false;
  bool isFetchingAlat = true;

  // State untuk Input Tanggal dan Jam
  DateTime selectedDate = DateTime.now();
  // Default jam operasional pertama (07:00)
  String _selectedTimeStr = "07:00"; 
  
  int dendaPerHari = 5000;

  @override
  void initState() {
    super.initState();
    _fetchDetailAlat();
  }

  Future<void> _fetchDetailAlat() async {
    try {
      final data = await supabase
          .from('detail_peminjaman')
          .select('jumlah_pinjam, alat(nama_alat, foto_url, kategori(nama_kategori))')
          .eq('id_pinjam', widget.item['id_pinjam']);
      
      setState(() {
        listAlat = List<Map<String, dynamic>>.from(data);
        isFetchingAlat = false;
      });
    } catch (e) {
      debugPrint("Error fetch alat: $e");
    }
  }

  // --- CUSTOM TIME PICKER SESUAI JAM OPERASIONAL ---
  void _showTimePickerList() {
    final List<String> times = [
      "07:00", "08:00", "09:00", "10:00", "11:00", 
      "12:00", "13:00", "14:00"
    ];

    String temporarySelectedTime = _selectedTimeStr;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              backgroundColor: Colors.white,
              title: const Text(
                "Jam Operasional",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D4379)),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 300,
                child: ListView.builder(
                  itemCount: times.length,
                  itemBuilder: (context, index) {
                    bool isSelected = temporarySelectedTime == times[index];
                    return ListTile(
                      title: Text(times[index], 
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF5AB9D5) : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                        )
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF5AB9D5)) : null,
                      onTap: () => setDialogState(() => temporarySelectedTime = times[index]),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _selectedTimeStr = temporarySelectedTime);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5AB9D5)),
                  child: const Text("Pilih", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _hitungTotalDenda() {
    try {
      DateTime tenggat = DateTime.parse(widget.item['tenggat']);
      final timeParts = _selectedTimeStr.split(':');
      DateTime pengembalian = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day,
        int.parse(timeParts[0]), int.parse(timeParts[1])
      );

      if (pengembalian.isAfter(tenggat)) {
        Duration selisih = pengembalian.difference(tenggat);
        // Menghitung denda: Jika telat (meski hanya beberapa jam), dihitung 1 hari
        int jumlahHariTelat = (selisih.inMinutes / (24 * 60)).ceil();
        return jumlahHariTelat * dendaPerHari;
      }
    } catch (e) {
      debugPrint("Error hitung denda: $e");
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    int totalDenda = _hitungTotalDenda();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Proses Pengembalian", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeaderModern(),
            const SizedBox(height: 25),
            const Text("Waktu Pengembalian", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildActiveInput(DateFormat('dd/MM/yyyy').format(selectedDate), Icons.calendar_today, () async {
                  final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2024), lastDate: DateTime(2101));
                  if (picked != null) setState(() => selectedDate = picked);
                }),
                const SizedBox(width: 12),
                _buildActiveInput(_selectedTimeStr, Icons.access_time, () => _showTimePickerList()),
              ],
            ),
            const SizedBox(height: 30),
            if (isFetchingAlat) const Center(child: CircularProgressIndicator()) 
            else ...listAlat.map((alat) => _buildAlatCardModern(alat)).toList(),
            const Divider(height: 40),
            _buildDendaRow("Denda Keterlambatan", "Rp ${NumberFormat('#,###').format(totalDenda)}"),
            const SizedBox(height: 12),
            _buildDendaRow("Total Denda", "Rp ${NumberFormat('#,###').format(totalDenda)}", isTotal: true),
            const SizedBox(height: 40),
            
            // TOMBOL SELESAI
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setState(() => isLoading = true);
                  try {
                    final timeParts = _selectedTimeStr.split(':');
                    final DateTime waktuSelesai = DateTime(
                      selectedDate.year, selectedDate.month, selectedDate.day,
                      int.parse(timeParts[0]), int.parse(timeParts[1])
                    );
                    
                    // Jika totalDenda > 0 maka status 'denda', jika tidak maka 'selesai'
                    String statusBaru = totalDenda > 0 ? 'denda' : 'selesai';

                    // 1. Update tabel peminjaman (Tanpa kolom total_denda)
                    await supabase.from('peminjaman').update({
                      'status_transaksi': statusBaru,
                      'tgl_pengembalian': waktuSelesai.toIso8601String(),
                      // 'total_denda': totalDenda, <-- HAPUS BARIS INI KARENA ERROR
                    }).eq('id_pinjam', widget.item['id_pinjam']);

                    // 2. Insert ke tabel denda (Jika ada denda)
                    if (totalDenda > 0) {
                      await supabase.from('denda').insert({
                        'id_kembali': widget.item['id_pinjam'], // Sesuaikan dengan relasi di DB kamu
                        'total_denda': totalDenda,
                        'jumlah_terlambat': (totalDenda / dendaPerHari).ceil(),
                        'tarif_per_hari': dendaPerHari,
                        'created_at': DateTime.now().toIso8601String(),
                      });
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pengembalian Berhasil Disimpan"))
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  } finally {
                    if (mounted) setState(() => isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5AB9D5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Selesai", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildUserHeaderModern() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFF1F4F8),
                child: Icon(Icons.person, color: Colors.blueGrey),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item['nama_users'] ?? "Peminjam",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: const Color(0xFF5AB9D5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(widget.item['tipe_user'] ?? "User",
                        style: const TextStyle(
                            color: Color(0xFF5AB9D5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Menggunakan null check agar tidak crash
              _buildMiniDateInfo("Pengambilan", widget.item['tgl_pengambilan'] ?? widget.item['tgl_pinjam']), 
              _buildMiniDateInfo("Tenggat", widget.item['tenggat']),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniDateInfo(String label, String? dateStr) {
    // Jika dateStr null, tampilkan "-" agar tidak error subtype 'Null'
    String formattedDate = "-";
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        DateTime date = DateTime.parse(dateStr);
        formattedDate = DateFormat('dd MMM yyyy | HH:mm').format(date);
      } catch (e) {
        formattedDate = "Format Salah";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildActiveInput(String val, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF5AB9D5).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF5AB9D5)),
              const SizedBox(width: 10),
              Text(val, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D4379))),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlatCardModern(Map<String, dynamic> alat) {
    final String? fotoUrl = alat['alat']['foto_url'];
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60, height: 60, color: const Color(0xFFF8FAFC),
              child: fotoUrl != null ? Image.network(fotoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)) : const Icon(Icons.image),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alat['alat']['nama_alat'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Jumlah: ${alat['jumlah_pinjam']}", style: const TextStyle(color: Color(0xFF22C55E), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDendaRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.black : Colors.grey, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500, fontSize: isTotal ? 16 : 14)),
        Text(value, style: TextStyle(color: isTotal ? const Color(0xFF5AB9D5) : Colors.black, fontWeight: FontWeight.bold, fontSize: isTotal ? 18 : 14)),
      ],
    );
  }
}