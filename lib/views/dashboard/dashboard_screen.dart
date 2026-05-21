import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/trip_model.dart';
import '../../services/firestore_service.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../trips/create_trip_screen.dart';
import '../trips/trip_detail_screen.dart';
import '../trips/trip_history_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool showWelcomeMessage;

  const DashboardScreen({super.key, this.showWelcomeMessage = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firestoreService = FirestoreService();
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';
  final _searchCtrl = TextEditingController();
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.showWelcomeMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppHelpers.showSnack(context, 'Login successful');
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl:
                'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee'
                '?w=1200&q=80&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xAA0A0F2E),
                  Color(0xEE0A0F2E),
                  AppColors.navyDeep,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.amber,
                              AppColors.amberLight,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.public_rounded,
                          color: AppColors.navyDeep,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.glassBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.glassBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(Icons.person_rounded,
                              color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Explore\nThe World',
                    style: GoogleFonts.sora(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Find beautiful destinations for your next trip',
                    style: GoogleFonts.inter(
                      color: AppColors.slate400,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.glassBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.glassBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.slate400,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (_) => setState(() {}),
                                style:
                                    GoogleFonts.inter(color: AppColors.white),
                                decoration: InputDecoration(
                                  hintText: 'Search trips or destinations...',
                                  hintStyle: GoogleFonts.inter(
                                      color: AppColors.slate400),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (_searchCtrl.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: AppColors.slate400),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {});
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.glassBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        _FilterChipButton(
                          label: 'Upcoming',
                          isSelected: _filterIndex == 0,
                          onTap: () => setState(() => _filterIndex = 0),
                        ),
                        const SizedBox(width: 8),
                        _FilterChipButton(
                          label: 'Past Trips',
                          isSelected: _filterIndex == 1,
                          onTap: () => setState(() => _filterIndex = 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<List<TripModel>>(
                      stream:
                          _firestoreService.streamMemberTrips(_currentUserId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.amber),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Failed to load trips.',
                              style: GoogleFonts.inter(color: AppColors.white),
                            ),
                          );
                        }

                        final trips = snapshot.data ?? [];
                        final now = DateTime.now();
                        final query = _searchCtrl.text.trim().toLowerCase();
                        final filtered = trips.where((trip) {
                          final matchesSearch = query.isEmpty ||
                              trip.title.toLowerCase().contains(query) ||
                              trip.destination.toLowerCase().contains(query);
                          final isUpcoming = !trip.endDate
                              .isBefore(DateTime(now.year, now.month, now.day));
                          final matchesFilter =
                              _filterIndex == 0 ? isUpcoming : !isUpcoming;
                          return matchesSearch && matchesFilter;
                        }).toList();

                        if (filtered.isEmpty) {
                          return Center(
                            child: Text(
                              _filterIndex == 0
                                  ? 'No upcoming trips yet.\nTap + to create one!'
                                  : 'No past trips yet.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: AppColors.slate400,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            final trip = filtered[index];
                            final fallbackImage = index % 2 == 0
                                ? 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?q=80&w=1200'
                                : 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?q=80&w=1200';

                            return GestureDetector(
                              onTap: () {
                                final now = DateTime.now();
                                final isPast = trip.endDate.isBefore(
                                  DateTime(now.year, now.month, now.day),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => isPast
                                        ? TripHistoryDetailScreen(trip: trip)
                                        : TripDetailScreen(trip: trip),
                                  ),
                                );
                              },
                              child: _TripCard(
                                title: trip.title,
                                country: trip.destination,
                                dateRange:
                                    '${DateFormat('MMM d').format(trip.startDate)} - ${DateFormat('MMM d').format(trip.endDate)}',
                                image: trip.coverImageUrl ?? fallbackImage,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTripScreen()),
          );
        },
        backgroundColor: AppColors.amber,
        icon: const Icon(Icons.add_rounded, color: AppColors.navyDeep),
        label: Text(
          'Plan Trip',
          style: GoogleFonts.inter(
            color: AppColors.navyDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final String title;
  final String country;
  final String dateRange;
  final String image;

  const _TripCard({
    required this.title,
    required this.country,
    required this.dateRange,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.sora(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppColors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    country,
                    style: GoogleFonts.inter(
                      color: AppColors.slate400,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_month_rounded,
                      color: AppColors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    dateRange,
                    style: GoogleFonts.inter(
                      color: AppColors.slate400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.amber : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? AppColors.navyDeep : AppColors.slate400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
