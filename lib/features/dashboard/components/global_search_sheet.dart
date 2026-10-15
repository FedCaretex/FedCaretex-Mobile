import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../main_screen.dart';

/// Model item pencarian global
class SearchItem {
  final String title;
  final String subtitle;
  final String category; // 'Fitur', 'Klinis', 'Obat', 'Edukasi'
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final int? targetTabIndex; // jika bisa langsung navigasi ke tab navbar
  final String? detailInfo;

  const SearchItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.targetTabIndex,
    this.detailInfo,
  });
}

class GlobalSearchSheet extends ConsumerStatefulWidget {
  const GlobalSearchSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GlobalSearchSheet(),
    );
  }

  @override
  ConsumerState<GlobalSearchSheet> createState() => _GlobalSearchSheetState();
}

class _GlobalSearchSheetState extends ConsumerState<GlobalSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  static const List<String> _categories = [
    'Semua',
    'Fitur',
    'Klinis',
    'Obat',
    'Edukasi',
  ];

  static const List<SearchItem> _allItems = [
    // ── FITUR UTAMA ──────────────────────────────────────────────
    SearchItem(
      title: 'Prediksi Risiko Diabetes',
      subtitle: 'Inferensi AI on-device & analisis kontribusi fitur SHAP',
      category: 'Fitur',
      icon: Icons.analytics_rounded,
      iconBgColor: Color(0xFFF3E8FF),
      iconColor: Color(0xFF9333EA),
      targetTabIndex: 4,
    ),
    SearchItem(
      title: 'Sinkronisasi Federated Learning',
      subtitle: 'Pendaftaran klien, pelatihan lokal DP, dan audit ledger',
      category: 'Fitur',
      icon: Icons.wifi_tethering_rounded,
      iconBgColor: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
      targetTabIndex: 3,
    ),
    SearchItem(
      title: 'Jadwal & Pengingat Obat',
      subtitle: 'Kelola jadwal minum obat dan riwayat kepatuhan',
      category: 'Fitur',
      icon: Icons.medication_rounded,
      iconBgColor: Color(0xFFFFEDD5),
      iconColor: Color(0xFFEA580C),
      targetTabIndex: 2,
    ),
    SearchItem(
      title: 'Grafik & Tren Glukosa',
      subtitle: 'Pantau histori gula darah, HbA1c, dan statistik kesehatan',
      category: 'Fitur',
      icon: Icons.bar_chart_rounded,
      iconBgColor: Color(0xFFD1FAE5),
      iconColor: Color(0xFF059669),
      targetTabIndex: 1,
    ),
    SearchItem(
      title: 'Audit Ledger Blockchain',
      subtitle: 'Verifikasi hash integritas model global via Ganache EVM',
      category: 'Fitur',
      icon: Icons.verified_user_rounded,
      iconBgColor: Color(0xFFE0E7FF),
      iconColor: Color(0xFF4F46E5),
      targetTabIndex: 3,
    ),

    // ── DATA KLINIS & PARAMETER ─────────────────────────────────
    SearchItem(
      title: 'Kadar HbA1c (Hemoglobin A1c)',
      subtitle:
          'Rata-rata gula darah 3 bulan: Normal <5.7%, Pradiabetes 5.7–6.4%',
      category: 'Klinis',
      icon: Icons.bloodtype_rounded,
      iconBgColor: Color(0xFFFFE4E6),
      iconColor: Color(0xFFE11D48),
      detailInfo:
          'HbA1c menggambarkan rata-rata glukosa darah 2-3 bulan terakhir. Target pasien pradiabetes adalah menjaga di bawah 5.7% melalui diet dan olahraga teratur.',
    ),
    SearchItem(
      title: 'Glukosa Darah Puasa (Fasting Glucose)',
      subtitle: 'Target normal <100 mg/dL, Pradiabetes 100–125 mg/dL',
      category: 'Klinis',
      icon: Icons.water_drop_rounded,
      iconBgColor: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
      detailInfo:
          'Diukur setelah berpuasa minimal 8 jam. Nilai 100-125 mg/dL mengindikasikan gangguan toleransi glukosa puasa (IFG).',
    ),
    SearchItem(
      title: 'Indeks Massa Tubuh (BMI)',
      subtitle: 'Berat(kg) / Tinggi(m)². Normal Asia: 18.5 – 22.9 kg/m²',
      category: 'Klinis',
      icon: Icons.monitor_weight_rounded,
      iconBgColor: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
      detailInfo:
          'BMI di atas 23 kg/m² pada populasi Asia diasosiasikan dengan peningkatan resistensi insulin yang signifikan.',
    ),
    SearchItem(
      title: 'Tekanan Darah & Hipertensi',
      subtitle:
          'Batas optimal <120/80 mmHg. Faktor komorbiditas utama diabetes',
      category: 'Klinis',
      icon: Icons.favorite_rounded,
      iconBgColor: Color(0xFFFFE4E6),
      iconColor: Color(0xFFE11D48),
      detailInfo:
          'Hipertensi sering terjadi bersamaan dengan diabetes karena resistensi insulin memicu kekakuan dinding arteri.',
    ),

    // ── OBAT & TERAPI ───────────────────────────────────────────
    SearchItem(
      title: 'Metformin HCl 500 mg',
      subtitle: 'Lini pertama sensitizer insulin, diminum setelah makan',
      category: 'Obat',
      icon: Icons.medication_rounded,
      iconBgColor: Color(0xFFFFEDD5),
      iconColor: Color(0xFFEA580C),
      targetTabIndex: 2,
      detailInfo:
          'Menurunkan produksi glukosa oleh organ hati dan meningkatkan sensitivitas jaringan terhadap insulin.',
    ),
    SearchItem(
      title: 'Glimepiride 2 mg',
      subtitle: 'Golongan Sulfonilurea untuk merangsang pelepasan insulin',
      category: 'Obat',
      icon: Icons.medical_services_rounded,
      iconBgColor: Color(0xFFFEE2E2),
      iconColor: Color(0xFFDC2626),
      targetTabIndex: 2,
      detailInfo:
          'Diminum sebelum sarapan pagi. Perhatikan tanda-tanda hipoglikemia seperti keringat dingin dan pusing.',
    ),
    SearchItem(
      title: 'Acarbose 50 mg',
      subtitle: 'Penghambat alfa-glukosidase, diminum bersama suapan pertama',
      category: 'Obat',
      icon: Icons.health_and_safety_rounded,
      iconBgColor: Color(0xFFD1FAE5),
      iconColor: Color(0xFF059669),
      targetTabIndex: 2,
    ),

    // ── EDUKASI & GAYA HIDUP ────────────────────────────────────
    SearchItem(
      title: 'Latihan Aerobik & Kardio 30 Menit',
      subtitle:
          'Jalan cepat, berenang, atau bersepeda meningkatkan ambilan glukosa',
      category: 'Edukasi',
      icon: Icons.directions_run_rounded,
      iconBgColor: Color(0xFFD1FAE5),
      iconColor: Color(0xFF059669),
      detailInfo:
          'Otot aktif dapat menyerap glukosa darah tanpa tergantung sepenuhnya pada insulin. Lakukan 150 menit per minggu.',
    ),
    SearchItem(
      title: 'Pola Makan Rendah Indeks Glikemik (GI)',
      subtitle: 'Pilih beras merah, gandum utuh, dan perbanyak serat larut',
      category: 'Edukasi',
      icon: Icons.restaurant_rounded,
      iconBgColor: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
      detailInfo:
          'Makanan dengan GI rendah dicerna lebih lambat sehingga tidak memicu lonjakan glukosa darah secara drastis.',
    ),
    SearchItem(
      title: 'Manajemen Stres & Tidur 7-8 Jam',
      subtitle: 'Kortisol tinggi memicu pelepasan glukosa cadangan dari hati',
      category: 'Edukasi',
      icon: Icons.bedtime_rounded,
      iconBgColor: Color(0xFFEDE9FE),
      iconColor: Color(0xFF7C3AED),
      detailInfo:
          'Kurang tidur kronis terbukti menurunkan sensitivitas insulin sebesar 20-30% pada orang dewasa.',
    ),
  ];

  List<SearchItem> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();

    return _allItems.where((item) {
      final matchesCategory =
          _selectedCategory == 'Semua' || item.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;

      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          (item.detailInfo?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _handleItemTap(SearchItem item) {
    if (item.targetTabIndex != null) {
      Navigator.of(context).pop();
      ref.read(bottomNavIndexProvider.notifier).setIndex(item.targetTabIndex!);
    } else if (item.detailInfo != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            item.detailInfo!,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: const Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Mengerti',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredItems;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2132) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Drag Handle ───────────────────────────────────────────
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Title & Close Button ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.navHomeGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pencarian Cerdas',
                      style: GoogleFonts.quicksand(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Search Input Field ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF292C3D) : const Color(0xFFF1F4F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.transparent,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                ),
                decoration: InputDecoration(
                  hintText: 'Cari fitur, obat, metrik klinis, tips...',
                  hintStyle: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF6366F1),
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.cancel_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 18,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Category Filter Chips ─────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;

                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.navHomeGradient : null,
                      color: isSelected
                          ? null
                          : (isDark
                              ? const Color(0xFF292C3D)
                              : const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? const Color(0xFFD1D5DB)
                                  : const Color(0xFF6B7280)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Search Results List ───────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildItemCard(item, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(SearchItem item, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleItemTap(item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252839) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E1B4B),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: item.iconBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: item.iconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                item.targetTabIndex != null
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.info_outline_rounded,
                size: 16,
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF292C3D) : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada hasil ditemukan',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba gunakan kata kunci lain seperti\n"HbA1c", "Metformin", atau "Prediksi"',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
