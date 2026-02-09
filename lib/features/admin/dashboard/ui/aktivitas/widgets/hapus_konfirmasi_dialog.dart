import 'package:flutter/material.dart';

class HapusDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Hapus", textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
      content: Text("Apakah anda yakin menghapus peminjaman ini?", textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context), 
          child: Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            // Jalankan fungsi hapus di sini
            Navigator.pop(context);
          }, 
          child: Text("Iya"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
        ),
      ],
    );
  }
}