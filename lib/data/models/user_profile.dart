import 'local_day.dart';
import 'row_values.dart';

/// The local learner profile.
///
/// Lumio keeps a single profile on the device; [id] `1` is the seeded default
/// so every other table has a stable foreign key from the first launch.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayNameAr,
    this.displayNameEn,
    this.avatarEmoji,
    this.gradeLevelAr,
    this.gradeLevelEn,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Reads a profile from a database row.
  factory UserProfile.fromRow(Map<String, Object?> row) => UserProfile(
        id: intValue(row['id']),
        displayNameAr: textValue(row['display_name_ar']),
        displayNameEn: textOrNull(row['display_name_en']),
        avatarEmoji: textOrNull(row['avatar_emoji']),
        gradeLevelAr: textOrNull(row['grade_level_ar']),
        gradeLevelEn: textOrNull(row['grade_level_en']),
        createdAt: dateTimeValue(row['created_at']),
        updatedAt: dateTimeOrNull(row['updated_at']),
        isActive: boolValue(row['is_active']),
      );

  final int id;
  final String displayNameAr;
  final String? displayNameEn;
  final String? avatarEmoji;
  final String? gradeLevelAr;
  final String? gradeLevelEn;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  /// The display name for [languageCode], falling back to Arabic.
  String displayName(String languageCode) =>
      languageCode == 'ar' ? displayNameAr : (displayNameEn ?? displayNameAr);

  /// The grade label for [languageCode], falling back to Arabic.
  String? gradeLevel(String languageCode) =>
      languageCode == 'ar' ? gradeLevelAr : (gradeLevelEn ?? gradeLevelAr);

  /// Row representation including the primary key.
  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'display_name_ar': displayNameAr,
        'display_name_en': displayNameEn,
        'avatar_emoji': avatarEmoji,
        'grade_level_ar': gradeLevelAr,
        'grade_level_en': gradeLevelEn,
        'created_at': dateTimeToMillis(createdAt),
        'updated_at': updatedAt == null ? null : dateTimeToMillis(updatedAt!),
        'is_active': boolToInt(isActive),
      };

  /// Row representation for an insert, without the primary key.
  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  UserProfile copyWith({
    String? displayNameAr,
    String? displayNameEn,
    String? avatarEmoji,
    String? gradeLevelAr,
    String? gradeLevelEn,
    DateTime? updatedAt,
    bool? isActive,
  }) =>
      UserProfile(
        id: id,
        displayNameAr: displayNameAr ?? this.displayNameAr,
        displayNameEn: displayNameEn ?? this.displayNameEn,
        avatarEmoji: avatarEmoji ?? this.avatarEmoji,
        gradeLevelAr: gradeLevelAr ?? this.gradeLevelAr,
        gradeLevelEn: gradeLevelEn ?? this.gradeLevelEn,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
      );

  /// Today's local day, exposed for callers that need a consistent bucket.
  LocalDay get today => LocalDay.today();

  @override
  String toString() => 'UserProfile($id, $displayNameAr)';
}