import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditTanggalDialog extends StatefulWidget {
  final int idPinjam;

  const EditTanggalDialog({super.key, required this.idPinjam});

  @override
  State<EditTanggalDialog> createState() => _EditTanggalDialogState();
}

class _EditTanggalDialogState extends State<EditTanggalDialog> {

  DateTime? ambilDateTime;
  DateTime? tenggatDateTime;

  final TextEditingController ambilController = TextEditingController();
  final TextEditingController tenggatController = TextEditingController();

  // ================= DATE PICKER =================
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    bool isAmbil,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        // jam default
        final dt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          isAmbil ? 8 : 16, // ambil 08:00, tenggat 16:00
          0,
        );

        controller.text =
            "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";

        if (isAmbil) {
          ambilDateTime = dt;
        } else {
          tenggatDateTime = dt;
        }
      });
    }
  }


  // ================= UPDATE SUPABASE =================
  Future<void> updateTanggal() async {
    try {

      if (ambilDateTime == null || tenggatDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tanggal belum dipilih")),
        );
        return;
      }

      await Supabase.instance.client
          .from('peminjaman')
          .update({
            'tgl_pengambilan': ambilDateTime!.toIso8601String(),
            'tenggat': tenggatDateTime!.toIso8601String(),
          })
          .eq('id_pinjam', widget.idPinjam);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil update tanggal"),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print("ERROR UPDATE: $e");
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "Edit Tanggal",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B4C7E),
              ),
            ),

            const SizedBox(height: 20),

            _buildDateField("Pengambilan", ambilController, true),
            const SizedBox(height: 15),
            _buildDateField("Tenggat", tenggatController, false),

            const SizedBox(height: 30),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton(
                    onPressed: updateTanggal,
                    child: const Text("Iya"),
                  ),
                ),

              ],
            )
          ],
        ),
      ),
    );
  }

  // ================= WIDGET FIELD =================
  Widget _buildDateField(
    String label,
    TextEditingController controller,
    bool isAmbil,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context, controller, isAmbil),
        ),
      ],
    );
  }


  String _getMonthName(int month) {
    const months = [
      "Jan","Feb","Mar","Apr","Mei","Jun",
      "Jul","Agu","Sep","Okt","Nov","Des"
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    ambilController.dispose();
    tenggatController.dispose();
    super.dispose();
  }
}
