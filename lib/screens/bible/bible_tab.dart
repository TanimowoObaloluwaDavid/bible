import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:scripture_daily/theme/app_theme.dart';
import 'package:scripture_daily/models/models.dart';
import 'package:scripture_daily/models/bible_data.dart';
import 'package:scripture_daily/services/bible_service.dart';
import 'package:provider/provider.dart';
import 'package:scripture_daily/services/auth_provider.dart';
import 'package:scripture_daily/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class BibleTab extends StatefulWidget {
  const BibleTab({super.key});
  @override State<BibleTab> createState() => _BibleTabState();
}

class _BibleTabState extends State<BibleTab> {
  BibleVersion _version = BibleData.versions[0];
  BibleBook    _book    = BibleData.books[39]; // Matthew
  int          _chapter = 1;
  List<BibleVerse> _verses = [];
  bool _loading = true;
  bool _isSharing = false;
  double _fontSize = 17;
  final Map<String, List<BibleVerse>> _cache = {};
  final ScrollController _scroll = ScrollController();

  @override
  void initState() { super.initState(); _fetch(); }
  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  String get _key => '${_book.id}_${_chapter}_${_version.id}';

  Future<void> _fetch() async {
    setState(() => _loading = true);
    if (_cache.containsKey(_key)) {
      setState(() { _verses = _cache[_key]!; _loading = false; }); return;
    }
    final v = await BibleService.fetchChapter(_book.id, _chapter, translation: _version.id);
    if (mounted) { _cache[_key] = v; setState(() { _verses = v; _loading = false; }); }
  }

  void _prev() {
    HapticFeedback.selectionClick();
    if (_chapter > 1) { setState(() => _chapter--); _fetch(); _scroll.jumpTo(0); }
    else {
      final i = BibleData.books.indexOf(_book);
      if (i > 0) { setState(() { _book = BibleData.books[i-1]; _chapter = _book.chapters; }); _fetch(); }
    }
  }

  void _next() {
    HapticFeedback.selectionClick();
    if (_chapter < _book.chapters) { setState(() => _chapter++); _fetch(); _scroll.jumpTo(0); }
    else {
      final i = BibleData.books.indexOf(_book);
      if (i < BibleData.books.length-1) { setState(() { _book = BibleData.books[i+1]; _chapter = 1; }); _fetch(); }
    }
  }

