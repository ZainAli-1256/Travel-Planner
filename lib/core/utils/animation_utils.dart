// lib/core/utils/animation_utils.dart

import 'package:flutter/material.dart';

// ── Durations ────────────────────────────────────────────────────────────────
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration xSlow = Duration(milliseconds: 900);
}

// ── Curves ────────────────────────────────────────────────────────────────────
class AppCurves {
  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve spring = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
}

// ── Fade + Slide In Widget ────────────────────────────────────────────────────
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.beginOffset = const Offset(0, 0.08),
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: AppCurves.enter)
        .drive(Tween(begin: 0.0, end: 1.0));
    _slide = CurvedAnimation(parent: _controller, curve: AppCurves.enter)
        .drive(Tween(begin: widget.beginOffset, end: Offset.zero));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Staggered list wrapper ────────────────────────────────────────────────────
class StaggeredItem extends StatelessWidget {
  final int index;
  final Widget child;

  const StaggeredItem({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: Duration(milliseconds: 100 + index * 80),
      child: child,
    );
  }
}

// ── Shimmer-like pulse for loading ───────────────────────────────────────────
class PulseLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const PulseLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<PulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_anim.value * 0.15),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
