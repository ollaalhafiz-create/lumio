import 'enums.dart';
import 'row_values.dart';

/// One row of the append-only XP ledger.
///
/// The table has no update or delete path in the data layer: earnings and
/// (rare) corrections are new rows, and the learner's total is always
/// `SUM(xp_events.amount)`. [sourceKey] carries a unique index, so a reward that
/// pays XP can only ever produce one ledger row.
class XpEvent {
  const XpEvent({
    required this.id,
    required this.userId,
    required this.amount,
    required this.reason,
    this.sourceKey,
    this.sourceType,
    this.sourceId,
    required this.createdAt,
    required this.localDate,
  });

  factory XpEvent.fromRow(Map<String, Object?> row) => XpEvent(
        id: intValue(row['id']),
        userId: intValue(row['user_id']),
        amount: intValue(row['amount']),
        reason: XpReason.fromValue(row['reason']),
        sourceKey: textOrNull(row['source_key']),
        sourceType: textOrNull(row['source_type']),
        sourceId: intOrNull(row['source_id']),
        createdAt: dateTimeValue(row['created_at']),
        localDate: textValue(row['local_date']),
      );

  final int id;
  final int userId;

  /// Signed amount; negative rows record corrections.
  final int amount;

  /// Why this row exists.
  final XpReason reason;

  /// Unique idempotency key such as `achievement:3` or `quiz_result:12:perfect`.
  /// `null` for manual adjustments that may repeat.
  final String? sourceKey;

  /// Technical type of the origin row, for debugging and grouping.
  final String? sourceType;

  /// Technical id of the origin row.
  final int? sourceId;

  final DateTime createdAt;

  /// `YYYY-MM-DD` local day, used by daily challenges and goals.
  final String localDate;

  /// `true` when the row increases the total.
  bool get isEarning => amount > 0;

  /// `true` when the row is a correction.
  bool get isCorrection => amount < 0;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'user_id': userId,
        'amount': amount,
        'reason': reason.key,
        'source_key': sourceKey,
        'source_type': sourceType,
        'source_id': sourceId,
        'created_at': dateTimeToMillis(createdAt),
        'local_date': localDate,
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  @override
  String toString() => 'XpEvent($id, $amount XP, ${reason.key})';
}