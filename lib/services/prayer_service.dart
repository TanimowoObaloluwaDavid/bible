import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scripture_daily/models/models.dart';

class PrayerService {
  static const _key = 'prayer_entries';
  static const _bookmarksKey = 'bookmarks';

  // ─── Prayers ─────────────────────────────────────────────────────────────────

  static Future<List<PrayerEntry>> loadPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => PrayerEntry.fromJson(json.decode(s))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> savePrayer(PrayerEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(json.encode(entry.toJson()));
    await prefs.setStringList(_key, raw);
  }

  static Future<void> updatePrayer(PrayerEntry updated) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final list = raw.map((s) => PrayerEntry.fromJson(json.decode(s))).toList();
    final idx = list.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      list[idx] = updated;
      await prefs.setStringList(_key, list.map((e) => json.encode(e.toJson())).toList());
    }
  }

  static Future<void> deletePrayer(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final list = raw.map((s) => PrayerEntry.fromJson(json.decode(s))).toList();
    list.removeWhere((e) => e.id == id);
    await prefs.setStringList(_key, list.map((e) => json.encode(e.toJson())).toList());
  }

  // ─── Bookmarks ────────────────────────────────────────────────────────────────

  static Future<List<Bookmark>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bookmarksKey) ?? [];
    return raw.map((s) => Bookmark.fromJson(json.decode(s))).toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  static Future<void> saveBookmark(Bookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bookmarksKey) ?? [];
    final list = raw.map((s) => Bookmark.fromJson(json.decode(s))).toList();
    if (!list.any((b) => b.reference == bookmark.reference)) {
      list.insert(0, bookmark);
      await prefs.setStringList(_bookmarksKey, list.map((e) => json.encode(e.toJson())).toList());
    }
  }

  static Future<void> deleteBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bookmarksKey) ?? [];
    final list = raw.map((s) => Bookmark.fromJson(json.decode(s))).toList();
    list.removeWhere((e) => e.id == id);
    await prefs.setStringList(_bookmarksKey, list.map((e) => json.encode(e.toJson())).toList());
  }
}
