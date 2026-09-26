import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SyncStatusCard extends StatelessWidget {
  final bool isSyncing;
  final String statusText;
  final String lastSyncTime;
  final VoidCallback onSyncPressed;

  const SyncStatusCard({
    super.key,
    required this.isSyncing,
    required this.statusText,
    required this.lastSyncTime,
    required this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSyncing ? const Color(0xFFEFF6FF) : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: isSyncing 
              ? const CircularProgressIndicator(color: Color(0xFF3B82F6))
              : const Icon(Icons.cloud_done, size: 48, color: Color(0xFF10B981)),
          ),
          const SizedBox(height: 24),
          Text(
            statusText,
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last sync: $lastSyncTime',
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isSyncing ? null : onSyncPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                isSyncing ? 'Syncing Weights...' : 'Start Federated Training',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
