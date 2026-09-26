import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BentoSquareCard extends StatelessWidget {
  final String title;
  final String description;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onTap;

  const BentoSquareCard({
    super.key,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: Colors.black87),
                ),
              ],
            ),
            Text(
              description,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Check',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 16, color: Colors.black87),
              ],
            )
          ],
        ),
      ),
    );
  }
}
