import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scripture_daily/theme/app_theme.dart';
import 'package:scripture_daily/services/auth_provider.dart';
import 'package:scripture_daily/services/notification_service.dart';
import 'package:scripture_daily/screens/auth/welcome_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Profile', style: GoogleFonts.playfairDisplay(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ),
      body: ListView(
        children: [
          // User card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(user?.initials ?? 'U', style: GoogleFonts.playfairDisplay(
                      fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'Beloved',
                        style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '', style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(_providerLabel(user?.provider ?? 'email'),
                          style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Settings sections
          _Section(title: 'Reading', items: [
            _SettingsItem(icon: Icons.text_fields_rounded, label: 'Default Bible Version', trailing: 'KJV'),
            _SettingsItem(icon: Icons.language_rounded, label: 'Language', trailing: 'English'),
            _SettingsItem(icon: Icons.brightness_6_rounded, label: 'Theme', trailing: 'Light'),
          ]),

          const SizedBox(height: 12),

          _Section(title: 'Notifications', items: [
            _SettingsItem(icon: Icons.notifications_rounded, label: 'Daily Verse Reminder', trailing: '', isSwitch: true, switchValue: true),
            _SettingsItem(icon: Icons.self_improvement_rounded, label: 'Prayer Reminders', trailing: '', isSwitch: true, switchValue: false),
          ]),

          const SizedBox(height: 12),

          _Section(title: 'About', items: [
            _SettingsItem(icon: Icons.info_outline_rounded, label: 'App Version', trailing: '1.0.0'),
            _SettingsItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', trailing: ''),
            _SettingsItem(icon: Icons.description_outlined, label: 'Terms of Service', trailing: ''),
          ]),

          const SizedBox(height: 12),

          // Sign out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (_) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppTheme.error),
              label: Text('Sign Out', style: GoogleFonts.dmSans(
                fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.error)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.error.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _providerLabel(String provider) {
    switch (provider) {
      case 'google': return 'Signed in with Google';
      case 'apple': return 'Signed in with Apple';
      default: return 'Email Account';
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text(title, style: GoogleFonts.dmSans(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: AppTheme.textMuted, letterSpacing: 0.8)),
        ),
        Container(
          color: Colors.white,
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast) const Padding(
                    padding: EdgeInsets.only(left: 56),
                    child: Divider(height: 1),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String trailing;
  final bool isSwitch;
  final bool switchValue;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.trailing,
    this.isSwitch = false,
    this.switchValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppTheme.primary),
      ),
      title: Text(label, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: isSwitch
          ? Transform.scale(scale: 0.8,
              child: Switch(value: switchValue, onChanged: (_) {}, activeColor: AppTheme.primary))
          : trailing.isNotEmpty
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(trailing, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textMuted),
                ])
              : const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textMuted),
    );
  }
}
