import 'package:flutter/material.dart';
// Import model pusat
import 'package:selaras_backend/features/shared/models/alat_model.dart';

class AlatCard extends StatelessWidget {
  final AlatModel alat;
  final String namaKategori;
  final VoidCallback onAdd;

  const AlatCard({
    super.key,
    required this.alat,
    required this.namaKategori,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    bool isOutOfStock = alat.stokTotal <= 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5AB9D5).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF5AB9D5).withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: alat.fotoUrl != null && alat.fotoUrl!.isNotEmpty
                    ? Image.network(
                        alat.fotoUrl!,
                        fit: BoxFit.cover, // Agar gambar memenuhi area kartu
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Tampilan jika link gambar rusak atau tidak ditemukan
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.broken_image_outlined, color: Colors.grey),
                              Text(namaKategori, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          );
                        },
                      )
                    : const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alat.namaAlat,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF2D4379),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        namaKategori, 
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOutOfStock 
                            ? Colors.red.withOpacity(0.1) 
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isOutOfStock ? "Kosong" : "Stok: ${alat.stokTotal}",
                        style: TextStyle(
                          fontSize: 9, 
                          fontWeight: FontWeight.bold, 
                          color: isOutOfStock ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton(
                    onPressed: isOutOfStock ? null : onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5AB9D5),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[200],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, size: 16),
                        SizedBox(width: 4),
                        Text(
                          "Tambah",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}