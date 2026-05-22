// lib/views/auth/login_screen.dart

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/animation_utils.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/input_formatters.dart';
import '../../services/firebase_auth_service.dart';
import 'signup_screen.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = FirebaseAuthService();

  bool _obscurePass = true;
  bool _isLoading = false;
  bool _emailFocused = false;
  bool _passFocused = false;

  late AnimationController _logoController;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await _authService.signInWithEmail(
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(showWelcomeMessage: true),
        ),
        (_) => false,
      );
    } else {
      AppHelpers.showSnack(context, result.errorMessage!, isError: true);
    }
  }

  Future<void> _handleForgotPassword() async {
    final emailCtrl = TextEditingController(text: _emailCtrl.text);
    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.navyDeep,
          title: Text('Reset Password',
              style: GoogleFonts.sora(color: AppColors.white)),
          content: TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            inputFormatters: [LeadingSpaceFormatter()],
            style: GoogleFonts.inter(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Email address',
              hintStyle: GoogleFonts.inter(color: AppColors.slate400),
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
                  const Text('Send', style: TextStyle(color: AppColors.amber)),
            ),
          ],
        );
      },
    );

    if (shouldSend != true) return;

    final email = emailCtrl.text.trim();
    if (email.isEmpty) return;

    final result = await _authService.sendPasswordReset(email);
    if (!mounted) return;

    if (result.success) {
      AppHelpers.showSnack(context, 'Password reset email sent.');
    } else {
      AppHelpers.showSnack(
          context, result.errorMessage ?? 'Failed to send email',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──────────────────────────────────
          CachedNetworkImage(
            imageUrl:
                'https://images.unsplash.com/photo-1488085061387-422e29b40080'
                '?w=1200&q=80&auto=format&fit=crop',
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.navyDeep),
            errorWidget: (_, __, ___) => Container(color: AppColors.navyDeep),
          ),

          // ── Dark scrim ────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC0A0F2E),
                  Color(0xF00A0F2E),
                  AppColors.navyDeep,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Ambient glow orb ──────────────────────────────────
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withOpacity(0.08),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Logo / Icon
                  ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.amber, AppColors.amberLight],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.amber.withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.explore_rounded,
                        color: AppColors.navyDeep,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Headline
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Welcome\nBack',
                      style: GoogleFonts.sora(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.1,
                        letterSpacing: -2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      'Sign in to continue your adventures',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.slate400,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Glass form card ───────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 400),
                    child: _GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email field
                            _FocusAwareField(
                              controller: _emailCtrl,
                              label: 'Email address',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.none,
                              inputFormatters: [LeadingSpaceFormatter()],
                              onFocusChange: (v) =>
                                  setState(() => _emailFocused = v),
                              isFocused: _emailFocused,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(v)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Password field
                            _FocusAwareField(
                              controller: _passCtrl,
                              label: 'Password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePass,
                              textCapitalization: TextCapitalization.none,
                              onFocusChange: (v) =>
                                  setState(() => _passFocused = v),
                              isFocused: _passFocused,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                    () => _obscurePass = !_obscurePass),
                                child: Icon(
                                  _obscurePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.slate400,
                                  size: 20,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _handleForgotPassword,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.inter(
                                    color: AppColors.amber,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── CTA button ────────────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 500),
                    child: _MorphButton(
                      label: 'Sign In',
                      isLoading: _isLoading,
                      onTap: _handleLogin,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Sign up link ──────────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 600),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.inter(
                            color: AppColors.slate400,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final created = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                            if (!mounted) return;
                            if (created == true) {
                              AppHelpers.showSnack(
                                context,
                                'Account created successfully. Please log in.',
                              );
                            }
                          },
                          child: Text(
                            'Create one',
                            style: GoogleFonts.sora(
                              color: AppColors.amber,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Glass Card ───────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Focus-aware Text Field ────────────────────────────────────────────────────
class _FocusAwareField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final void Function(bool) onFocusChange;
  final bool isFocused;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const _FocusAwareField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.sentences,
    required this.onFocusChange,
    required this.isFocused,
    this.suffixIcon,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: AppColors.amber.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 0,
                  )
                ]
              : [],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: GoogleFonts.inter(color: AppColors.white, fontSize: 15),
          validator: validator,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon,
                color: isFocused ? AppColors.amber : AppColors.slate400,
                size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.glassBg,
            labelStyle: GoogleFonts.inter(
              color: isFocused ? AppColors.amber : AppColors.slate400,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.glassBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.glassBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.amber, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Morphing CTA Button ───────────────────────────────────────────────────────
class _MorphButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _MorphButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_MorphButton> createState() => _MorphButtonState();
}

class _MorphButtonState extends State<_MorphButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.isLoading ? 28 : 16),
            gradient: widget.isLoading
                ? const LinearGradient(
                    colors: [Color(0xFF8B7355), Color(0xFF6B5B3E)])
                : const LinearGradient(
                    colors: [AppColors.amber, AppColors.amberLight]),
            boxShadow: [
              BoxShadow(
                color: AppColors.amber.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(AppColors.white),
                    ),
                  )
                : Text(
                    widget.label,
                    style: GoogleFonts.sora(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDeep,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
