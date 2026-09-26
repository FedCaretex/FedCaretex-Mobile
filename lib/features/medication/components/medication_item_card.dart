import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/medication_model.dart';

class MedicationItemCard extends StatelessWidget {
  final MedicationSchedule medication;
  final VoidCallback onToggle;

  const MedicationItemCard({
    super.key,
    required this.medication,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: medication.isTaken ? const Color(0xFFD1FAE5) : const Color(0xFFFBD4D4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication_liquid,
                  color: medication.isTaken ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${medication.time} • ${medication.dosage}',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: medication.isTaken ? const Color(0xFF2E7D32) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: medication.isTaken ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: medication.isTaken ? Colors.white : Colors.transparent,
              ),
            ),
          )
        ],
      ),
    );
  }
}
