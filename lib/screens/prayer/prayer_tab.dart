import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:scripture_daily/theme/app_theme.dart';
import 'package:scripture_daily/models/models.dart';
import 'package:scripture_daily/services/auth_provider.dart';
import 'package:scripture_daily/services/firestore_service.dart';
import 'package:scripture_daily/widgets/animated_button.dart';

class PrayerTab extends StatefulWidget {
  const PrayerTab({super.key});
  @override State<PrayerTab> createState() => _PrayerTabState();
}

class _PrayerTabState extends State<PrayerTab> {
  String _filterCategory = 'All';

  void _showAddPrayer(String uid) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPrayerSheet(onSave: (entry) async {
        await FirestoreService.addPrayer(uid, entry);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    if (uid == null) return const SizedBox.shrink();

    final categories = ['All', 'Answered', ...PrayerEntry.categories];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Prayer Journal', style: GoogleFonts.playfairDisplay(
            fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppTheme.divider)),
      ),
      body: Column(children: [
        // Category filter chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final cat = categories[i];
              final isSel = _filterCategory == cat;
              return GestureDetector(
                onTap: () { HapticFeedback.selectionClick(); setState(() => _filterCategory = cat); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? AppTheme.primary : AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSel ? AppTheme.primary : AppTheme.divider),
                  ),
                  child: Text(cat, style: GoogleFonts.dmSans(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: isSel ? AppTheme.white : AppTheme.textSecondary)),
                ),
              );
            },
          ),
        ),

        // Prayers list — real-time from Firestore
        Expanded(
          child: StreamBuilder<List<PrayerEntry>>(
            stream: FirestoreService.prayersStream(uid),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
              }
              if (snap.hasError) {
                return Center(child: Text('Could not load prayers',
                    style: GoogleFonts.dmSans(color: AppTheme.textSecondary)));
              }
              final all = snap.data ?? [];
              final filtered = _filterCategory == 'All'
                  ? all
                  : _filterCategory == 'Answered'
                      ? all.where((p) => p.isAnswered).toList()
                      : all.where((p) => p.category == _filterCategory).toList();

              if (filtered.isEmpty) return _EmptyPrayer(onAdd: () => _showAddPrayer(uid));

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _PrayerCard(
                  entry: filtered[i],
                  onToggleAnswered: (e) async {
                    e.isAnswered = !e.isAnswered;
                    await FirestoreService.updatePrayer(uid, e);
                  },
                  onDelete: (e) async {
                    await FirestoreService.deletePrayer(uid, e.id);
                  },
                ),
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPrayer(uid),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.white,
        elevation: 4,
        label: Text('Add Prayer', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700)),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerEntry entry;
  final ValueChanged<PrayerEntry> onToggleAnswered;
  final ValueChanged<PrayerEntry> onDelete;
  const _PrayerCard({required this.entry, required this.onToggleAnswered, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: entry.isAnswered
            ? AppTheme.success.withOpacity(0.35) : AppTheme.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03),
            blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.orangeTint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(entry.category, style: GoogleFonts.dmSans(
                      fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
                ),
                if (entry.isAnswered) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_rounded, size: 10, color: AppTheme.success),
                      const SizedBox(width: 3),
                      Text('Answered', style: GoogleFonts.dmSans(
                          fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.success)),
                    ]),
                  ),
                ],
              ]),
              const SizedBox(height: 8),
              Text(entry.title, style: GoogleFonts.playfairDisplay(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ])),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, size: 18, color: AppTheme.textMuted),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'answered', child: Text(
                  entry.isAnswered ? 'Mark Unanswered' : 'Mark as Answered',
                  style: GoogleFonts.dmSans(fontSize: 14))),
                PopupMenuItem(value: 'delete', child: Text('Delete',
                    style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.error))),
              ],
              onSelected: (v) {
                if (v == 'answered') onToggleAnswered(entry);
                else onDelete(entry);
              },
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.body, style: GoogleFonts.playfairDisplay(
                fontSize: 14, color: AppTheme.textSecondary, height: 1.65,
                fontStyle: FontStyle.italic),
              maxLines: 4, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Text(DateFormat('MMM d, yyyy • h:mm a').format(entry.createdAt),
                style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted)),
          ]),
        ),
      ]),
    );
  }
}

class _EmptyPrayer extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyPrayer({required this.onAdd});
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
          child: const Icon(Icons.self_improvement_rounded, color: AppTheme.white, size: 38),
        ),
        const SizedBox(height: 20),
        Text('Start Your Prayer Journal', style: GoogleFonts.playfairDisplay(
            fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text('Write prayers, track answered ones,\nand grow deeper in faith.',
          style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
          textAlign: TextAlign.center),
        const SizedBox(height: 24),
        BounceButton(
          label: 'Write First Prayer',
          icon: const Icon(Icons.add_rounded, color: AppTheme.white, size: 18),
          onTap: onAdd,
        ),
      ]),
    ),
  );
}

class _AddPrayerSheet extends StatefulWidget {
  final ValueChanged<PrayerEntry> onSave;
  const _AddPrayerSheet({required this.onSave});
  @override State<_AddPrayerSheet> createState() => _AddPrayerSheetState();
}

class _AddPrayerSheetState extends State<_AddPrayerSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  String _category = 'Daily Word';
  @override void dispose() { _titleCtrl.dispose(); _bodyCtrl.dispose(); super.dispose(); }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    widget.onSave(PrayerEntry(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
      category: _category,
      createdAt: DateTime.now(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(
            width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2)),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('New Prayer', style: GoogleFonts.playfairDisplay(
                    fontSize: 18, fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Save', style: GoogleFonts.dmSans(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.white)),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: PrayerEntry.categories.map((c) {
                  final isSel = _category == c;
                  return GestureDetector(
                    onTap: () { HapticFeedback.selectionClick(); setState(() => _category = c); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel ? AppTheme.primary : AppTheme.orangeTint,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSel ? AppTheme.primary : AppTheme.divider),
                      ),
                      child: Text(c, style: GoogleFonts.dmSans(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: isSel ? AppTheme.white : AppTheme.textSecondary)),
                    ),
                  );
                }).toList()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'Prayer title...',
                  hintStyle: GoogleFonts.playfairDisplay(fontSize: 16, color: AppTheme.textMuted),
                  border: InputBorder.none, enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none, contentPadding: EdgeInsets.zero,
                ),
              ),
              Container(height: 1, color: AppTheme.divider, margin: const EdgeInsets.symmetric(vertical: 10)),
              TextField(
                controller: _bodyCtrl,
                maxLines: 5,
                style: GoogleFonts.playfairDisplay(fontSize: 15, color: AppTheme.textPrimary,
                    height: 1.7, fontStyle: FontStyle.italic),
                decoration: InputDecoration(
                  hintText: 'Write your prayer here...',
                  hintStyle: GoogleFonts.playfairDisplay(fontSize: 15, color: AppTheme.textMuted,
                      fontStyle: FontStyle.italic),
                  border: InputBorder.none, enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none, contentPadding: EdgeInsets.zero,
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