  Future<void> _shareVerse(BibleVerse v) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    HapticFeedback.mediumImpact();
    try {
      await Share.share(
        '"${v.text}"\n— ${_book.name} ${_chapter}:${v.number} (${_version.abbreviation})\n\nShared via Scripture Daily ✦',
        subject: '${_book.name} ${_chapter}:${v.number}',
      );
    } catch (_) {}
    if (mounted) setState(() => _isSharing = false);
  }

  Future<void> _bookmarkVerse(BibleVerse v) async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    HapticFeedback.mediumImpact();
    final ref = '${_book.name} ${_chapter}:${v.number}';
    final already = await FirestoreService.isBookmarked(uid, ref);
    if (already) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Already saved', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
      return;
    }
    await FirestoreService.addBookmark(uid, Bookmark(
      id: const Uuid().v4(),
      reference: ref,
      text: v.text,
      versionId: _version.id,
      savedAt: DateTime.now(),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Verse saved ✦', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: const SizedBox(),
        title: GestureDetector(
          onTap: _showBookPicker,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(children: [
              Text('${_book.name}', style: GoogleFonts.playfairDisplay(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(width: 3),
              Text('${_chapter}', style: GoogleFonts.playfairDisplay(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppTheme.textMuted),
            ]),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _showVersionPicker,
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.orangeTint,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Text(_version.abbreviation, style: GoogleFonts.dmSans(
                  fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            ),
          ),
          GestureDetector(
            onTap: _showFontSize,
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppTheme.orangeTint, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.format_size_rounded, size: 18, color: AppTheme.primaryDark),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppTheme.divider)),
      ),
      body: Column(children: [
        Expanded(
          child: _loading
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: AppTheme.orangeTint, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.menu_book_rounded, color: AppTheme.primary, size: 26),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5),
                ]))
              : _verses.isEmpty
                  ? Center(child: Text('Could not load chapter',
                      style: GoogleFonts.dmSans(color: AppTheme.textSecondary)))
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      itemCount: _verses.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) return _ChapterHeader(book: _book.name, chapter: _chapter, version: _version.abbreviation);
                        return _VerseRow(
                          verse: _verses[i-1],
                          fontSize: _fontSize,
                          onShare: _shareVerse,
                          onBookmark: _bookmarkVerse,
                        );
                      },
                    ),
        ),
        // ── Chapter nav bar ──────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border(top: BorderSide(color: AppTheme.divider)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, -4))],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(children: [
            _NavBtn(icon: Icons.arrow_back_ios_rounded, label: 'Prev', onTap: _prev),
            Expanded(child: Column(children: [
              Text('${_book.name} ${_chapter}', style: GoogleFonts.playfairDisplay(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              Text('Ch. ${_chapter} of ${_book.chapters}', style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppTheme.textMuted)),
            ])),
            _NavBtn(icon: Icons.arrow_forward_ios_rounded, label: 'Next', onTap: _next, reversed: true),
          ]),
        ),
      ]),
    );
  }

  void _showBookPicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookSheet(current: _book, onSelect: (b) {
        setState(() { _book = b; _chapter = 1; }); _fetch();
      }),
    );
  }

  void _showVersionPicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => _VersionSheet(versions: BibleData.versions, current: _version,
          onSelect: (v) { setState(() => _version = v); _fetch(); }),
    );
  }

  void _showFontSize() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, set) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Text Size', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Drag to adjust reading size', style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted)),
          const SizedBox(height: 20),
          Row(children: [
            Text('A', style: GoogleFonts.playfairDisplay(fontSize: 14, color: AppTheme.textSecondary)),
            Expanded(child: SliderTheme(
              data: SliderTheme.of(ctx).copyWith(
                activeTrackColor: AppTheme.primary, thumbColor: AppTheme.primary,
                inactiveTrackColor: AppTheme.divider, overlayColor: AppTheme.primary.withOpacity(0.15),
              ),
              child: Slider(
                value: _fontSize, min: 13, max: 26, divisions: 13,
                onChanged: (v) { set(() {}); setState(() => _fontSize = v); },
              ),
            )),
            Text('A', style: GoogleFonts.playfairDisplay(fontSize: 22, color: AppTheme.textSecondary)),
          ]),
          const SizedBox(height: 8),
        ]),
      )),
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  final String book, version;
  final int chapter;
  const _ChapterHeader({required this.book, required this.chapter, required this.version});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.orangeTint2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(version, style: GoogleFonts.dmSans(
            fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
      ),
      const SizedBox(height: 10),
      Text(book, style: GoogleFonts.playfairDisplay(
          fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      Text('Chapter $chapter', style: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 30, height: 1.5, color: AppTheme.primary.withOpacity(0.3)),
        const SizedBox(width: 8),
        Text('✦', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
        const SizedBox(width: 8),
        Container(width: 30, height: 1.5, color: AppTheme.primary.withOpacity(0.3)),
      ]),
    ]),
  );
}

class _VerseRow extends StatefulWidget {
  final BibleVerse verse;
  final double fontSize;
  final Future<void> Function(BibleVerse) onShare;
  final Future<void> Function(BibleVerse)? onBookmark;
  const _VerseRow({required this.verse, required this.fontSize, required this.onShare, this.onBookmark});
  @override State<_VerseRow> createState() => _VerseRowState();
}

class _VerseRowState extends State<_VerseRow> {
  bool _highlighted = false;
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        setState(() => _showActions = !_showActions);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: _highlighted ? AppTheme.orangeTint : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: '${widget.verse.number}  ',
                style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary, height: 1.8),
              ),
              TextSpan(
                text: widget.verse.text,
                style: GoogleFonts.playfairDisplay(
                    fontSize: widget.fontSize, color: AppTheme.textPrimary, height: 1.75),
              ),
            ]),
          ),
          if (_showActions)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 20),
              child: Row(children: [
                _VAction(icon: Icons.highlight_rounded, label: 'Highlight', color: AppTheme.primary,
                    onTap: () { setState(() { _highlighted = !_highlighted; _showActions = false; }); }),
                const SizedBox(width: 8),
                _VAction(icon: Icons.share_rounded, label: 'Share', color: AppTheme.primaryDark,
                    onTap: () { setState(() => _showActions = false); widget.onShare(widget.verse); }),
                const SizedBox(width: 8),
                _VAction(icon: Icons.bookmark_outline_rounded, label: 'Save', color: AppTheme.primaryDeeper,
                    onTap: () {
                      setState(() => _showActions = false);
                      widget.onBookmark?.call(widget.verse);
                    }),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _VAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _VAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () { HapticFeedback.selectionClick(); onTap(); },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ]),
    ),
  );
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool reversed;
  const _NavBtn({required this.icon, required this.label, required this.onTap, this.reversed = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.orangeTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (!reversed) ...[Icon(icon, size: 14, color: AppTheme.primary), const SizedBox(width: 5)],
        Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
        if (reversed)  ...[const SizedBox(width: 5), Icon(icon, size: 14, color: AppTheme.primary)],
      ]),
    ),
  );
}

