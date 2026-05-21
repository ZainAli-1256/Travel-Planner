import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NotificationItem(
        title: 'Trip reminder',
        subtitle: 'Paris trip starts in 2 days',
        time: '2h ago',
        icon: Icons.calendar_month_rounded,
      ),
      _NotificationItem(
        title: 'New chat message',
        subtitle: 'Alex: Can we add the museum?',
        time: '5h ago',
        icon: Icons.forum_rounded,
      ),
      _NotificationItem(
        title: 'Weather update',
        subtitle: 'Rain expected on Day 2 in Paris',
        time: '1d ago',
        icon: Icons.cloud_rounded,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        title: Text('Notifications',
            style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.navyDeep,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: AppColors.amber),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: GoogleFonts.inter(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(item.subtitle,
                          style: GoogleFonts.inter(
                              color: AppColors.slate400, fontSize: 12)),
                    ],
                  ),
                ),
                Text(item.time,
                    style: GoogleFonts.inter(
                        color: AppColors.slate400, fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });
}
