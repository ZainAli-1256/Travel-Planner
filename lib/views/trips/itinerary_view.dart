import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/trip_model.dart';
import '../../../models/itinerary_item_model.dart';
import '../../../services/firestore_service.dart';

class ItineraryView extends StatefulWidget {
  final String tripId;
  final TripModel trip;

  const ItineraryView({super.key, required this.tripId, required this.trip});

  @override
  State<ItineraryView> createState() => _ItineraryViewState();
}

class _ItineraryViewState extends State<ItineraryView> {
  final _firestoreService = FirestoreService();

  Future<void> _showAddItemDialog() async {
    final titleCtrl = TextEditingController();
    final placeCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'activity';
    DateTime selectedDate = widget.trip.startDate;
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.navyDeep,
            title: Text('Add Plan',
                style: GoogleFonts.sora(color: AppColors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: AppColors.slate400),
                    ),
                  ),
                  TextField(
                    controller: placeCtrl,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Start time',
                      labelStyle: TextStyle(color: AppColors.slate400),
                    ),
                  ),
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      labelStyle: TextStyle(color: AppColors.slate400),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: category,
                    dropdownColor: AppColors.navyDeep,
                    style: const TextStyle(color: AppColors.white),
                    items: ['activity', 'food', 'transport', 'hotel']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => category = v);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: widget.trip.startDate,
                        lastDate: widget.trip.endDate,
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_month_rounded,
                        color: AppColors.amber),
                    label: Text(
                      DateFormat('MMM d, yyyy').format(selectedDate),
                      style: GoogleFonts.inter(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.slate400)),
              ),
              TextButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (titleCtrl.text.trim().isEmpty) {
                          AppHelpers.showSnack(context, 'Please enter a title');
                          return;
                        }
                        setState(() => isSaving = true);
                        try {
                          await _firestoreService.addItineraryItem(
                            tripId: widget.tripId,
                            dayLabel: DateFormat('MMM d').format(selectedDate),
                            date: selectedDate,
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim().isEmpty
                                ? null
                                : descCtrl.text.trim(),
                            category: category,
                            startTime: placeCtrl.text.trim().isEmpty
                                ? null
                                : placeCtrl.text.trim(),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            AppHelpers.showSnack(
                                context, 'Plan saved successfully');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppHelpers.showSnack(context, 'Failed to save plan',
                                isError: true);
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() => isSaving = false);
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.amber,
                        ),
                      )
                    : const Text('Save',
                        style: TextStyle(color: AppColors.amber)),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showEditItemDialog(ItineraryItemModel item) async {
    final titleCtrl = TextEditingController(text: item.title);
    final timeCtrl = TextEditingController(text: item.startTime ?? '');
    final descCtrl = TextEditingController(text: item.description ?? '');
    String category = item.category;
    DateTime selectedDate = item.date;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.navyDeep,
              title: Text('Edit Plan',
                  style: GoogleFonts.sora(color: AppColors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: AppColors.slate400),
                      ),
                    ),
                    TextField(
                      controller: timeCtrl,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                        labelText: 'Estimated Time',
                        labelStyle: TextStyle(color: AppColors.slate400),
                      ),
                    ),
                    TextField(
                      controller: descCtrl,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        labelStyle: TextStyle(color: AppColors.slate400),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
                      value: category,
                      dropdownColor: AppColors.navyDeep,
                      style: const TextStyle(color: AppColors.white),
                      items: ['activity', 'food', 'transport', 'hotel']
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => category = v);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: widget.trip.startDate,
                          lastDate: widget.trip.endDate,
                        );
                        if (picked != null)
                          setState(() => selectedDate = picked);
                      },
                      icon: const Icon(Icons.calendar_month_rounded,
                          color: AppColors.amber),
                      label: Text(
                        DateFormat('MMM d, yyyy').format(selectedDate),
                        style: GoogleFonts.inter(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.slate400)),
                ),
                TextButton(
                  onPressed: () async {
                    if (titleCtrl.text.isEmpty) return;
                    await _firestoreService.updateItineraryItem(
                      widget.tripId,
                      item.itemId,
                      {
                        'title': titleCtrl.text.trim(),
                        'startTime': timeCtrl.text.trim(),
                        'description': descCtrl.text.trim().isEmpty
                            ? null
                            : descCtrl.text.trim(),
                        'category': category,
                        'date': selectedDate.millisecondsSinceEpoch,
                        'dayLabel': DateFormat('MMM d').format(selectedDate),
                      },
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save',
                      style: TextStyle(color: AppColors.amber)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ItineraryItemModel>>(
            stream: _firestoreService.streamItinerary(widget.tripId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.amber));
              }
              final items = snapshot.data ?? [];
              final sortedItems = [...items]..sort((a, b) {
                  final dateCompare = a.date.compareTo(b.date);
                  if (dateCompare != 0) return dateCompare;
                  return a.sortOrder.compareTo(b.sortOrder);
                });
              if (sortedItems.isEmpty) {
                return Center(
                  child: Text(
                    'No plans added yet.',
                    style: GoogleFonts.inter(color: AppColors.slate400),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedItems.length,
                itemBuilder: (context, index) {
                  final item = sortedItems[index];
                  IconData icon;
                  switch (item.category) {
                    case 'food':
                      icon = Icons.restaurant_rounded;
                      break;
                    case 'hotel':
                      icon = Icons.hotel_rounded;
                      break;
                    case 'transport':
                      icon = Icons.directions_car_rounded;
                      break;
                    default:
                      icon = Icons.local_activity_rounded;
                      break;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.glassBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.navyDeep,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: AppColors.amber),
                      ),
                      title: Text(item.title,
                          style: GoogleFonts.inter(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(item.startTime ?? '',
                          style: GoogleFonts.inter(color: AppColors.slate400)),
                      trailing: PopupMenuButton<String>(
                        color: AppColors.navyDeep,
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditItemDialog(item);
                          } else if (value == 'delete') {
                            _firestoreService.deleteItineraryItem(
                                widget.tripId, item.itemId);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit',
                                style:
                                    GoogleFonts.inter(color: AppColors.white)),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete',
                                style:
                                    GoogleFonts.inter(color: Colors.redAccent)),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert_rounded,
                            color: AppColors.slate400),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _showAddItemDialog,
            child: Text('Add Plan',
                style: GoogleFonts.inter(
                    color: AppColors.navyDeep, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
