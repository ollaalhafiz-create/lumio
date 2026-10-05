import 'row_values.dart';

/// A user-authored or seeded note attached to a study item.
///
/// Notes follow the same bilingual contract as the rest of the content: the
/// learner types [bodyAr], and an English version can be filled in later.
class ReviewNote {
  const ReviewNote({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.bodyAr,
    this.bodyEn,
    this.isPinned = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReviewNote.fromRow(Map<String, Object?> row) => ReviewNote(
        id: intValue(row['id']),
        userId: intValue(row['user_id']),
        entityType: textValue(row['entity_type']),
        entityId: intValue(row['entity_id']),
        bodyAr: textValue(row['body_ar']),
        bodyEn: textOrNull(row['body_en']),
        isPinned: boolValue(row['is_pinned']),
        createdAt: dateTimeValue(row['created_at']),
        updatedAt: dateTimeOrNull(row['updated_at']),
      );

  final int id;
  final int userId;

  /// `subject`, `chapter`, `lesson`, `quiz`, `question` or `flashcard`.
  final String entityType;

  final int entityId;

  /// Arabic note text. This is the field the learner writes.
  final String bodyAr;

  /// Optional English translation of [bodyAr].
  final String? bodyEn;

  final bool isPinned;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// The note for [languageCode], falling back to Arabic.
  String body(String languageCode) =>
      languageCode == 'ar' ? bodyAr : (bodyEn ?? bodyAr);

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'user_id': userId,
        'entity_type': entityType,
        'entity_id': entityId,
        'body_ar': bodyAr,
        'body_en': bodyEn,
        'is_pinned': boolToInt(isPinned),
        'created_at': dateTimeToMillis(createdAt),
        'updated_at': updatedAt == null ? null : dateTimeToMillis(updatedAt!),
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  ReviewNote copyWith({
    int? id,
    String? bodyAr,
    String? bodyEn,
    bool? isPinned,
    DateTime? updatedAt,
  }) =>
      ReviewNote(
        id: id ?? this.id,
        userId: userId,
        entityType: entityType,
        entityId: entityId,
        bodyAr: bodyAr ?? this.bodyAr,
        bodyEn: bodyEn ?? this.bodyEn,
        isPinned: isPinned ?? this.isPinned,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => 'ReviewNote($id, $entityType:$entityId)';
}