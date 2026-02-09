import 'package:flutter/material.dart';
// Import model pusat
import 'package:selaras_backend/features/shared/models/alat_model.dart';

import '../logic/alat_model.dart';

class AlatCard extends StatelessWidget {
  final AlatModel alat;
  final VoidCallback onAdd;

  const AlatCard({
    super.key,
    required this.alat,
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
              child: Hero(
                tag: 'alat_${alat.idAlat}',
                child: Icon(
                  _getIconForKategori(alat.namaKategori),
                  size: 50,
                  color: const Color(0xFF5AB9D5).withOpacity(0.5),
                ),
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
                        alat.namaKategori, 
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

  IconData _getIconForKategori(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'elektronik':
        return Icons.devices_rounded;
      case 'pertukangan':
        return Icons.build_rounded;
      case 'kesehatan':
        return Icons.medical_services_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }
}