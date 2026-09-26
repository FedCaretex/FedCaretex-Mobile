import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';

class QuickSettingsSheet extends StatefulWidget {
  const QuickSettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ,
      builder: (_) => const QuickSettingsSheet(),
    )
  }
}