// ── Book picker sheet ─────────────────────────────────────────────────────────
class _BookSheet extends StatefulWidget {
  final BibleBook current;
  final ValueChanged<BibleBook> onSelect;
  const _BookSheet({required this.current, required this.onSelect});
  @override State<_BookSheet> createState() => _BookSheetState();
}

class _BookSheetState extends State<_BookSheet> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height * 0.82,
    decoration: const BoxDecoration(
      color: AppTheme.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: Column(children: [
      Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Choose Book', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700)),
          GestureDetector(onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close_rounded, color: AppTheme.textMuted)),
        ]),
      ),
      const SizedBox(height: 12),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: AppTheme.orangeTint, borderRadius: BorderRadius.circular(12)),
        child: TabBar(
          controller: _tab,
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.textSecondary,
          indicator: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [Tab(text: 'Old Testament'), Tab(text: 'New Testament')],
        ),
      ),
      const SizedBox(height: 4),
      Expanded(child: TabBarView(controller: _tab, children: [
        _BookList(books: BibleData.oldTestament, current: widget.current,
            onSelect: (b) { Navigator.pop(context); widget.onSelect(b); }),
        _BookList(books: BibleData.newTestament, current: widget.current,
            onSelect: (b) { Navigator.pop(context); widget.onSelect(b); }),
      ])),
    ]),
  );
}

class _BookList extends StatelessWidget {
  final List<BibleBook> books;
  final BibleBook current;
  final ValueChanged<BibleBook> onSelect;
  const _BookList({required this.books, required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    itemCount: books.length,
    itemBuilder: (_, i) {
      final b = books[i];
      final sel = b.name == current.name;
      return GestureDetector(
        onTap: () { HapticFeedback.selectionClick(); onSelect(b); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: sel ? AppTheme.orangeTint : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? AppTheme.primary.withOpacity(0.3) : Colors.transparent),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.name, style: GoogleFonts.dmSans(
                  fontSize: 15, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                  color: sel ? AppTheme.primary : AppTheme.textPrimary)),
              Text('${b.chapters} chapters', style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted)),
            ])),
            if (sel) const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 18),
          ]),
        ),
      );
    },
  );
}

// ── Version picker ────────────────────────────────────────────────────────────
class _VersionSheet extends StatelessWidget {
  final List<BibleVersion> versions;
  final BibleVersion current;
  final ValueChanged<BibleVersion> onSelect;
  const _VersionSheet({required this.versions, required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AppTheme.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Bible Version', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700)),
          GestureDetector(onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close_rounded, color: AppTheme.textMuted)),
        ]),
      ),
      const Divider(height: 1),
      ...versions.map((v) {
        final sel = v.id == current.id;
        return GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); Navigator.pop(context); onSelect(v); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: sel ? AppTheme.orangeTint : Colors.transparent,
            ),
            child: Row(children: [
              Container(
                width: 44, height: 26,
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primary : AppTheme.divider,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: Text(v.abbreviation, style: GoogleFonts.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w800,
                    color: sel ? AppTheme.white : AppTheme.textSecondary))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v.name, style: GoogleFonts.dmSans(
                    fontSize: 14, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                    color: sel ? AppTheme.primary : AppTheme.textPrimary)),
                Text(v.language, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted)),
              ])),
              if (sel) const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 18),
            ]),
          ),
        );
      }),
      const SizedBox(height: 16),
    ]),
  );
}
