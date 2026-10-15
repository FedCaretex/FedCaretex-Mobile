import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String? photoUrl;
  final VoidCallback onAvatarTap;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;
  final int unreadCount;

  const ProfileHeader({
    super.key,
    required this.userName,
    this.photoUrl,
    required this.onAvatarTap,
    required this.onSearchTap,
    required this.onNotificationTap,
    this.unreadCount = 3,
  });

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';

    final words = trimmed.split(RegExp(r'\s+'));
    return words
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = _getInitials(userName);
    final fontSize = initials.length > 2 ? 13.0 : (initials.length == 2 ? 15.0 : 18.0);
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    final initialsWidget = Text(
      initials,
      style: GoogleFonts.quicksand(
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
        letterSpacing: 0.5,
        color: const Color(0xFF4F46E5),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Avatar & Greeting ───────────────────────────────────────
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    gradient: AppColors.navHomeGradient,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: isDark
                        ? const Color(0xFF292C3D)
                        : const Color(0xFFEDE9FE),
                    child: hasPhoto
                        ? ClipOval(
                            child: Image.network(
                              photoUrl!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  initialsWidget,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : initialsWidget,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $userName! ',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kesehatanmu terpantau aman',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Search & Notification Buttons ───────────────────────────
        Row(
          children: [
            _buildActionButton(
              icon: Icons.search_rounded,
              tooltip: 'Pencarian',
              onTap: onSearchTap,
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notifikasi',
              onTap: onNotificationTap,
              isDark: isDark,
              badgeCount: unreadCount,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
    int badgeCount = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252839) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: badgeCount > 0
                ? Badge(
                    label: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: const Color(0xFFEF4444),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isDark ? Colors.white : const Color(0xFF4B5563),
                    ),
                  )
                : Icon(
                    icon,
                    size: 22,
                    color: isDark ? Colors.white : const Color(0xFF4B5563),
                  ),
          ),
        ),
      ),
    );
  }
}
