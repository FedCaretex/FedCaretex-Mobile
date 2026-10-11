import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class AuthBottomSection extends StatelessWidget {
  final VoidCallback onToggle;
  final bool isRegister;

  const AuthBottomSection({
    super.key,
    required this.onToggle,
    this.isRegister = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onToggle,
      child: Text(
        isRegister ? 'Sudah punya akun? Masuk' : 'Belum punya akun? Daftar',
        style: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
