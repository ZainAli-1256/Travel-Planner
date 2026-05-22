import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/chat_message_model.dart';
import '../../models/trip_model.dart';
import 'itinerary_view.dart';
import 'chat_view.dart';
import 'weather_view.dart';
import 'places_view.dart';
import '../../services/firestore_service.dart';
import 'trip_edit_screen.dart';
import '../../services/chat_state_store.dart';
import '../../services/chat_notification_service.dart';

class TripDetailScreen extends StatefulWidget {
  final TripModel trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firestoreService = FirestoreService();
  late TripModel _trip;
  DateTime _chatLastReadAt = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _autoReadTimer;

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _trip = widget.trip;
    _tabController.addListener(_handleTabChange);
    _loadChatReadAt();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleTabChange());
  }

  @override
  void dispose() {
    _autoReadTimer?.cancel();
    if (ChatNotificationService.instance.activeTripId.value == _trip.tripId) {
      ChatNotificationService.instance.activeTripId.value = null;
    }
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChatReadAt() async {
    if (_currentUid.isEmpty) return;
    final value = await ChatStateStore.getLastRead(_currentUid, _trip.tripId);
    if (value != null && mounted) {
      setState(() => _chatLastReadAt = value);
    }
  }

  Future<void> _markChatRead() async {
    if (_currentUid.isEmpty) return;
    final now = DateTime.now();
    if (mounted) setState(() => _chatLastReadAt = now);
    await ChatStateStore.setLastRead(_currentUid, _trip.tripId, now);
  }

  void _handleTabChange() {
    if (!mounted) return;
    if (_tabController.index == 1) {
      ChatNotificationService.instance.activeTripId.value = _trip.tripId;
      _markChatRead();
    } else {
      _autoReadTimer?.cancel();
      if (ChatNotificationService.instance.activeTripId.value == _trip.tripId) {
        ChatNotificationService.instance.activeTripId.value = null;
      }
    }
  }

  void _scheduleAutoRead() {
    _autoReadTimer?.cancel();
    _autoReadTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _markChatRead();
    });
  }

  Future<void> _refreshTrip() async {
    final updated = await _firestoreService.getTrip(_trip.tripId);
    if (updated != null && mounted) {
      setState(() => _trip = updated);
    }
  }

  Future<void> _showMembersSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Trip Members',
                      style: GoogleFonts.sora(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_rounded,
                        color: AppColors.amber),
                    onPressed: _promptAddMember,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<String>>(
                future: _resolveMemberNames(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.amber)),
                    );
                  }
                  final names = snapshot.data ?? [];
                  if (names.isEmpty) {
                    return Text('No members found.',
                        style: GoogleFonts.inter(color: AppColors.slate400));
                  }
                  return Column(
                    children: names
                        .map((name) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.glassBg,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppColors.glassBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_rounded,
                                      color: AppColors.amber),
                                  const SizedBox(width: 10),
                                  Text(name,
                                      style: GoogleFonts.inter(
                                          color: AppColors.white)),
                                ],
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<List<String>> _resolveMemberNames() async {
    final names = <String>[];
    for (final uid in _trip.members) {
      final user = await _firestoreService.getUser(uid);
      names.add(user?.name ?? 'Unknown user');
    }
    return names;
  }

  Future<void> _promptAddMember() async {
    final emailCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.navyDeep,
          title: Text('Add Member',
              style: GoogleFonts.sora(color: AppColors.white)),
          content: TextField(
            controller: emailCtrl,
            style: GoogleFonts.inter(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Email address',
              hintStyle: GoogleFonts.inter(color: AppColors.slate400),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.amber),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.slate400)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Add', style: TextStyle(color: AppColors.amber)),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final email = emailCtrl.text.trim();
    if (email.isEmpty) return;

    final user = await _firestoreService.getUserByEmail(email);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found with that email.')),
        );
      }
      return;
    }

    await _firestoreService.addMember(_trip.tripId, user.uid);
    if (mounted) {
      setState(
          () => _trip = _trip.copyWith(members: [..._trip.members, user.uid]));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} added to the trip.')),
      );
    }
  }

  Future<void> _promptReuseTrip() async {
    final titleCtrl = TextEditingController(text: '${_trip.title} (Copy)');
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
      sourceTrip: _trip,
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
        title: Text(
          _trip.title,
          style: GoogleFonts.sora(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.navyDeep,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            tooltip: 'Members',
            onPressed: _showMembersSheet,
            icon: const Icon(Icons.group_rounded, color: AppColors.white),
          ),
          IconButton(
            tooltip: 'Edit trip',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TripEditScreen(trip: _trip)),
              );
              await _refreshTrip();
            },
            icon: const Icon(Icons.edit_rounded, color: AppColors.white),
          ),
          IconButton(
            tooltip: 'Reuse plan',
            onPressed: _promptReuseTrip,
            icon: const Icon(Icons.copy_rounded, color: AppColors.white),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.amber,
          unselectedLabelColor: AppColors.slate400,
          indicatorColor: AppColors.amber,
          tabs: [
            const Tab(icon: Icon(Icons.map_rounded), text: 'Plan'),
            _buildChatTab(),
            const Tab(icon: Icon(Icons.explore_rounded), text: 'Places'),
            const Tab(icon: Icon(Icons.cloud_rounded), text: 'Weather'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ItineraryView(tripId: _trip.tripId, trip: _trip),
          ChatView(tripId: _trip.tripId),
          PlacesView(trip: _trip),
          WeatherView(trip: _trip),
        ],
      ),
    );
  }

  Tab _buildChatTab() {
    return Tab(
      icon: StreamBuilder<List<ChatMessageModel>>(
        stream: _firestoreService.streamMessages(_trip.tripId),
        builder: (context, snapshot) {
          final messages = snapshot.data ?? [];
          final unread = messages.where((msg) {
            if (msg.senderId == _currentUid) return false;
            return msg.sentAt.isAfter(_chatLastReadAt);
          }).length;

          if (_tabController.index == 1 && unread > 0) {
            _scheduleAutoRead();
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.forum_rounded),
              if (unread > 0)
                Positioned(
                  right: -8,
                  top: -6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : unread.toString(),
                      style: const TextStyle(
                        color: AppColors.navyDeep,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      text: 'Chat',
    );
  }
}
