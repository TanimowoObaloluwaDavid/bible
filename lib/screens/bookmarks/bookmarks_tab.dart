import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:scripture_daily/theme/app_theme.dart';
import 'package:scripture_daily/models/models.dart';
import 'package:scripture_daily/services/auth_provider.dart';
import 'package:scripture_daily/services/firestore_service.dart';

class BookmarksTab extends StatelessWidget {
  const BookmarksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Saved Verses', style: GoogleFonts.playfairDisplay(
            fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppTheme.divider)),
      ),
      body: StreamBuilder<List<Bookmark>>(
        stream: FirestoreService.bookmarksStream(uid),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }
          if (snap.hasError) {
            return Center(child: Text('Could not load bookmarks',
                style: GoogleFonts.dmSans(color: AppTheme.textSecondary)));
          }
          final bookmarks = snap.data ?? [];
          if (bookmarks.isEmpty) return _EmptyBookmarks();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            itemBuilder: (_, i) => _BookmarkCard(
              bookmark: bookmarks[i],
              onDelete: (b) async {
                HapticFeedback.mediumImpact();
                await FirestoreService.deleteBookmark(uid, b.id);
              },
              onShare: (b) async {
                HapticFeedback.lightImpact();
                await Share.share(
                  '"${b.text}"\n— ${b.reference} (${b.versionId.toUpperCase()})\n\nShared via Scripture Daily ✦',
                  subject: b.reference,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final ValueChanged<Bookmark> onDelete;
  final ValueChanged<Bookmark> onShare;
  const _BookmarkCard({required this.bookmark, required this.onDelete, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03),
            blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Text(bookmark.reference, style: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: AppTheme.primary, letterSpacing: 0.3)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.orangeTint2,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(bookmark.versionId.toUpperCase(), style: GoogleFonts.dmSans(
                  fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
            ),
          ]),
          Row(children: [
            GestureDetector(
              onTap: () => onShare(bookmark),
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: AppTheme.orangeTint,
                    borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.share_rounded, size: 15, color: AppTheme.primary),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => onDelete(bookmark),
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(Icons.delete_outline_rounded, size: 15, color: AppTheme.error),
              ),
            ),
          ]),
        ]),
        const SizedBox(height: 10),
        Text('"${bookmark.text}"', style: GoogleFonts.playfairDisplay(
            fontSize: 15, fontStyle: FontStyle.italic,
            color: AppTheme.textPrimary, height: 1.7)),
        const SizedBox(height: 10),
        Text(DateFormat('MMM d, yyyy').format(bookmark.savedAt),
            style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted)),
      ]),
    );
  }
}

class _EmptyBookmarks extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.bookmark_outline_rounded, color: AppTheme.white, size: 38),
        ),
        const SizedBox(height: 20),
        Text('No Saved Verses', style: GoogleFonts.playfairDisplay(
            fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text('Long-press any verse in the Bible\nreader to save it here.',
          style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
          textAlign: TextAlign.center),
      ]),
    ),
  );
}
