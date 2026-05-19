// lib/core/utils/helpers.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class AppHelpers {
  AppHelpers._();

  /// Format a DateTime to "MMM dd, yyyy" — e.g. "Jan 05, 2025"
  static String formatDate(DateTime date) =>
      DateFormat('MMM dd, yyyy').format(date);

  /// Format a DateTime range e.g. "Jan 05 – Jan 15, 2025"
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${DateFormat('MMM dd').format(start)} – '
          '${DateFormat('dd, yyyy').format(end)}';
    }
    return '${DateFormat('MMM dd').format(start)} – '
        '${DateFormat('MMM dd, yyyy').format(end)}';
  }

  /// Trip duration in days
  static int tripDuration(DateTime start, DateTime end) =>
      end.difference(start).inDays + 1;

  /// Compute trip progress 0.0 – 1.0 (clamped)
  static double tripProgress(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(end)) return 1.0;
    final total = end.difference(start).inMinutes;
    final elapsed = now.difference(start).inMinutes;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Trip status label
  static String tripStatus(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (now.isBefore(start)) return 'Upcoming';
    if (now.isAfter(end)) return 'Completed';
    return 'Ongoing';
  }

  /// Status color
  static Color tripStatusColor(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (now.isBefore(start)) return AppColors.info;
    if (now.isAfter(end)) return AppColors.slate400;
    return AppColors.success;
  }

  /// Show a styled snackbar
  static void showSnack(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: AppColors.white, fontSize: 13)),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Pick an image from the destination image pool based on a seed string
  static String destinationImage(String seed) {
    final images = [
      'https://images.unsplash.com/photo-1506929562872-bb421503ef21?w=800&q=70',
      'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800&q=70',
      'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=800&q=70',
      'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800&q=70',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=70',
      'https://images.unsplash.com/photo-1530521954074-e64f6810b32d?w=800&q=70',
      'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?w=800&q=70',
    ];
    return images[seed.codeUnits.fold(0, (a, b) => a + b) % images.length];
  }
}
