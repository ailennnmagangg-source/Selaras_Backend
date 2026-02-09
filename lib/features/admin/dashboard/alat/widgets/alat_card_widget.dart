import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class AlatCardWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AlatCardWidget({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String namaKategori = data['kategori'] != null 
        ? data['kategori']['nama_kategori'] 
        : 'Tanpa Kategori';
        
    final String? fotoUrl = data['foto_url'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Bagian Gambar (Sekarang Bersih Tanpa Ikon Melayang)
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                "${fotoUrl ?? 'https://via.placeholder.com/150'}?t=${DateTime.now().millisecondsSinceEpoch}",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[100],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          
          // 2. Detail Teks
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['nama_alat'] ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF2D4379)
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  namaKategori, 
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])
                ),
                const SizedBox(height: 8),

                // 3. Baris Stok Sejajar dengan Ikon Edit & Delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Label Stok
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Stok ${data['stok_total']}",
                        style: const TextStyle(
                          fontSize: 11, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.green
                        ),
                      ),
                    ),
                    
                    // Grup Tombol Aksi Sejajar Horizontal
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onEdit,
                          child: const Icon(Icons.edit, size: 18, color: Colors.cyan),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: onDelete,
                          child: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}