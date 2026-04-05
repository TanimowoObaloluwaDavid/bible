import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scripture_daily/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Bouncy primary button ──────────────────────────────────────────────────
class BounceButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget? icon;
  final Color? color;
  final Color? textColor;
  final double height;
  final double? width;
  final double radius;

  const BounceButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.color,
    this.textColor,
    this.height = 56,
    this.width,
    this.radius = 16,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onTapDown(_) { _ctrl.forward(); HapticFeedback.lightImpact(); }
  void _onTapUp(_) { _ctrl.reverse(); widget.onTap?.call(); }
  void _onTapCancel() { _ctrl.reverse(); }

  @override
  Widget build(BuildContext context) {
    final bg = widget.color ?? AppTheme.primary;
    final fg = widget.textColor ?? AppTheme.white;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: widget.isLoading ? null : _onTapDown,
        onTapUp: widget.isLoading ? null : _onTapUp,
        onTapCancel: widget.isLoading ? null : _onTapCancel,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.color != null
                  ? [widget.color!, widget.color!]
                  : [AppTheme.primary, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              BoxShadow(
                color: bg.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: fg))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 10)],
                      Text(widget.label, style: GoogleFonts.dmSans(
                          fontSize: 15, fontWeight: FontWeight.w700, color: fg)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Ghost / Outlined button ────────────────────────────────────────────────
class GhostButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? icon;
  final Color? borderColor;
  final Color? textColor;
  final double height;

  const GhostButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.borderColor,
    this.textColor,
    this.height = 56,
  });

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bc = widget.borderColor ?? AppTheme.primary;
    final tc = widget.textColor ?? AppTheme.primary;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) { _ctrl.forward(); HapticFeedback.selectionClick(); },
        onTapUp: (_) { _ctrl.reverse(); widget.onTap?.call(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bc, width: 1.5),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 10)],
                Text(widget.label, style: GoogleFonts.dmSans(
                    fontSize: 15, fontWeight: FontWeight.w700, color: tc)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Social Auth button ─────────────────────────────────────────────────────
class SocialButton extends StatefulWidget {
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final bool isLoading;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: widget.isLoading ? null : (_) { _ctrl.forward(); HapticFeedback.lightImpact(); },
        onTapUp: widget.isLoading ? null : (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: widget.isLoading ? null : () => _ctrl.reverse(),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: widget.borderColor != null ? Border.all(color: widget.borderColor!, width: 1.5) : null,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 22, height: 22, child: widget.icon),
              const SizedBox(width: 12),
              Text(widget.label, style: GoogleFonts.dmSans(
                  fontSize: 15, fontWeight: FontWeight.w600, color: widget.foregroundColor)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── App text field ─────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onChanged: onChanged,
      validator: validator,
      style: GoogleFonts.dmSans(fontSize: 15, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: AppTheme.textMuted)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
