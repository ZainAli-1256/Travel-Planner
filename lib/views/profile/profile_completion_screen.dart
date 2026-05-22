import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../../core/utils/input_formatters.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final UserModel user;
  final bool isEditing;

  const ProfileCompletionScreen({
    super.key,
    required this.user,
    this.isEditing = false,
  });

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  final _passportNumberCtrl = TextEditingController();
  final _passportExpiryCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _dietaryCtrl = TextEditingController();
  final _languageCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyRelationCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  String _travelStyle = 'Explorer';
  String _gender = 'Prefer not to say';
  String _budgetRange = 'Mid-range';
  String _accommodationType = 'Hotel';
  String _phoneCode = '+92';
  String _emergencyPhoneCode = '+92';
  bool _isSaving = false;

  static const List<String> _phoneCodes = [
    '+1',
    '+20',
    '+33',
    '+44',
    '+49',
    '+61',
    '+81',
    '+86',
    '+91',
    '+92',
    '+234',
    '+880',
    '+971',
    '+973',
    '+974',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
    final phoneParts = _splitPhone(widget.user.phone);
    _phoneCode = phoneParts.code;
    _phoneCtrl.text = phoneParts.number;
    _cityCtrl.text = widget.user.city ?? '';
    _stateCtrl.text = widget.user.stateRegion ?? '';
    _countryCtrl.text = widget.user.country ?? '';
    _postalCtrl.text = widget.user.postalCode ?? '';
    _dobCtrl.text = widget.user.dateOfBirth ?? '';
    _nationalityCtrl.text = widget.user.nationality ?? '';
    _passportNumberCtrl.text = widget.user.passportNumber ?? '';
    _passportExpiryCtrl.text = widget.user.passportExpiry ?? '';
    _bioCtrl.text = widget.user.bio ?? '';
    _dietaryCtrl.text = widget.user.dietaryPreferences ?? '';
    _languageCtrl.text = widget.user.preferredLanguage ?? '';
    _emergencyNameCtrl.text = widget.user.emergencyContactName ?? '';
    _emergencyRelationCtrl.text = widget.user.emergencyContactRelation ?? '';
    final emergencyParts = _splitPhone(widget.user.emergencyContactPhone);
    _emergencyPhoneCode = emergencyParts.code;
    _emergencyPhoneCtrl.text = emergencyParts.number;
    _travelStyle = widget.user.travelStyle ?? 'Explorer';
    _gender = widget.user.gender ?? 'Prefer not to say';
    _budgetRange = widget.user.budgetRange ?? 'Mid-range';
    _accommodationType = widget.user.accommodationType ?? 'Hotel';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _postalCtrl.dispose();
    _dobCtrl.dispose();
    _nationalityCtrl.dispose();
    _passportNumberCtrl.dispose();
    _passportExpiryCtrl.dispose();
    _bioCtrl.dispose();
    _dietaryCtrl.dispose();
    _languageCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyRelationCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _firestoreService.updateUser(widget.user.uid, {
        'name': _nameCtrl.text.trim(),
        'phone': _formatPhone(_phoneCode, _phoneCtrl.text.trim()),
        'city': _cityCtrl.text.trim(),
        'stateRegion': _stateCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'postalCode': _postalCtrl.text.trim(),
        'dateOfBirth': _dobCtrl.text.trim(),
        'gender': _gender,
        'nationality': _nationalityCtrl.text.trim(),
        'passportNumber': _passportNumberCtrl.text.trim(),
        'passportExpiry': _passportExpiryCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'travelStyle': _travelStyle,
        'budgetRange': _budgetRange,
        'accommodationType': _accommodationType,
        'dietaryPreferences': _dietaryCtrl.text.trim(),
        'preferredLanguage': _languageCtrl.text.trim(),
        'emergencyContactName': _emergencyNameCtrl.text.trim(),
        'emergencyContactRelation': _emergencyRelationCtrl.text.trim(),
        'emergencyContactPhone': _formatPhone(
          _emergencyPhoneCode,
          _emergencyPhoneCtrl.text.trim(),
        ),
        'profileComplete': true,
      });

      await FirebaseAuth.instance.currentUser?.updateDisplayName(
        _nameCtrl.text.trim(),
      );

      if (mounted) {
        AppHelpers.showSnack(
            context, widget.isEditing ? 'Profile updated' : 'Profile saved');
        if (widget.isEditing) {
          Navigator.pop(context, true);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (_) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnack(context, 'Failed to save profile', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        automaticallyImplyLeading: widget.isEditing,
        title: Text(widget.isEditing ? 'Edit Profile' : 'Complete Profile',
            style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditing
                      ? 'Update your profile details'
                      : 'Tell us a bit about you',
                  style: GoogleFonts.sora(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'We use this to personalize trip recommendations and chat.',
                  style: GoogleFonts.inter(color: AppColors.slate400),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Personal'),
                const SizedBox(height: 12),
                _buildLabel('Full Name'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameCtrl,
                  hint: 'Your full name',
                  icon: Icons.person_outline_rounded,
                  validator: (val) => _required(val, 'name'),
                ),
                const SizedBox(height: 16),
                _buildLabel('Email'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emailCtrl,
                  hint: 'Email address',
                  icon: Icons.mail_outline_rounded,
                  readOnly: true,
                  textCapitalization: TextCapitalization.none,
                ),
                const SizedBox(height: 16),
                _buildLabel('Phone'),
                const SizedBox(height: 8),
                _buildPhoneInput(
                  controller: _phoneCtrl,
                  code: _phoneCode,
                  onCodeChanged: (val) => setState(() => _phoneCode = val),
                  label: 'phone',
                ),
                const SizedBox(height: 16),
                _buildLabel('Date of Birth'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _dobCtrl,
                  hint: 'YYYY-MM-DD',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                  onTap: _pickDateOfBirth,
                  textCapitalization: TextCapitalization.none,
                  validator: (val) => _validateDateOfBirth(val),
                ),
                const SizedBox(height: 16),
                _buildLabel('Gender'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _gender,
                  items: const [
                    'Female',
                    'Male',
                    'Non-binary',
                    'Prefer not to say',
                  ],
                  onChanged: (val) => setState(() => _gender = val),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Address'),
                const SizedBox(height: 12),
                _buildLabel('City'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _cityCtrl,
                  hint: 'City',
                  icon: Icons.location_city_rounded,
                  validator: (val) => _required(val, 'city'),
                ),
                const SizedBox(height: 16),
                _buildLabel('Area'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _stateCtrl,
                  hint: 'Area',
                  icon: Icons.map_outlined,
                  validator: (val) => _required(val, 'area'),
                ),
                const SizedBox(height: 16),
                _buildLabel('Country'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _countryCtrl,
                  hint: 'Country',
                  icon: Icons.public_rounded,
                  validator: (val) => _required(val, 'country'),
                ),
                const SizedBox(height: 16),
                _buildLabel('Postal Code'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _postalCtrl,
                  hint: 'Postal code',
                  icon: Icons.local_post_office_outlined,
                  validator: (val) => _validatePostal(val),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Travel Documents'),
                const SizedBox(height: 12),
                _buildLabel('Nationality'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nationalityCtrl,
                  hint: 'Nationality',
                  icon: Icons.flag_outlined,
                  validator: (val) => _required(val, 'nationality'),
                ),
                const SizedBox(height: 16),
                _buildLabel('Passport Number'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passportNumberCtrl,
                  hint: 'Passport number',
                  icon: Icons.badge_outlined,
                  textCapitalization: TextCapitalization.none,
                  validator: (val) => _validateOptionalPassportNumber(val),
                ),
                const SizedBox(height: 16),
                _buildLabel('Passport Expiry'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passportExpiryCtrl,
                  hint: 'YYYY-MM-DD',
                  icon: Icons.event_outlined,
                  keyboardType: TextInputType.datetime,
                  textCapitalization: TextCapitalization.none,
                  validator: (val) =>
                      _validateOptionalDate(val, 'passport expiry'),
                ),
                const SizedBox(height: 16),
                _buildLabel('Travel Style'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _travelStyle,
                  items: const [
                    'Explorer',
                    'Relaxer',
                    'Foodie',
                    'Backpacker',
                    'Family',
                    'Business',
                  ],
                  onChanged: (val) => setState(() => _travelStyle = val),
                ),
                const SizedBox(height: 16),
                _buildLabel('Budget Range'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _budgetRange,
                  items: const [
                    'Budget',
                    'Mid-range',
                    'Luxury',
                  ],
                  onChanged: (val) => setState(() => _budgetRange = val),
                ),
                const SizedBox(height: 16),
                _buildLabel('Accommodation Type'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _accommodationType,
                  items: const [
                    'Hotel',
                    'Hostel',
                    'Apartment',
                    'Resort',
                    'Guesthouse',
                  ],
                  onChanged: (val) => setState(() => _accommodationType = val),
                ),
                const SizedBox(height: 16),
                _buildLabel('Dietary Preferences'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _dietaryCtrl,
                  hint: 'Vegetarian, Halal, etc.',
                  icon: Icons.restaurant_outlined,
                  validator: (val) => _required(val, 'dietary preferences'),
                ),
                const SizedBox(height: 16),
                _buildLabel('Preferred Language'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _languageCtrl,
                  hint: 'English',
                  icon: Icons.language_outlined,
                  validator: (val) => _required(val, 'preferred language'),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Emergency Contact'),
                const SizedBox(height: 12),
                _buildLabel('Contact Name'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emergencyNameCtrl,
                  hint: 'Full name',
                  icon: Icons.contact_phone_outlined,
                  validator: (val) => _required(val, 'emergency contact name'),
                ),
                const SizedBox(height: 16),
                _buildLabel('Relationship'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emergencyRelationCtrl,
                  hint: 'Relationship',
                  icon: Icons.people_outline,
                  validator: (val) =>
                      _required(val, 'emergency contact relationship'),
                ),
                const SizedBox(height: 16),
                _buildLabel('Emergency Phone'),
                const SizedBox(height: 8),
                _buildPhoneInput(
                  controller: _emergencyPhoneCtrl,
                  code: _emergencyPhoneCode,
                  onCodeChanged: (val) =>
                      setState(() => _emergencyPhoneCode = val),
                  label: 'emergency phone',
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('About'),
                const SizedBox(height: 12),
                _buildLabel('Bio'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _bioCtrl,
                  hint: 'A short intro about you',
                  icon: Icons.edit_note_rounded,
                  maxLines: 3,
                  validator: (val) => _required(val, 'bio'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const CircularProgressIndicator(
                            color: AppColors.navyDeep)
                        : Text('Save Profile',
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

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your $label';
    }
    return null;
  }

  String? _validatePhone(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your $label';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 10) {
      return 'Enter 11 digits for $label';
    }
    return null;
  }

  String? _validateDate(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your $label';
    }
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value.trim())) {
      return 'Use YYYY-MM-DD for $label';
    }
    return null;
  }

  String? _validateOptionalDate(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return _validateDate(value, label);
  }

  String? _validateDateOfBirth(String? value) {
    final baseError = _validateDate(value, 'date of birth');
    if (baseError != null) return baseError;
    final parsed = DateTime.tryParse(value!.trim());
    if (parsed == null) {
      return 'Enter a valid date of birth';
    }
    final today = DateTime.now();
    final minDate = DateTime(today.year - 15, today.month, today.day);
    if (parsed.isAfter(minDate)) {
      return 'You must be at least 15 years old';
    }
    return null;
  }

  String? _validatePostal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your postal code';
    }
    final postalRegex = RegExp(r'^[A-Za-z0-9\-\s]{3,10}$');
    if (!postalRegex.hasMatch(value.trim())) {
      return 'Enter a valid postal code';
    }
    return null;
  }

  String? _validateOptionalPassportNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final passRegex = RegExp(r'^[A-Za-z0-9]{6,}$');
    if (!passRegex.hasMatch(value.trim())) {
      return 'Enter a valid passport number';
    }
    return null;
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final latest = DateTime(now.year - 15, now.month, now.day);
    final initial = _parseOrFallbackDate(_dobCtrl.text, latest);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: latest,
    );
    if (picked == null) return;
    _dobCtrl.text = _formatDate(picked);
  }

  DateTime _parseOrFallbackDate(String value, DateTime fallback) {
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) return fallback;
    return parsed;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  _PhoneParts _splitPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const _PhoneParts(code: '+92', number: '');
    }
    final parts = value.trim().split(' ');
    if (parts.length >= 2 && parts.first.startsWith('+')) {
      final code = parts.first;
      final number = parts.sublist(1).join(' ').replaceAll(RegExp(r'\D'), '');
      final normalizedCode = _phoneCodes.contains(code) ? code : '+92';
      return _PhoneParts(code: normalizedCode, number: number);
    }
    return _PhoneParts(
      code: '+92',
      number: value.replaceAll(RegExp(r'\D'), ''),
    );
  }

  String _formatPhone(String code, String number) {
    return '$code ${number.replaceAll(RegExp(r'\D'), '')}'.trim();
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: AppColors.white,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(color: AppColors.white),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters ?? [LeadingSpaceFormatter()],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.slate400),
        prefixIcon: Icon(icon, color: AppColors.amber),
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

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.sora(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.navyDeep,
          iconEnabledColor: AppColors.amber,
          style: GoogleFonts.inter(color: AppColors.white),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  Widget _buildPhoneInput({
    required TextEditingController controller,
    required String code,
    required ValueChanged<String> onCodeChanged,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 110,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _phoneCodes.contains(code) ? code : _phoneCodes.first,
              dropdownColor: AppColors.navyDeep,
              iconEnabledColor: AppColors.amber,
              style: GoogleFonts.inter(color: AppColors.white),
              items: _phoneCodes
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (val) {
                if (val != null) onCodeChanged(val);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: controller,
            hint: '10-digit number',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.number,
            validator: (val) => _validatePhone(val, label),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhoneParts {
  final String code;
  final String number;

  const _PhoneParts({required this.code, required this.number});
}
