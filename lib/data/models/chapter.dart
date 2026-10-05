import 'localized_text.dart';
import 'row_values.dart';

/// A chapter of a subject, for example `المعادلات الخطية`.
class Chapter {
  const Chapter({
    required this.id,
    required this.subjectId,
    required this.title,
    this.summary = LocalizedText.empty,
    this.estimatedMinutes = 0,
    this.sortOrder = 0,
  });

  /// Reads a chapter from a database row.
  factory Chapter.fromRow(Map<String, Object?> row) => Chapter(
        id: intValue(row['id']),
        subjectId: intValue(row['subject_id']),
        title: LocalizedText.fromColumns(row['title_ar'], row['title_en']),
        summary: LocalizedText.fromColumns(row['summary_ar'], row['summary_en']),
        estimatedMinutes: intValue(row['estimated_minutes']),
        sortOrder: intValue(row['sort_order']),
      );

  final int id;
  final int subjectId;

  /// Bilingual chapter title; Arabic is primary.
  final LocalizedText title;

  /// Bilingual short summary.
  final LocalizedText summary;

  /// Estimated study time in minutes, shown as a hint only.
  final int estimatedMinutes;

  final int sortOrder;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'subject_id': subjectId,
        'title_ar': title.ar,
        'title_en': title.en,
        'summary_ar': summary.ar,
        'summary_en': summary.en,
        'estimated_minutes': estimatedMinutes,
        'sort_order': sortOrder,
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  Chapter copyWith({
    LocalizedText? title,
    LocalizedText? summary,
    int? estimatedMinutes,
    int? sortOrder,
  }) =>
      Chapter(
        id: id,
        subjectId: subjectId,
        title: title ?? this.title,
        summary: summary ?? this.summary,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  @override
  String toString() => 'Chapter($id, ${title.ar})';
}