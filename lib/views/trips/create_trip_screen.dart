import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../services/firestore_service.dart';
import 'city_search_screen.dart';
import '../../core/utils/input_formatters.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  final _firestoreService = FirestoreService();

  Future<void> _openCitySearch() async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CitySearchScreen()),
    );
    if (selected != null && selected.trim().isNotEmpty) {
      setState(() => _destinationCtrl.text = selected.trim());
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.amber,
              onPrimary: AppColors.navyDeep,
              surface: AppColors.navyDeep,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select travel dates')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestoreService.createTrip(
        title: _titleCtrl.text.trim(),
        destination: _destinationCtrl.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        createdBy: user.uid,
        notes: _notesCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create trip: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        title: Text(
          'Plan New Trip',
          style: GoogleFonts.sora(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xEE0A0F2E), AppColors.navyDeep],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Trip Title'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _titleCtrl,
                      hint: 'e.g. Summer Vacation',
                      icon: Icons.title_rounded,
                      inputFormatters: [
                        LeadingSpaceFormatter(),
                        LengthLimitingTextInputFormatter(60),
                      ],
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Enter a title'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Destination'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _destinationCtrl,
                      hint: 'e.g. Paris, France',
                      icon: Icons.location_on_rounded,
                      inputFormatters: [
                        LeadingSpaceFormatter(),
                        LengthLimitingTextInputFormatter(80),
                      ],
                      suffixIcon: IconButton(
                        onPressed: _openCitySearch,
                        icon: const Icon(Icons.search_rounded,
                            color: AppColors.amber),
                        tooltip: 'Search cities',
                      ),
                      validator: (val) =>
                          (val == null || val.trim().isEmpty)
                          ? 'Enter a destination'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Travel Dates'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDateRange,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.glassBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: AppColors.amber),
                            const SizedBox(width: 16),
                            Text(
                              _startDate == null
                                  ? 'Select Dates'
                                  : '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}',
                              style: GoogleFonts.inter(
                                color: _startDate == null
                                    ? AppColors.slate400
                                    : AppColors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Notes (Optional)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _notesCtrl,
                      hint: 'Add any specific things to remember...',
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                      inputFormatters: [
                        LeadingSpaceFormatter(),
                        LengthLimitingTextInputFormatter(200),
                      ],
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isLoading ? null : _createTrip,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.navyDeep)
                            : Text(
                                'Create Trip',
                                style: GoogleFonts.inter(
                                  color: AppColors.navyDeep,
                                  fontSize: 18,
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
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: AppColors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(color: AppColors.white),
      maxLines: maxLines,
      validator: validator,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters ?? [LeadingSpaceFormatter()],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.slate400),
        prefixIcon: Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 12, bottom: 8, top: 8),
          child: Icon(icon, color: AppColors.amber),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.glassBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.amber),
        ),
      ),
    );
  }
}
