import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/chat_message_model.dart';
import '../../models/trip_model.dart';
import '../../services/firestore_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.navyDeep,
        appBar: AppBar(
          title: Text('Notifications',
              style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
        ),
        body: Center(
          child: Text(
            'Log in to see notifications.',
            style: GoogleFonts.inter(color: AppColors.slate400),
          ),
        ),
      );
    }

    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        title: Text('Notifications',
            style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<List<TripModel>>(
        stream: firestoreService.streamMemberTrips(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.amber),
            );
          }

          final trips = snapshot.data ?? [];
          if (trips.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: GoogleFonts.inter(color: AppColors.slate400),
              ),
            );
          }

          final reminders = _buildTripReminders(trips);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _SectionTitle(label: 'Trip Reminders'),
              const SizedBox(height: 12),
              if (reminders.isEmpty)
                _EmptySection(message: 'No upcoming trips right now.')
              else
                ...reminders.map((item) => _NotificationTile(item: item)),
              const SizedBox(height: 24),
              _SectionTitle(label: 'Latest Messages'),
              const SizedBox(height: 12),
              if (trips.isEmpty)
                _EmptySection(message: 'No trip chats yet.')
              else
                ...trips.map((trip) => _LatestMessageTile(trip: trip)),
            ],
          );
        },
      ),
    );
  }
}

List<_NotificationItem> _buildTripReminders(List<TripModel> trips) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final upcoming = trips
      .where((trip) => !trip.startDate.isBefore(today))
      .toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));

  return upcoming.take(6).map((trip) {
    final days = trip.startDate.difference(today).inDays;
    final dayLabel = days == 0
        ? 'starts today'
        : days == 1
            ? 'starts tomorrow'
            : 'starts in $days days';

    return _NotificationItem(
      title: 'Trip reminder',
      subtitle: '${trip.title} • ${trip.destination} $dayLabel',
      time: DateFormat('MMM d').format(trip.startDate),
      icon: Icons.calendar_month_rounded,
    );
  }).toList();
}

class _LatestMessageTile extends StatelessWidget {
  final TripModel trip;

  const _LatestMessageTile({required this.trip});

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('trips')
        .doc(trip.tripId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(1);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: messagesRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _SkeletonTile();
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _EmptyMessageTile(trip: trip);
        }

        final msg = ChatMessageModel.fromMap(docs.first.data());
        final item = _NotificationItem(
          title: trip.title,
          subtitle: '${msg.senderName}: ${msg.text}',
          time: _formatTime(msg.sentAt),
          icon: Icons.forum_rounded,
        );

        return _NotificationTile(item: item);
      },
    );
  }
}

String _formatTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('MMM d').format(date);
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.sora(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 12),
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

class _NotificationTile extends StatelessWidget {
  final _NotificationItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                        color: AppColors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(item.subtitle,
                    style: GoogleFonts.inter(
                        color: AppColors.slate400, fontSize: 12)),
              ],
            ),
          ),
          Text(item.time,
              style:
                  GoogleFonts.inter(color: AppColors.slate400, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.navyDeep,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.navyDeep,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessageTile extends StatelessWidget {
  final TripModel trip;

  const _EmptyMessageTile({required this.trip});

  @override
  Widget build(BuildContext context) {
    return _NotificationTile(
      item: _NotificationItem(
        title: trip.title,
        subtitle: 'No messages yet in this trip chat.',
        time: '',
        icon: Icons.forum_rounded,
      ),
    );
  }
}
