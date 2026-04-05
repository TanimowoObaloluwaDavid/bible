import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scripture_daily/theme/app_theme.dart';
import 'package:scripture_daily/screens/auth/login_screen.dart';
import 'package:scripture_daily/screens/auth/signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _fade, _slide;
  late Animation<double> _fadeA;
  late Animation<Offset> _slideA;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
    _fade  = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slide = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeA = CurvedAnimation(parent: _fade,  curve: Curves.easeOut);
    _slideA = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slide, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 200), () { _fade.forward(); _slide.forward(); });
  }
  @override void dispose() { _fade.dispose(); _slide.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryDeeper, AppTheme.primaryDark, AppTheme.primary],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeA,
            child: SlideTransition(
              position: _slideA,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Spacer(flex: 2),

                  // ── Hero icon ───────────────────────────────────────────
                  Center(child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppTheme.white.withOpacity(0.25), width: 1.5),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('✦', style: TextStyle(fontSize: 40, color: AppTheme.white.withOpacity(0.95))),
                    ]),
                  )),
                  const SizedBox(height: 28),

                  Text('Scripture\nDaily', textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 42, fontWeight: FontWeight.w700, color: AppTheme.white, height: 1.1)),
                  const SizedBox(height: 12),
                  Text('Read. Pray. Share.\nGrow deeper in faith every day.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                        fontSize: 16, color: AppTheme.white.withOpacity(0.7), height: 1.6)),

                  const Spacer(flex: 2),

                  // ── Feature pills ───────────────────────────────────────
                  Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
                    _Pill('📖 7+ Versions'), _Pill('🌍 70 Languages'),
                    _Pill('🙏 Prayer Journal'), _Pill('🔔 Daily Reminders'),
                    _Pill('📤 Share Verses'), _Pill('🔖 Bookmarks'),
                  ]),

                  const SizedBox(height: 36),

                  // ── CTA buttons ─────────────────────────────────────────
                  GestureDetector(
                    onTap: () { HapticFeedback.mediumImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())); },
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
                            blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Center(child: Text('Get Started — It\'s Free',
                        style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () { HapticFeedback.lightImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())); },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.white.withOpacity(0.4), width: 1.5),
                      ),
                      child: Center(child: Text('I already have an account',
                        style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600,
                            color: AppTheme.white.withOpacity(0.9)))),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text('"Thy word is a lamp unto my feet" — Psalm 119:105',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.white.withOpacity(0.4))),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppTheme.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.white.withOpacity(0.2)),
    ),
    child: Text(label, style: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.white.withOpacity(0.85))),
  );
}
