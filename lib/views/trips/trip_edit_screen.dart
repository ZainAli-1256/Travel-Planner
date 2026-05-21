import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/trip_model.dart';
import '../../services/firestore_service.dart';

class TripEditScreen extends StatefulWidget {
  final TripModel trip;

  const TripEditScreen({super.key, required this.trip});

  @override
  State<TripEditScreen> createState() => _TripEditScreenState();
}

class _TripEditScreenState extends State<TripEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _firestoreService = FirestoreService();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.trip.title;
    _destinationCtrl.text = widget.trip.destination;
    _notesCtrl.text = widget.trip.notes ?? '';
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _destinationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      AppHelpers.showSnack(context, 'Please select travel dates',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestoreService.updateTrip(widget.trip.tripId, {
        'title': _titleCtrl.text.trim(),
        'destination': _destinationCtrl.text.trim(),
        'startDate': _startDate!.millisecondsSinceEpoch,
        'endDate': _endDate!.millisecondsSinceEpoch,
        'notes': _notesCtrl.text.trim(),
      });

      if (mounted) {
        AppHelpers.showSnack(context, 'Trip updated');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnack(context, 'Failed to update trip', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTrip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.navyDeep,
          title: Text('Delete Trip',
              style: GoogleFonts.sora(color: AppColors.white)),
          content: Text('This will remove the trip and all its data.',
              style: GoogleFonts.inter(color: AppColors.slate400)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.slate400)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _firestoreService.deleteTrip(widget.trip.tripId);
    if (mounted) {
      AppHelpers.showSnack(context, 'Trip deleted');
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.trip.createdBy == _currentUid;

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        title: Text('Edit Trip',
            style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
        actions: [
          if (isOwner)
            IconButton(
              onPressed: _deleteTrip,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
            ),
        ],
      ),
      body: SafeArea(
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
                  validator: (val) => val!.isEmpty ? 'Enter a title' : null,
                ),
                const SizedBox(height: 24),
                _buildLabel('Destination'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _destinationCtrl,
                  hint: 'e.g. Paris, France',
                  icon: Icons.location_on_rounded,
                  validator: (val) =>
                      val!.isEmpty ? 'Enter a destination' : null,
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
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveTrip,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.navyDeep)
                        : Text('Save Changes',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(color: AppColors.white),
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.slate400),
        prefixIcon: Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 12, bottom: 8, top: 8),
          child: Icon(icon, color: AppColors.amber),
        ),
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
