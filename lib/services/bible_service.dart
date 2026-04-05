import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scripture_daily/models/models.dart';

class BibleService {
  static const String _baseUrl = 'https://bible-api.com';

  // bible-api.com wants spaces NOT encoded as %20 or +
  // e.g. https://bible-api.com/john 3:16
  // Book IDs stored with + (e.g. 1+Samuel) need to become spaces in the URL
  static String _buildUrl(String ref, String translation) {
    // Replace + with space, then build URL without encoding the path
    final cleanRef = ref.replaceAll('+', ' ');
    final uri = Uri.parse('$_baseUrl/$cleanRef?translation=$translation');
    return uri.toString();
  }

  // Fetch a full chapter
  static Future<List<BibleVerse>> fetchChapter(
    String bookId,
    int chapter, {
    String translation = 'kjv',
  }) async {
    try {
      final ref = '${bookId.replaceAll('+', ' ')} $chapter';
      final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(ref)}')
          .replace(queryParameters: {'translation': translation});
      final response = await http.get(uri, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final verses = data['verses'] as List?;
        if (verses == null) return [];
        return verses.map((v) => BibleVerse(
          number: v['verse'] as int,
          text: (v['text'] as String).trim(),
        )).toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  // Get daily verse
  static Future<Map<String, String>?> getDailyVerse(
    String ref, {
    String translation = 'kjv',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(ref)}')
          .replace(queryParameters: {'translation': translation});
      final response = await http.get(uri, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['text']?.toString().trim() ?? '';
        final reference = data['reference']?.toString() ?? ref;
        if (text.isNotEmpty) {
          return {'reference': reference, 'text': text};
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  // Fetch a specific verse
  static Future<String?> fetchVerse(
    String reference, {
    String translation = 'kjv',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(reference)}')
          .replace(queryParameters: {'translation': translation});
      final response = await http.get(uri, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['text']?.toString().trim();
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  // Search verses
  static Future<List<Map<String, dynamic>>> searchVerses(
    String query, {
    String translation = 'kjv',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(query)}')
          .replace(queryParameters: {'translation': translation});
      final response = await http.get(uri, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['verses'] != null) {
          return List<Map<String, dynamic>>.from(data['verses']);
        }
      }
    } catch (e) {
      // ignore
    }
    return [];
  }
}
