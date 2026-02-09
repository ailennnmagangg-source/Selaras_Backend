import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selaras_backend/features/peminjam/katalog/logic/alat_model.dart';

class PeminjamanFormScreen extends StatefulWidget {
  final List<AlatModel> selectedItems;
  const PeminjamanFormScreen({super.key, required this.selectedItems});

  @override
  State<PeminjamanFormScreen> createState() => _PeminjamanFormScreenState();
}

class _PeminjamanFormScreenState extends State<PeminjamanFormScreen> {
  final _namaController = TextEditingController();
  
  DateTime? _tglAmbil;
  String? _jamAmbil; // Diubah jadi String untuk menyimpan hasil seleksi list
  DateTime? _tglTenggat;
  String? _jamTenggat;

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
    // List jam operasional dummy
    final List<String> times = [
      "07:00", "08:00", "09:00", "10:00", "11:00", 
      "12:00", "13:00", "14:00", "15:00", "16:00"
    ];

    showDialog(
      context: context,
      builder: (context) {
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
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: times.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(times[index]),
                  onTap: () {
                    setState(() {
                      if (isAmbil) {
                        _jamAmbil = times[index];
                      } else {
                        _jamTenggat = times[index];
                      }
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
          ],
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

            // List Alat
            ...uniqueItems.map((item) {
              final count = groupedItems[item.idAlat] ?? 0;
              return _buildAlatCard(item, count);
            }).toList(),

            _buildTambahButton(),
            const Divider(height: 40, thickness: 1, color: Color(0xFFE0E0E0)),

            _buildLabel("Nama Peminjam"),
            _buildTextField("Masukkan nama peminjam", _namaController),
            
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
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
              // Gambar dummy jika URL kosong
              image: item.fotoUrl != null ? DecorationImage(image: NetworkImage(item.fotoUrl!), fit: BoxFit.cover) : null,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.namaAlat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D4379))),
                Text(item.namaKategori, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text("Dipinjam $count", style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
        ],
      ),
    );
  }

  Widget _buildTambahButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {},
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
        onPressed: () {
          // Hanya Dummy Feedback
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tombol ditekan (Mode UI)")));
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

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
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