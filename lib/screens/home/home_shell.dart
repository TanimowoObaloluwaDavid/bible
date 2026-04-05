import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scripture_daily/theme/app_theme.dart';
import 'package:scripture_daily/screens/home/home_tab.dart';
import 'package:scripture_daily/screens/bible/bible_tab.dart';
import 'package:scripture_daily/screens/prayer/prayer_tab.dart';
import 'package:scripture_daily/screens/bookmarks/bookmarks_tab.dart';
import 'package:scripture_daily/screens/profile/profile_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with SingleTickerProviderStateMixin {
  int _idx = 0;
  late AnimationController _tabCtrl;

  static const _tabs = [HomeTab(), BibleTab(), PrayerTab(), BookmarksTab(), ProfileTab()];
  static const _labels = ['Home', 'Bible', 'Prayer', 'Saved', 'Profile'];
  static const _icons = [
    Icons.home_rounded, Icons.menu_book_rounded,
    Icons.self_improvement_rounded, Icons.bookmark_rounded, Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
    _tabCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }
  @override void dispose() { _tabCtrl.dispose(); super.dispose(); }

  void _onTap(int i) {
    HapticFeedback.selectionClick();
    setState(() => _idx = i);
    _tabCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: List.generate(5, (i) => _NavItem(
                icon: _icons[i], label: _labels[i],
                isSelected: _idx == i,
                onTap: () => _onTap(i),
              )),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: isSelected ? AppTheme.primary : AppTheme.textMuted),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? AppTheme.primary : AppTheme.textMuted,
            ),
            child: Text(label),
          ),
        ]),
      ),
    );
  }
}
