import 'localized_text.dart';
import 'row_values.dart';

/// A study subject such as `الرياضيات` or `اللغة العربية`.
class Subject {
  const Subject({
    required this.id,
    required this.name,
    this.description = LocalizedText.empty,
    required this.iconKey,
    required this.colorHex,
    this.sortOrder = 0,
    this.isArchived = false,
    required this.createdAt,
  });

  /// Reads a subject from a database row.
  factory Subject.fromRow(Map<String, Object?> row) => Subject(
        id: intValue(row['id']),
        name: LocalizedText.fromColumns(row['name_ar'], row['name_en']),
        description: LocalizedText.fromColumns(
          row['description_ar'],
          row['description_en'],
        ),
        iconKey: textValue(row['icon_key']),
        colorHex: textValue(row['color_hex']),
        sortOrder: intValue(row['sort_order']),
        isArchived: boolValue(row['is_archived']),
        createdAt: dateTimeValue(row['created_at']),
      );

  final int id;

  /// Bilingual subject name; Arabic is primary.
  final LocalizedText name;

  /// Bilingual one-line description.
  final LocalizedText description;

  /// Semantic icon key, mapped to an icon by the UI layer.
  final String iconKey;

  /// `#RRGGBB` accent colour used by the UI.
  final String colorHex;

  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'name_ar': name.ar,
        'name_en': name.en,
        'description_ar': description.ar,
        'description_en': description.en,
        'icon_key': iconKey,
        'color_hex': colorHex,
        'sort_order': sortOrder,
        'is_archived': boolToInt(isArchived),
        'created_at': dateTimeToMillis(createdAt),
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  Subject copyWith({
    LocalizedText? name,
    LocalizedText? description,
    String? iconKey,
    String? colorHex,
    int? sortOrder,
    bool? isArchived,
  }) =>
      Subject(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        iconKey: iconKey ?? this.iconKey,
        colorHex: colorHex ?? this.colorHex,
        sortOrder: sortOrder ?? this.sortOrder,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt,
      );

  @override
  String toString() => 'Subject($id, ${name.ar})';
}