import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scripture_daily/models/models.dart';

class FirestoreService {
  static String _pk(String uid) => 'prayers_$uid';
  static String _bk(String uid) => 'bookmarks_$uid';

  // ── Prayers ─────────────────────────────────────────────────────────────────

  static Stream<List<PrayerEntry>> prayersStream(String uid) async* {
    yield await _loadPrayers(uid);
  }

  static Future<List<PrayerEntry>> _loadPrayers(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_pk(uid)) ?? [];
    return raw.map((s) => PrayerEntry.fromJson(json.decode(s))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> addPrayer(String uid, PrayerEntry e) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_pk(uid)) ?? [];
    raw.insert(0, json.encode(e.toJson()));
    await prefs.setStringList(_pk(uid), raw);
  }

  static Future<void> updatePrayer(String uid, PrayerEntry e) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_pk(uid)) ?? [];
    final list = raw.map((s) => PrayerEntry.fromJson(json.decode(s))).toList();
    final idx = list.indexWhere((x) => x.id == e.id);
    if (idx != -1) { list[idx] = e; await prefs.setStringList(_pk(uid), list.map((x) => json.encode(x.toJson())).toList()); }
  }

  static Future<void> deletePrayer(String uid, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_pk(uid)) ?? [];
    final list = raw.map((s) => PrayerEntry.fromJson(json.decode(s))).toList()
      ..removeWhere((x) => x.id == id);
    await prefs.setStringList(_pk(uid), list.map((x) => json.encode(x.toJson())).toList());
  }

  // ── Bookmarks ────────────────────────────────────────────────────────────────

  static Stream<List<Bookmark>> bookmarksStream(String uid) async* {
    yield await _loadBookmarks(uid);
  }

  static Future<List<Bookmark>> _loadBookmarks(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bk(uid)) ?? [];
    return raw.map((s) => Bookmark.fromJson(json.decode(s))).toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  static Future<void> addBookmark(String uid, Bookmark b) async {
    final list = await _loadBookmarks(uid);
    if (list.any((x) => x.reference == b.reference)) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bk(uid)) ?? [];
    raw.insert(0, json.encode(b.toJson()));
    await prefs.setStringList(_bk(uid), raw);
  }

  static Future<void> deleteBookmark(String uid, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bk(uid)) ?? [];
    final list = raw.map((s) => Bookmark.fromJson(json.decode(s))).toList()
      ..removeWhere((x) => x.id == id);
    await prefs.setStringList(_bk(uid), list.map((x) => json.encode(x.toJson())).toList());
  }

  static Future<bool> isBookmarked(String uid, String reference) async {
    final list = await _loadBookmarks(uid);
    return list.any((b) => b.reference == reference);
  }
}
