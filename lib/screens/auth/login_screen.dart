import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scripture_daily/theme/app_theme.dart';
import 'package:scripture_daily/services/auth_provider.dart';
import 'package:scripture_daily/screens/auth/forgot_password_screen.dart';
import 'package:scripture_daily/screens/auth/signup_screen.dart';
import 'package:scripture_daily/screens/home/home_shell.dart';
import 'package:scripture_daily/widgets/animated_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _emailExpanded = false, _obscure = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 100), () => _fadeCtrl.forward());
  }
  @override void dispose() { _emailCtrl.dispose(); _passwordCtrl.dispose(); _fadeCtrl.dispose(); super.dispose(); }

  void _goHome() => Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()), (_) => false);

  Future<void> _signInEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>()
        .signInWithEmail(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) _goHome();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Orange header
            Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDeeper],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: SafeArea(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 18),
                    ),
                  ),
                  const Spacer(),
                  Text('Welcome Back', style: GoogleFonts.playfairDisplay(
                      fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.white)),
                  const SizedBox(height: 4),
                  Text('Continue your spiritual journey',
                    style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.white.withOpacity(0.7))),
                  const SizedBox(height: 20),
                ]),
              )),
            ),

            // White card
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SocialButton(label: 'Continue with Google',
                  icon: _GoogleIcon(), backgroundColor: AppTheme.white,
                  foregroundColor: AppTheme.textPrimary, borderColor: AppTheme.divider,
                  isLoading: auth.isLoading, onTap: () async {
                    final ok = await auth.signInWithGoogle(); if (ok && mounted) _goHome();
                  }),
                const SizedBox(height: 12),
                SocialButton(label: 'Continue with Apple',
                  icon: const Icon(Icons.apple, size: 22, color: AppTheme.white),
                  backgroundColor: const Color(0xFF1A1A1A), foregroundColor: AppTheme.white,
                  isLoading: auth.isLoading, onTap: () async {
                    final ok = await auth.signInWithApple(); if (ok && mounted) _goHome();
                  }),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(children: [
                    const Expanded(child: Divider()),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text('or sign in with email',
                          style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted))),
                    const Expanded(child: Divider()),
                  ]),
                ),

                // Email expand button
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 280),
                  crossFadeState: _emailExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: GhostButton(
                    label: 'Sign in with Email',
                    icon: const Icon(Icons.email_outlined, size: 18, color: AppTheme.primary),
                    onTap: () => setState(() => _emailExpanded = true),
                  ),
                  secondChild: Form(
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      AppTextField(controller: _emailCtrl, label: 'Email address',
                          hint: 'you@example.com', keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined, textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter your email';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          }),
                      const SizedBox(height: 14),
                      AppTextField(controller: _passwordCtrl, label: 'Password', hint: '••••••••',
                          obscureText: _obscure, prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.done,
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                size: 20, color: AppTheme.textMuted),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter your password';
                            if (v.length < 6) return 'At least 6 characters';
                            return null;
                          }),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () { HapticFeedback.lightImpact();
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())); },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 4),
                            child: Text('Forgot password?', style: GoogleFonts.dmSans(
                                fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                          ),
                        ),
                      ),
                      if (auth.error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                          ),
                          child: Text(auth.error!, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.error)),
                        ),
                      const SizedBox(height: 6),
                      BounceButton(label: 'Sign In', isLoading: auth.isLoading, onTap: _signInEmail),
                    ]),
                  ),
                ),

                const SizedBox(height: 28),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Don't have an account? ",
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary)),
                  GestureDetector(
                    onTap: () { HapticFeedback.lightImpact();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpScreen())); },
                    child: Text('Sign up', style: GoogleFonts.dmSans(
                        fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  ),
                ]),
                const SizedBox(height: 32),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override Widget build(BuildContext context) =>
      CustomPaint(size: const Size(22, 22), painter: _GP());
}
class _GP extends CustomPainter {
  @override void paint(Canvas c, Size s) {
    final p = Paint()..style = PaintingStyle.fill;
    final cx = Offset(s.width/2, s.height/2); final r = s.width/2;
    p.color = const Color(0xFF4285F4); c.drawArc(Rect.fromCircle(center: cx, radius: r), -1.57, 3.14, true, p);
    p.color = const Color(0xFF34A853); c.drawArc(Rect.fromCircle(center: cx, radius: r), 1.57, 1.57, true, p);
    p.color = const Color(0xFFFBBC04); c.drawArc(Rect.fromCircle(center: cx, radius: r), 3.14, 0.79, true, p);
    p.color = const Color(0xFFEA4335); c.drawArc(Rect.fromCircle(center: cx, radius: r), 3.93, 0.78, true, p);
    p.color = Colors.white; c.drawCircle(cx, r*0.55, p);
    p.color = const Color(0xFF4285F4); c.drawRect(Rect.fromLTWH(cx.dx, cx.dy-r*0.18, r*1.1, r*0.36), p);
  }
  @override bool shouldRepaint(_) => false;
}
