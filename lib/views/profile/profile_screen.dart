import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/user_model.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';
import 'profile_completion_screen.dart';
import '../../core/utils/input_formatters.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestoreService = FirestoreService();
  final _authService = FirebaseAuthService();
  bool _notifyTrips = true;
  bool _notifyChat = true;

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _editName(UserModel user) async {
    final nameCtrl = TextEditingController(text: user.name);
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.navyDeep,
          title: Text('Edit Name',
              style: GoogleFonts.sora(color: AppColors.white)),
          content: TextField(
            controller: nameCtrl,
            style: GoogleFonts.inter(color: AppColors.white),
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [
              LeadingSpaceFormatter(),
              LengthLimitingTextInputFormatter(60),
            ],
            decoration: InputDecoration(
              hintText: 'Full name',
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
                  const Text('Save', style: TextStyle(color: AppColors.amber)),
            ),
          ],
        );
      },
    );

    if (shouldSave != true) return;

    final nextName = nameCtrl.text.trim();
    if (nextName.isEmpty) return;

    await _firestoreService.updateUser(user.uid, {'name': nextName});
    if (mounted) {
      AppHelpers.showSnack(context, 'Profile updated');
      setState(() {});
    }
  }

  Future<void> _editProfile(UserModel user) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProfileCompletionScreen(user: user, isEditing: true),
      ),
    );

    if (updated == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.navyDeep,
          title:
              Text('Log out', style: GoogleFonts.sora(color: AppColors.white)),
          content: Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.inter(color: AppColors.slate400),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.slate400)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log out',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _authService.signOut();
    if (mounted) {
      AppHelpers.showSnack(context, 'Logged out successfully');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        title: Text('Profile',
            style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
      ),
      body: FutureBuilder<UserModel?>(
        future: _firestoreService.getUser(_currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.amber));
          }

          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: Text('User not found',
                  style: GoogleFonts.inter(color: AppColors.slate400)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glassBg,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: GoogleFonts.sora(
                        color: AppColors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(user.name,
                    style: GoogleFonts.sora(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20)),
                const SizedBox(height: 4),
                Text(user.email,
                    style: GoogleFonts.inter(color: AppColors.slate400)),
                if ((user.city ?? '').isNotEmpty ||
                    (user.country ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${user.city ?? ''}${user.city != null && user.country != null ? ', ' : ''}${user.country ?? ''}',
                      style: GoogleFonts.inter(color: AppColors.slate400),
                    ),
                  ),
                if ((user.travelStyle ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Style: ${user.travelStyle}',
                      style: GoogleFonts.inter(color: AppColors.slate400),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => _editProfile(user),
                      icon: const Icon(Icons.edit_rounded,
                          color: AppColors.amber),
                      label: Text('Edit Profile',
                          style: GoogleFonts.inter(color: AppColors.white)),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () => _editName(user),
                      icon: const Icon(Icons.person_outline_rounded,
                          color: AppColors.slate400),
                      label: Text('Quick Name Edit',
                          style: GoogleFonts.inter(color: AppColors.slate400)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionCard(
                  title: 'Personal',
                  items: [
                    _ProfileItem('Email', user.email),
                    _ProfileItem('Phone', user.phone),
                    _ProfileItem('Date of birth', user.dateOfBirth),
                    _ProfileItem('Gender', user.gender),
                  ],
                ),
                _SectionCard(
                  title: 'Address',
                  items: [
                    _ProfileItem('City', user.city),
                    _ProfileItem('Area', user.stateRegion),
                    _ProfileItem('Country', user.country),
                    _ProfileItem('Postal code', user.postalCode),
                  ],
                ),
                _SectionCard(
                  title: 'Travel Documents',
                  items: [
                    _ProfileItem('Nationality', user.nationality),
                    _ProfileItem('Passport number', user.passportNumber),
                    _ProfileItem('Passport expiry', user.passportExpiry),
                  ],
                ),
                _SectionCard(
                  title: 'Preferences',
                  items: [
                    _ProfileItem('Travel style', user.travelStyle),
                    _ProfileItem('Budget range', user.budgetRange),
                    _ProfileItem('Accommodation', user.accommodationType),
                    _ProfileItem('Dietary', user.dietaryPreferences),
                    _ProfileItem('Language', user.preferredLanguage),
                  ],
                ),
                _SectionCard(
                  title: 'Emergency Contact',
                  items: [
                    _ProfileItem('Name', user.emergencyContactName),
                    _ProfileItem('Relationship', user.emergencyContactRelation),
                    _ProfileItem('Phone', user.emergencyContactPhone),
                  ],
                ),
                _SectionCard(
                  title: 'Bio',
                  items: [
                    _ProfileItem('About', user.bio),
                  ],
                ),
                _SettingTile(
                  title: 'Trip notifications',
                  subtitle: 'Reminders for upcoming plans',
                  value: _notifyTrips,
                  onChanged: (val) => setState(() => _notifyTrips = val),
                ),
                _SettingTile(
                  title: 'Chat notifications',
                  subtitle: 'Notify on new messages',
                  value: _notifyChat,
                  onChanged: (val) => setState(() => _notifyChat = val),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Log out'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        color: AppColors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        color: AppColors.slate400, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.amber,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<_ProfileItem> items;

  const _SectionCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems =
        items.where((item) => (item.value ?? '').trim().isNotEmpty).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.sora(
                  color: AppColors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (visibleItems.isEmpty)
            Text('Not set', style: GoogleFonts.inter(color: AppColors.slate400))
          else
            ...visibleItems.map((item) => _ProfileRow(item: item)),
        ],
      ),
    );
  }
}

class _ProfileItem {
  final String label;
  final String? value;

  const _ProfileItem(this.label, this.value);
}

class _ProfileRow extends StatelessWidget {
  final _ProfileItem item;

  const _ProfileRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(item.label,
                style:
                    GoogleFonts.inter(color: AppColors.slate400, fontSize: 12)),
          ),
          Expanded(
            flex: 6,
            child: Text(item.value ?? '-',
                style: GoogleFonts.inter(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}
