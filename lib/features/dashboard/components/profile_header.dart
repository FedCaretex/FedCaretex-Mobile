import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.avatarUrl,
    required this.onSearchTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName!',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: onSearchTap,
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: onNotificationTap,
              icon: const Badge(
                child: Icon(Icons.notifications_none),
              ),
            ),
          ],
        )
      ],
    );
  }
}
