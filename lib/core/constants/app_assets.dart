// lib/core/constants/app_assets.dart

class AppAssets {
  AppAssets._();

  // ── Lottie Animations ──────────────────────────────────────────
  /// Download from: https://lottiefiles.com/animations/empty-state-travel
  static const String emptyTrips = 'assets/animations/empty_trips.json';

  /// Download from: https://lottiefiles.com/animations/loading
  static const String loading = 'assets/animations/loading.json';

  /// Download from: https://lottiefiles.com/animations/success-checkmark
  static const String successCheck = 'assets/animations/success_check.json';

  // ── Network Image Placeholders (Unsplash) ─────────────────────
  static const String authBg =
      'https://images.unsplash.com/photo-1488085061387-422e29b40080'
      '?w=1200&q=80&auto=format&fit=crop';

  static const String defaultAvatar =
      'https://ui-avatars.com/api/?background=F5A623&color=0A0F2E'
      '&bold=true&size=128';

  static String avatarUrl(String name) =>
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}'
      '&background=F5A623&color=0A0F2E&bold=true&size=128';

  // ── Destination placeholder images (Unsplash collection) ──────
  static const List<String> destinationImages = [
    'https://images.unsplash.com/photo-1506929562872-bb421503ef21?w=800&q=70',
    'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800&q=70',
    'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=800&q=70',
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800&q=70',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=70',
  ];
}
