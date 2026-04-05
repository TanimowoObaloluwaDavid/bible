import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:scripture_daily/theme/app_theme.dart';
import 'package:scripture_daily/services/auth_provider.dart';
import 'package:scripture_daily/services/bible_service.dart';
import 'package:scripture_daily/models/bible_data.dart';
import 'package:scripture_daily/widgets/animated_button.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  Map<String, String>? _verse;
  bool _loading = true;
  bool _isSharing = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 3))..repeat(reverse: true);
    _pulse = Tween(begin: 1.0, end: 1.04)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _loadVerse();
  }

  @override void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  Future<void> _loadVerse() async {
    final refs = BibleData.dailyVerseRefs;
    final ref  = refs[DateTime.now().day % refs.length];
    final v    = await BibleService.getDailyVerse(ref);
    if (mounted) setState(() { _verse = v; _loading = false; });
  }

  Future<void> _share() async {
    if (_verse == null || _isSharing) return;
    setState(() => _isSharing = true);
    HapticFeedback.mediumImpact();
    try {
      await Share.share(
        '"${_verse!['text']}"\n— ${_verse!['reference']}\n\nShared via Scripture Daily ✦',
        subject: _verse!['reference'],
      );
    } catch (_) {}
    if (mounted) setState(() => _isSharing = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final name  = auth.user?.displayName?.split(' ').first ?? 'Beloved';
    final now   = DateTime.now();
    final hour  = now.hour;
    final greet = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final date  = DateFormat('EEEE, MMMM d').format(now);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: AppTheme.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('✦', style: TextStyle(color: AppTheme.white, fontSize: 14))),
              ),
              const SizedBox(width: 10),
              Text('Scripture Daily', style: GoogleFonts.playfairDisplay(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ]),
            actions: [
              GestureDetector(
                onTap: () => HapticFeedback.lightImpact(),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.orangeTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: AppTheme.primaryDark, size: 20),
                ),
              ),
            ],
            bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: AppTheme.divider)),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // ── Greeting ───────────────────────────────────────────────
              Text(date, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text('$greet, $name 👋', style: GoogleFonts.playfairDisplay(
                  fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),

              const SizedBox(height: 22),

              // ── Daily Verse Card ───────────────────────────────────────
              ScaleTransition(
                scale: _loading ? const AlwaysStoppedAnimation(1.0) : _pulse,
                child: _DailyVerseCard(
                  loading: _loading,
                  verse: _verse,
                  onShare: _share,
                  onRefresh: () { setState(() { _loading = true; }); _loadVerse(); },
                ),
              ),

              const SizedBox(height: 24),

              // ── Quick Actions ──────────────────────────────────────────
              Row(children: [
                Text('Quick Actions', style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted, letterSpacing: 0.5)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _Action(icon: Icons.menu_book_rounded,       label: 'Read',     color: AppTheme.primary),
                const SizedBox(width: 10),
                _Action(icon: Icons.self_improvement_rounded, label: 'Pray',    color: AppTheme.primaryDark),
                const SizedBox(width: 10),
                _Action(icon: Icons.search_rounded,           label: 'Search',  color: AppTheme.primaryDeeper),
                const SizedBox(width: 10),
                _Action(icon: Icons.share_rounded,            label: 'Share',   color: const Color(0xFFFF8C42),
                    onTap: _share),
              ]),

              const SizedBox(height: 28),

              // ── Reading plan ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Continue Reading', style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5)),
                  GestureDetector(
                    onTap: () => HapticFeedback.selectionClick(),
                    child: Text('See all', style: GoogleFonts.dmSans(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ReadingCard(),

              const SizedBox(height: 28),

              // ── Start here ─────────────────────────────────────────────
              Text('Popular Books', style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _BookChip(name: 'Psalms',   sub: '150 chapters'),
                    _BookChip(name: 'John',     sub: '21 chapters'),
                    _BookChip(name: 'Proverbs', sub: '31 chapters'),
                    _BookChip(name: 'Romans',   sub: '16 chapters'),
                    _BookChip(name: 'Isaiah',   sub: '66 chapters'),
                    _BookChip(name: 'Genesis',  sub: '50 chapters'),
                  ],
                ),
              ),
            ])),
          ),
        ],
      ),
    );
  }
}

