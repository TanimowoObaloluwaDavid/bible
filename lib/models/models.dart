// ─── Bible Models ─────────────────────────────────────────────────────────────

class BibleVersion {
  final String id;
  final String name;
  final String abbreviation;
  final String language;
  final String languageCode;

  const BibleVersion({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.language,
    required this.languageCode,
  });
}

class BibleBook {
  final String id;
  final String name;
  final String testament; // OT or NT
  final int chapters;

  const BibleBook({
    required this.id,
    required this.name,
    required this.testament,
    required this.chapters,
  });
}

class BibleVerse {
  final int number;
  final String text;
  bool isHighlighted;
  bool isBookmarked;
  String? note;

  BibleVerse({
    required this.number,
    required this.text,
    this.isHighlighted = false,
    this.isBookmarked = false,
    this.note,
  });
}

class BibleChapter {
  final String bookName;
  final int chapter;
  final List<BibleVerse> verses;
  final String reference;

  const BibleChapter({
    required this.bookName,
    required this.chapter,
    required this.verses,
    required this.reference,
  });
}

// ─── Prayer Models ────────────────────────────────────────────────────────────

class PrayerEntry {
  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime createdAt;
  bool isAnswered;
  String? answeredNote;

  PrayerEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    this.isAnswered = false,
    this.answeredNote,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
    'isAnswered': isAnswered,
    'answeredNote': answeredNote,
  };

  factory PrayerEntry.fromJson(Map<String, dynamic> json) => PrayerEntry(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    category: json['category'],
    createdAt: DateTime.parse(json['createdAt']),
    isAnswered: json['isAnswered'] ?? false,
    answeredNote: json['answeredNote'],
  );

  static const List<String> categories = [
    'Gratitude',
    'Intercession',
    'Confession',
    'Petition',
    'Praise',
    'Healing',
    'Guidance',
    'Family',
    'Daily Word',
  ];
}

// ─── Bookmark ─────────────────────────────────────────────────────────────────

class Bookmark {
  final String id;
  final String reference;
  final String text;
  final String versionId;
  final DateTime savedAt;
  final String? note;

  const Bookmark({
    required this.id,
    required this.reference,
    required this.text,
    required this.versionId,
    required this.savedAt,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'text': text,
    'versionId': versionId,
    'savedAt': savedAt.toIso8601String(),
    'note': note,
  };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    id: json['id'],
    reference: json['reference'],
    text: json['text'],
    versionId: json['versionId'],
    savedAt: DateTime.parse(json['savedAt']),
    note: json['note'],
  );
}
