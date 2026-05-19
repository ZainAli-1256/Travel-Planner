import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                          Icons.flight_takeoff_rounded,
                          color: AppColors.navyDeep,
                        ),
                      ),
                      const Spacer(),
                      Container(
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
                        padding: const EdgeInsets.all(20),
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
                            Text(
                              'Search destinations...',
                              style: GoogleFonts.inter(
                                color: AppColors.slate400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: ListView(
                      children: [
                        _TripCard(
                          title: 'Santorini',
                          country: 'Greece',
                          image:
                              'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?q=80&w=1200',
                        ),
                        const SizedBox(height: 20),
                        _TripCard(
                          title: 'Dubai',
                          country: 'UAE',
                          image:
                              'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?q=80&w=1200',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final String title;
  final String country;
  final String image;

  const _TripCard({
    required this.title,
    required this.country,
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
              Text(
                country,
                style: GoogleFonts.inter(
                  color: AppColors.slate400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
