import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scripture_daily/theme/app_theme.dart';
import 'package:scripture_daily/services/auth_provider.dart';
import 'package:scripture_daily/screens/home/home_shell.dart';
import 'package:scripture_daily/screens/auth/login_screen.dart';
import 'package:scripture_daily/widgets/animated_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _confirmCtrl= TextEditingController();
  bool _obscure = true, _obscureC = true;
  late AnimationController _fadeCtrl, _slideCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade  = CurvedAnimation(parent: _fadeCtrl,  curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeCtrl.forward(); _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    _fadeCtrl.dispose(); _slideCtrl.dispose();
    super.dispose();
  }

  void _goHome() => Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()), (_) => false);

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>()
        .signUpWithEmail(_emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim());
    if (ok && mounted) _goHome();
  }

  Future<void> _google() async {
    final ok = await context.read<AuthProvider>().signInWithGoogle();
    if (ok && mounted) _goHome();
  }

  Future<void> _apple() async {
    final ok = await context.read<AuthProvider>().signInWithApple();
    if (ok && mounted) _goHome();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Orange hero header ───────────────────────────────
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back button
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                                      color: AppTheme.white, size: 18),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Floating cross icon
                              Container(
                                width: 54, height: 54,
                                decoration: BoxDecoration(
                                  color: AppTheme.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppTheme.white.withOpacity(0.3), width: 1),
                                ),
                                child: Center(
                                  child: Text('✦', style: TextStyle(
                                      fontSize: 26, color: AppTheme.white.withOpacity(0.9))),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text('Join Scripture Daily',
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.white)),
                              const SizedBox(height: 4),
                              Text('Your faith journey starts here',
                                style: GoogleFonts.dmSans(
                                    fontSize: 14, color: AppTheme.white.withOpacity(0.75))),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Curved white card body ───────────────────────────
                    Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      transform: Matrix4.translationValues(0, -24, 0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Social buttons
                            SocialButton(
                              label: 'Continue with Google',
                              icon: _GoogleIcon(),
                              backgroundColor: AppTheme.white,
                              foregroundColor: AppTheme.textPrimary,
                              borderColor: AppTheme.divider,
                              isLoading: auth.isLoading,
                              onTap: _google,
                            ),
                            const SizedBox(height: 12),
                            SocialButton(
                              label: 'Continue with Apple',
                              icon: const Icon(Icons.apple, size: 22, color: AppTheme.white),
                              backgroundColor: const Color(0xFF1A1A1A),
                              foregroundColor: AppTheme.white,
                              isLoading: auth.isLoading,
                              onTap: _apple,
                            ),

                            // Divider
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Row(children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Text('or create with email',
                                    style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted)),
                                ),
                                const Expanded(child: Divider()),
                              ]),
                            ),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(children: [
                                AppTextField(
                                  controller: _nameCtrl,
                                  label: 'Full name',
                                  hint: 'Your name',
                                  prefixIcon: Icons.person_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => (v == null || v.isEmpty) ? 'Enter your name' : null,
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller: _emailCtrl,
                                  label: 'Email address',
                                  hint: 'you@example.com',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Enter your email';
                                    if (!v.contains('@')) return 'Enter a valid email';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller: _passCtrl,
                                  label: 'Password',
                                  hint: 'At least 8 characters',
                                  obscureText: _obscure,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        size: 20, color: AppTheme.textMuted),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Enter a password';
                                    if (v.length < 8) return 'At least 8 characters';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller: _confirmCtrl,
                                  label: 'Confirm password',
                                  hint: '••••••••',
                                  obscureText: _obscureC,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  textInputAction: TextInputAction.done,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureC ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        size: 20, color: AppTheme.textMuted),
                                    onPressed: () => setState(() => _obscureC = !_obscureC),
                                  ),
                                  validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
                                ),
                              ]),
                            ),

                            if (auth.error != null)
                              Container(
                                margin: const EdgeInsets.only(top: 14),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                                ),
                                child: Text(auth.error!,
                                    style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.error)),
                              ),

                            const SizedBox(height: 24),
                            BounceButton(
                              label: 'Create My Account',
                              isLoading: auth.isLoading,
                              onTap: _signUp,
                              icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.white, size: 18),
                            ),

                            const SizedBox(height: 20),
                            // Perks row
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.orangeTint,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _Perk(icon: '📖', label: '7 Versions'),
                                  _Perk(icon: '🌍', label: '70 Languages'),
                                  _Perk(icon: '🙏', label: 'Daily Prayer'),
                                  _Perk(icon: '🔔', label: 'Reminders'),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('Already have an account? ',
                                  style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary)),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen())),
                                child: Text('Sign in',
                                    style: GoogleFonts.dmSans(fontSize: 14,
                                        color: AppTheme.primary, fontWeight: FontWeight.w700)),
                              ),
                            ]),
                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  final String icon, label;
  const _Perk({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.dmSans(
          fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
    ],
  );
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(
      size: const Size(22, 22), painter: _GooglePainter());
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..style = PaintingStyle.fill;
    final cx = Offset(s.width / 2, s.height / 2);
    final r = s.width / 2;
    p.color = const Color(0xFF4285F4);
    c.drawArc(Rect.fromCircle(center: cx, radius: r), -1.57, 3.14, true, p);
    p.color = const Color(0xFF34A853);
    c.drawArc(Rect.fromCircle(center: cx, radius: r), 1.57, 1.57, true, p);
    p.color = const Color(0xFFFBBC04);
    c.drawArc(Rect.fromCircle(center: cx, radius: r), 3.14, 0.79, true, p);
    p.color = const Color(0xFFEA4335);
    c.drawArc(Rect.fromCircle(center: cx, radius: r), 3.93, 0.78, true, p);
    p.color = Colors.white;
    c.drawCircle(cx, r * 0.55, p);
    p.color = const Color(0xFF4285F4);
    c.drawRect(Rect.fromLTWH(cx.dx, cx.dy - r * 0.18, r * 1.1, r * 0.36), p);
  }
  @override bool shouldRepaint(_) => false;
}
