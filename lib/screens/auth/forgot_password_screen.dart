import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scripture_daily/theme/app_theme.dart';
import 'package:scripture_daily/services/auth_provider.dart';
import 'package:scripture_daily/widgets/animated_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  @override void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().sendPasswordReset(_emailCtrl.text.trim());
    if (ok && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.orangeTint, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.primaryDark),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _sent ? _Success(email: _emailCtrl.text) : _Form(
                formKey: _formKey, emailCtrl: _emailCtrl,
                isLoading: auth.isLoading, onSubmit: _send,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;
  const _Form({required this.formKey, required this.emailCtrl, required this.isLoading, required this.onSubmit});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Container(
      width: 70, height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(Icons.lock_reset_rounded, color: AppTheme.white, size: 32),
    ),
    const SizedBox(height: 22),
    Text('Reset Password', style: GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
    const SizedBox(height: 8),
    Text('Enter your email and we\'ll send a reset link.',
      style: GoogleFonts.dmSans(fontSize: 15, color: AppTheme.textSecondary, height: 1.6)),
    const SizedBox(height: 28),
    Form(key: formKey, child: AppTextField(
      controller: emailCtrl, label: 'Email address', hint: 'you@example.com',
      keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Enter your email';
        if (!v.contains('@')) return 'Enter a valid email';
        return null;
      },
    )),
    const SizedBox(height: 24),
    BounceButton(label: 'Send Reset Link', isLoading: isLoading, onTap: onSubmit,
        icon: const Icon(Icons.send_rounded, color: AppTheme.white, size: 18)),
  ]);
}

class _Success extends StatelessWidget {
  final String email;
  const _Success({required this.email});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Container(
      width: 70, height: 70,
      decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(22)),
      child: const Icon(Icons.mark_email_read_rounded, color: AppTheme.success, size: 36),
    ),
    const SizedBox(height: 22),
    Text('Check Your Email', style: GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
    const SizedBox(height: 10),
    RichText(text: TextSpan(
      style: GoogleFonts.dmSans(fontSize: 15, color: AppTheme.textSecondary, height: 1.6),
      children: [
        const TextSpan(text: 'A reset link was sent to\n'),
        TextSpan(text: email, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
        const TextSpan(text: '\n\nFollow the link to create a new password.'),
      ],
    )),
    const SizedBox(height: 32),
    BounceButton(label: 'Back to Sign In', onTap: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.white, size: 18)),
  ]);
}

