import 'enums.dart';
import 'localized_text.dart';
import 'row_values.dart';

/// A bilingual flashcard for revision.
class Flashcard {
  const Flashcard({
    required this.id,
    required this.subjectId,
    this.chapterId,
    this.lessonId,
    required this.front,
    required this.back,
    this.hint = LocalizedText.empty,
    this.difficulty = Difficulty.easy,
    this.sortOrder = 0,
    this.isArchived = false,
    required this.createdAt,
  });

  factory Flashcard.fromRow(Map<String, Object?> row) => Flashcard(
        id: intValue(row['id']),
        subjectId: intValue(row['subject_id']),
        chapterId: intOrNull(row['chapter_id']),
        lessonId: intOrNull(row['lesson_id']),
        front: LocalizedText.fromColumns(row['front_ar'], row['front_en']),
        back: LocalizedText.fromColumns(row['back_ar'], row['back_en']),
        hint: LocalizedText.fromColumns(row['hint_ar'], row['hint_en']),
        difficulty: Difficulty.fromValue(row['difficulty']),
        sortOrder: intValue(row['sort_order']),
        isArchived: boolValue(row['is_archived']),
        createdAt: dateTimeValue(row['created_at']),
      );

  final int id;
  final int subjectId;
  final int? chapterId;
  final int? lessonId;

  /// Bilingual prompt side; Arabic is primary.
  final LocalizedText front;

  /// Bilingual answer side; Arabic is primary.
  final LocalizedText back;

  /// Bilingual optional hint.
  final LocalizedText hint;

  final Difficulty difficulty;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'subject_id': subjectId,
        'chapter_id': chapterId,
        'lesson_id': lessonId,
        'front_ar': front.ar,
        'front_en': front.en,
        'back_ar': back.ar,
        'back_en': back.en,
        'hint_ar': hint.ar,
        'hint_en': hint.en,
        'difficulty': difficulty.level,
        'sort_order': sortOrder,
        'is_archived': boolToInt(isArchived),
        'created_at': dateTimeToMillis(createdAt),
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  Flashcard copyWith({
    LocalizedText? front,
    LocalizedText? back,
    LocalizedText? hint,
    bool? isArchived,
  }) =>
      Flashcard(
        id: id,
        subjectId: subjectId,
        chapterId: chapterId,
        lessonId: lessonId,
        front: front ?? this.front,
        back: back ?? this.back,
        hint: hint ?? this.hint,
        difficulty: difficulty,
        sortOrder: sortOrder,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt,
      );

  @override
  String toString() => 'Flashcard($id)';
}