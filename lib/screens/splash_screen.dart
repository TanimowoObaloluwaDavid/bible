import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scripture_daily/theme/app_theme.dart';
import 'package:scripture_daily/screens/auth/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _logoFade, _logoScale, _textFade, _bottomFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
    _logoFade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
    _logoScale = Tween(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.55, curve: Curves.elasticOut)));
    _textFade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.65, curve: Curves.easeOut));
    _textSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.65, curve: Curves.easeOut)));
    _bottomFade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.6, 1.0, curve: Curves.easeOut));
    _ctrl.forward().then((_) => Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const WelcomeScreen(),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

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
        child: SafeArea(child: Column(children: [
          const Spacer(flex: 2),
          ScaleTransition(scale: _logoScale, child: FadeTransition(opacity: _logoFade,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: AppTheme.white.withOpacity(0.25), width: 1.5),
              ),
              child: Center(child: Text('✦', style: TextStyle(fontSize: 52, color: AppTheme.white.withOpacity(0.95)))),
            ),
          )),
          const SizedBox(height: 28),
          SlideTransition(position: _textSlide, child: FadeTransition(opacity: _textFade,
            child: Column(children: [
              Text('Scripture Daily', style: GoogleFonts.playfairDisplay(
                  fontSize: 36, fontWeight: FontWeight.w700, color: AppTheme.white)),
              const SizedBox(height: 8),
              Text('Read · Pray · Share · Grow', style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppTheme.white.withOpacity(0.6), letterSpacing: 1.2)),
            ]),
          )),
          const Spacer(flex: 2),
          FadeTransition(opacity: _bottomFade, child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _Dot(), const SizedBox(width: 6), _Dot(active: true), const SizedBox(width: 6), _Dot(),
            ]),
            const SizedBox(height: 20),
            Text('"The word of God is alive and active"',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.white.withOpacity(0.35))),
            const SizedBox(height: 4),
            Text('Hebrews 4:12', style: GoogleFonts.dmSans(
                fontSize: 11, color: AppTheme.white.withOpacity(0.25))),
            const SizedBox(height: 40),
          ])),
        ])),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({this.active = false});
  @override Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: active ? 20 : 6, height: 6,
    decoration: BoxDecoration(
      color: active ? AppTheme.white : AppTheme.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(3),
    ),
  );
}
