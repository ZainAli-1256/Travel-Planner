import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/animation_utils.dart';
import '../../core/utils/helpers.dart';
import '../../services/firebase_auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _authService = FirebaseAuthService();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.signUpWithEmail(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      AppHelpers.showSnack(
        context,
        'Account created successfully',
      );

      Navigator.pop(context);
    } else {
      AppHelpers.showSnack(
        context,
        result.errorMessage ?? 'Signup failed',
        isError: true,
      );
    }
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
                'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'
                '?w=1200&q=80&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),
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
              ),
            ),
          ),
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.amber,
                            AppColors.amberLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: AppColors.navyDeep,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Create\nAccount',
                      style: GoogleFonts.sora(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Start planning smarter journeys',
                    style: GoogleFonts.inter(
                      color: AppColors.slate400,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _GlassCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _Field(
                            controller: _nameCtrl,
                            label: 'Full Name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _Field(
                            controller: _emailCtrl,
                            label: 'Email',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _Field(
                            controller: _passCtrl,
                            label: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePass,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscurePass = !_obscurePass;
                                });
                              },
                              child: Icon(
                                _obscurePass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.slate400,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.length < 6) {
                                return 'Minimum 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _Field(
                            controller: _confirmCtrl,
                            label: 'Confirm Password',
                            icon: Icons.lock_person_outlined,
                            obscureText: _obscureConfirm,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                              child: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.slate400,
                              ),
                            ),
                            validator: (v) {
                              if (v != _passCtrl.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SignupButton(
                    isLoading: _isLoading,
                    onTap: _handleSignup,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
            border: Border.all(
              color: AppColors.glassBorder,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
        color: AppColors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: AppColors.slate400,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.amber,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.glassBg,
      ),
    );
  }
}

class _SignupButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _SignupButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              AppColors.amber,
              AppColors.amberLight,
            ],
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    AppColors.white,
                  ),
                )
              : Text(
                  'Create Account',
                  style: GoogleFonts.sora(
                    color: AppColors.navyDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
