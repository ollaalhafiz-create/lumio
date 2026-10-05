import 'enums.dart';
import 'localized_text.dart';
import 'row_values.dart';

/// A lesson inside a chapter: the reading the learner studies before the
/// questions of [Lesson.id] are asked.
class Lesson {
  const Lesson({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.body,
    this.type = LessonType.reading,
    this.difficulty = Difficulty.easy,
    this.durationMinutes = 0,
    this.sortOrder = 0,
    this.isPublished = true,
    required this.createdAt,
  });

  /// Reads a lesson from a database row.
  factory Lesson.fromRow(Map<String, Object?> row) => Lesson(
        id: intValue(row['id']),
        chapterId: intValue(row['chapter_id']),
        title: LocalizedText.fromColumns(row['title_ar'], row['title_en']),
        body: LocalizedText.fromColumns(row['body_ar'], row['body_en']),
        type: LessonType.fromValue(row['lesson_type']),
        difficulty: Difficulty.fromValue(row['difficulty']),
        durationMinutes: intValue(row['duration_minutes']),
        sortOrder: intValue(row['sort_order']),
        isPublished: boolValue(row['is_published']),
        createdAt: dateTimeValue(row['created_at']),
      );

  final int id;
  final int chapterId;

  /// Bilingual lesson title; Arabic is primary.
  final LocalizedText title;

  /// Bilingual lesson text. Stored with `\n` line breaks, never with
  /// direction-sensitive punctuation assembled by the data layer.
  final LocalizedText body;

  final LessonType type;
  final Difficulty difficulty;

  /// Suggested reading time in minutes.
  final int durationMinutes;

  final int sortOrder;
  final bool isPublished;
  final DateTime createdAt;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'chapter_id': chapterId,
        'title_ar': title.ar,
        'title_en': title.en,
        'body_ar': body.ar,
        'body_en': body.en,
        'lesson_type': type.key,
        'difficulty': difficulty.level,
        'duration_minutes': durationMinutes,
        'sort_order': sortOrder,
        'is_published': boolToInt(isPublished),
        'created_at': dateTimeToMillis(createdAt),
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  Lesson copyWith({
    LocalizedText? title,
    LocalizedText? body,
    LessonType? type,
    Difficulty? difficulty,
    int? durationMinutes,
    int? sortOrder,
    bool? isPublished,
  }) =>
      Lesson(
        id: id,
        chapterId: chapterId,
        title: title ?? this.title,
        body: body ?? this.body,
        type: type ?? this.type,
        difficulty: difficulty ?? this.difficulty,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        sortOrder: sortOrder ?? this.sortOrder,
        isPublished: isPublished ?? this.isPublished,
        createdAt: createdAt,
      );

  @override
  String toString() => 'Lesson($id, ${title.ar})';
}