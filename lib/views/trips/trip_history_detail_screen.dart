import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/itinerary_item_model.dart';
import '../../models/trip_model.dart';
import '../../services/firestore_service.dart';
import 'trip_detail_screen.dart';

class TripHistoryDetailScreen extends StatefulWidget {
  final TripModel trip;

  const TripHistoryDetailScreen({super.key, required this.trip});

  @override
  State<TripHistoryDetailScreen> createState() =>
      _TripHistoryDetailScreenState();
}

class _TripHistoryDetailScreenState extends State<TripHistoryDetailScreen> {
  final _firestoreService = FirestoreService();
  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _reuseTrip() async {
    final titleCtrl =
        TextEditingController(text: '${widget.trip.title} (Copy)');
    DateTimeRange? range;

    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.navyDeep,
              title: Text('Reuse Plan',
                  style: GoogleFonts.sora(color: AppColors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    style: GoogleFonts.inter(color: AppColors.white),
                    decoration: InputDecoration(
                      labelText: 'New trip title',
                      labelStyle: GoogleFonts.inter(color: AppColors.slate400),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) {
                        setState(() => range = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_month_rounded,
                        color: AppColors.navyDeep),
                    label: const Text('Select new dates',
                        style: TextStyle(color: AppColors.navyDeep)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amber),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    range == null
                        ? 'No dates selected'
                        : '${DateFormat('MMM d, yyyy').format(range!.start)} - ${DateFormat('MMM d, yyyy').format(range!.end)}',
                    style: GoogleFonts.inter(
                        color: AppColors.slate400, fontSize: 13),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.slate400)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Create',
                      style: TextStyle(color: AppColors.amber)),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldContinue != true || range == null) return;

    final newTripId = await _firestoreService.duplicateTrip(
      sourceTrip: widget.trip,
      newStartDate: range!.start,
      newEndDate: range!.end,
      createdBy: _currentUid,
      titleOverride:
          titleCtrl.text.trim().isEmpty ? null : titleCtrl.text.trim(),
    );

    final newTrip = await _firestoreService.getTrip(newTripId);
    if (newTrip != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TripDetailScreen(trip: newTrip)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        title: Text('Trip History',
            style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: _reuseTrip,
            icon: const Icon(Icons.copy_rounded, color: AppColors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.trip.title,
                style: GoogleFonts.sora(
                    color: AppColors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(widget.trip.destination,
                style: GoogleFonts.inter(color: AppColors.slate400)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.glassBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoItem(
                      label: 'Dates',
                      value: AppHelpers.formatDateRange(
                          widget.trip.startDate, widget.trip.endDate)),
                  _InfoItem(
                      label: 'Duration',
                      value: '${widget.trip.durationDays} days'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Itinerary',
                style: GoogleFonts.sora(
                    color: AppColors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            StreamBuilder<List<ItineraryItemModel>>(
              stream: _firestoreService.streamItinerary(widget.trip.tripId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.amber));
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Text('No itinerary items found.',
                      style: GoogleFonts.inter(color: AppColors.slate400));
                }
                return Column(
                  children: items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.glassBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.amber),
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
                                Text(item.startTime ?? item.dayLabel,
                                    style: GoogleFonts.inter(
                                        color: AppColors.slate400,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(DateFormat('MMM d').format(item.date),
                              style: GoogleFonts.inter(
                                  color: AppColors.slate400, fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.inter(
                color: AppColors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
