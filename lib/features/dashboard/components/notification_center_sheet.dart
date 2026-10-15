import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../main_screen.dart';

enum NotificationCategory { medication, flAi, clinical, privacy }

class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final NotificationCategory category;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final int? targetTabIndex;
  bool isRead;

  AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.category,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.targetTabIndex,
    this.isRead = false,
  });
}

class NotificationCenterSheet extends ConsumerStatefulWidget {
  const NotificationCenterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationCenterSheet(),
    );
  }

  @override
  ConsumerState<NotificationCenterSheet> createState() =>
      _NotificationCenterSheetState();
}

class _NotificationCenterSheetState
    extends ConsumerState<NotificationCenterSheet> {
  String _selectedFilter = 'Semua';

  static final List<AppNotificationItem> _notifications = [
    AppNotificationItem(
      id: 'notif_1',
      title: 'Waktunya Minum Obat Siang',
      message:
          'Metformin HCl 500 mg (1 tablet setelah makan siang). Jangan terlewat!',
      timeAgo: '15 mnt lalu',
      category: NotificationCategory.medication,
      icon: Icons.medication_rounded,
      iconBgColor: const Color(0xFFFFEDD5),
      iconColor: const Color(0xFFEA580C),
      targetTabIndex: 2,
      isRead: false,
    ),
    AppNotificationItem(
      id: 'notif_2',
      title: 'Global Model Round #3 Tersedia',
      message:
          'Server Federated Learning merilis model baru. Verifikasi ledger dan mulai pelatihan lokal.',
      timeAgo: '1 jam lalu',
      category: NotificationCategory.flAi,
      icon: Icons.wifi_tethering_rounded,
      iconBgColor: const Color(0xFFE0F2FE),
      iconColor: const Color(0xFF0284C7),
      targetTabIndex: 3,
      isRead: false,
    ),
    AppNotificationItem(
      id: 'notif_3',
      title: 'Pembaruan Analisis SHAP',
      message:
          'Faktor HbA1c & Fasting Glucose memberikan kontribusi tertinggi pada prediksi risiko pradiabetes Anda.',
      timeAgo: '3 jam lalu',
      category: NotificationCategory.clinical,
      icon: Icons.analytics_rounded,
      iconBgColor: const Color(0xFFF3E8FF),
      iconColor: const Color(0xFF7C3AED),
      targetTabIndex: 4,
      isRead: false,
    ),
    AppNotificationItem(
      id: 'notif_4',
      title: 'Differential Privacy Aktif',
      message:
          'Noise Gaussian kriptografis telah diaplikasikan pada bobot lokal sebelum tanda tangan Ed25519.',
      timeAgo: 'Kemarin',
      category: NotificationCategory.privacy,
      icon: Icons.security_rounded,
      iconBgColor: const Color(0xFFD1FAE5),
      iconColor: const Color(0xFF059669),
      targetTabIndex: 3,
      isRead: true,
    ),
    AppNotificationItem(
      id: 'notif_5',
      title: 'Glukosa Darah Mingguan Stabil',
      message:
          'Rata-rata gula darah 7 hari terakhir berada di kisaran 108 mg/dL (Zona Terkendali Baik).',
      timeAgo: '2 hari lalu',
      category: NotificationCategory.clinical,
      icon: Icons.insights_rounded,
      iconBgColor: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFD97706),
      targetTabIndex: 1,
      isRead: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<AppNotificationItem> get _filteredList {
    if (_selectedFilter == 'Semua') return _notifications;
    if (_selectedFilter == 'Obat') {
      return _notifications
          .where((n) => n.category == NotificationCategory.medication)
          .toList();
    }
    if (_selectedFilter == 'FL AI') {
      return _notifications
          .where((n) =>
              n.category == NotificationCategory.flAi ||
              n.category == NotificationCategory.privacy)
          .toList();
    }
    if (_selectedFilter == 'Klinis') {
      return _notifications
          .where((n) => n.category == NotificationCategory.clinical)
          .toList();
    }
    return _notifications;
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _handleItemTap(AppNotificationItem item) {
    setState(() {
      item.isRead = true;
    });

    if (item.targetTabIndex != null) {
      Navigator.of(context).pop();
      ref.read(bottomNavIndexProvider.notifier).setIndex(item.targetTabIndex!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _filteredList;
    final unread = _unreadCount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
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

          // ── Header Title & Actions ────────────────────────────────
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
                        gradient: AppColors.navMedicationGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pusat Notifikasi',
                      style: GoogleFonts.quicksand(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                      ),
                    ),
                    if (unread > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$unread Baru',
                          style: GoogleFonts.quicksand(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
          const SizedBox(height: 10),

          // ── Sub-header: Quick Action (Mark all as read) ───────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktivitas & pengingat kesehatan terkini',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
                if (unread > 0)
                  GestureDetector(
                    onTap: _markAllAsRead,
                    child: Text(
                      'Tandai dibaca',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Filter Chips ──────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFilterChip('Semua', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Obat', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('FL AI', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Klinis', isDark),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Notifications List ────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildNotificationCard(item, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.navMedicationGradient : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF292C3D) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
  }

  Widget _buildNotificationCard(AppNotificationItem item, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleItemTap(item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead
                ? (isDark ? const Color(0xFF242738) : const Color(0xFFF9FAFB))
                : (isDark ? const Color(0xFF2E3247) : const Color(0xFFEFF6FF)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead
                  ? (isDark ? Colors.white10 : const Color(0xFFE5E7EB))
                  : const Color(0xFF93C5FD),
              width: item.isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.quicksand(
                              fontWeight: item.isRead
                                  ? FontWeight.bold
                                  : FontWeight.w800,
                              fontSize: 15,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E1B4B),
                            ),
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.message,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFFD1D5DB)
                            : const Color(0xFF4B5563),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.timeAgo,
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        if (item.targetTabIndex != null)
                          Row(
                            children: [
                              Text(
                                'Buka Fitur',
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
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
              Icons.notifications_off_rounded,
              size: 48,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Semua pengingat dan aktivitas\nkesehatan Anda telah selesai',
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