// ── Daily verse card ─────────────────────────────────────────────────────────
class _DailyVerseCard extends StatelessWidget {
  final bool loading;
  final Map<String, String>? verse;
  final Future<void> Function() onShare;
  final VoidCallback onRefresh;
  const _DailyVerseCard({required this.loading, required this.verse,
      required this.onShare, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDeeper],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
            color: AppTheme.primary.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.white.withOpacity(0.25)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('✦ ', style: TextStyle(color: AppTheme.white, fontSize: 10)),
              Text('Verse of the Day', style: GoogleFonts.dmSans(
                  fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.white)),
            ]),
          ),
          Row(children: [
            GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); onRefresh(); },
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.refresh_rounded, color: AppTheme.white.withOpacity(0.8), size: 18),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () { HapticFeedback.mediumImpact(); onShare(); },
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.share_rounded, color: AppTheme.white.withOpacity(0.8), size: 18),
              ),
            ),
          ]),
        ]),
        const SizedBox(height: 16),
        if (loading)
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Shimmer(width: double.infinity, height: 14),
            const SizedBox(height: 8), _Shimmer(width: 240, height: 14),
            const SizedBox(height: 8), _Shimmer(width: 180, height: 14),
          ])
        else if (verse != null) ...[
          Text('"${verse!['text']}"', style: GoogleFonts.playfairDisplay(
              fontSize: 16, color: AppTheme.white, height: 1.7,
              fontStyle: FontStyle.italic)),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('— ${verse!['reference']}', style: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: AppTheme.white.withOpacity(0.75))),
            GestureDetector(
              onTap: () { HapticFeedback.mediumImpact(); onShare(); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.share_rounded, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 5),
                  Text('Share', style: GoogleFonts.dmSans(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                ]),
              ),
            ),
          ]),
        ] else
          Text('Could not load verse', style: GoogleFonts.dmSans(
              fontSize: 14, color: AppTheme.white.withOpacity(0.6))),
      ]),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final double width, height;
  const _Shimmer({required this.width, required this.height});
  @override Widget build(BuildContext context) => Container(
      width: width, height: height,
      decoration: BoxDecoration(
          color: AppTheme.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4)));
}

class _Action extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _Action({required this.icon, required this.label, required this.color, this.onTap});
  @override State<_Action> createState() => _ActionState();
}

class _ActionState extends State<_Action> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _s = Tween(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Expanded(
    child: ScaleTransition(
      scale: _s,
      child: GestureDetector(
        onTapDown: (_) { _c.forward(); HapticFeedback.lightImpact(); },
        onTapUp: (_) { _c.reverse(); widget.onTap?.call(); },
        onTapCancel: () => _c.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.color.withOpacity(0.15)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(widget.icon, color: AppTheme.white, size: 16),
            ),
            const SizedBox(height: 5),
            Text(widget.label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 10, fontWeight: FontWeight.w700, color: widget.color)),
          ]),
        ),
      ),
    ),
  );
}

class _ReadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppTheme.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('John • Chapter 3', style: GoogleFonts.dmSans(
                fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text('Last read: John 2', style: GoogleFonts.dmSans(
                fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.12, minHeight: 5,
                backgroundColor: AppTheme.divider,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              ),
            ),
          ])),
          const SizedBox(width: 12),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: AppTheme.white, size: 20),
          ),
        ]),
      ),
    );
  }
}

class _BookChip extends StatefulWidget {
  final String name, sub;
  const _BookChip({required this.name, required this.sub});
  @override State<_BookChip> createState() => _BookChipState();
}

class _BookChipState extends State<_BookChip> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _s = Tween(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _s,
    child: GestureDetector(
      onTapDown: (_) { _c.forward(); HapticFeedback.selectionClick(); },
      onTapUp: (_) => _c.reverse(),
      onTapCancel: () => _c.reverse(),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppTheme.orangeTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book_rounded, size: 14, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Text(widget.name, style: GoogleFonts.playfairDisplay(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text(widget.sub, style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
      ),
    ),
  );
}
