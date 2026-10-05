import 'local_day.dart';
import 'row_values.dart';

/// One row per learner per local day.
///
/// This table is what the streak is derived from: a day counts as active when
/// at least one counter is non-zero, and the counters are additive upserts, so
/// the row survives app restarts and can be rebuilt from the XP ledger.
class DailyActivity {
  const DailyActivity({
    required this.id,
    required this.userId,
    required this.localDate,
    this.xpEarned = 0,
    this.questionsAnswered = 0,
    this.questionsCorrect = 0,
    this.quizzesTaken = 0,
    this.lessonsOpened = 0,
    this.flashcardsReviewed = 0,
    this.studySeconds = 0,
    this.goalsCompleted = 0,
    required this.updatedAt,
  });

  factory DailyActivity.fromRow(Map<String, Object?> row) => DailyActivity(
        id: intValue(row['id']),
        userId: intValue(row['user_id']),
        localDate: textValue(row['local_date']),
        xpEarned: intValue(row['xp_earned']),
        questionsAnswered: intValue(row['questions_answered']),
        questionsCorrect: intValue(row['questions_correct']),
        quizzesTaken: intValue(row['quizzes_taken']),
        lessonsOpened: intValue(row['lessons_opened']),
        flashcardsReviewed: intValue(row['flashcards_reviewed']),
        studySeconds: intValue(row['study_seconds']),
        goalsCompleted: intValue(row['goals_completed']),
        updatedAt: dateTimeValue(row['updated_at']),
      );

  final int id;
  final int userId;

  /// `YYYY-MM-DD` day bucket in the device's local time zone.
  final String localDate;

  /// XP earned that day. A materialised convenience aggregate; the learner's
  /// total always comes from `SUM(xp_events.amount)`.
  final int xpEarned;

  final int questionsAnswered;
  final int questionsCorrect;
  final int quizzesTaken;
  final int lessonsOpened;
  final int flashcardsReviewed;
  final int studySeconds;
  final int goalsCompleted;
  final DateTime updatedAt;

  /// The [localDate] key parsed back into a [LocalDay].
  LocalDay? get day => LocalDay.tryParse(localDate);

  /// Accuracy of that day as a fraction between `0` and `1`.
  double get accuracy =>
      questionsAnswered == 0 ? 0 : questionsCorrect / questionsAnswered;

  /// Study time of that day in whole minutes.
  int get studyMinutes => studySeconds ~/ 60;

  /// `true` when something happened that day.
  bool get hasActivity =>
      xpEarned != 0 ||
      questionsAnswered != 0 ||
      quizzesTaken != 0 ||
      lessonsOpened != 0 ||
      flashcardsReviewed != 0 ||
      studySeconds != 0;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'user_id': userId,
        'local_date': localDate,
        'xp_earned': xpEarned,
        'questions_answered': questionsAnswered,
        'questions_correct': questionsCorrect,
        'quizzes_taken': quizzesTaken,
        'lessons_opened': lessonsOpened,
        'flashcards_reviewed': flashcardsReviewed,
        'study_seconds': studySeconds,
        'goals_completed': goalsCompleted,
        'updated_at': dateTimeToMillis(updatedAt),
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  /// The additive part of the row used by the upsert statement.
  ///
  /// Every counter is incremented with `col = col + ?`, so two events on the
  /// same day add up instead of overwriting each other.
  Map<String, Object?> toDeltaRow({
    int xpEarned = 0,
    int questionsAnswered = 0,
    int questionsCorrect = 0,
    int quizzesTaken = 0,
    int lessonsOpened = 0,
    int flashcardsReviewed = 0,
    int studySeconds = 0,
    int goalsCompleted = 0,
  }) =>
      <String, Object?>{
        'xp_earned': xpEarned,
        'questions_answered': questionsAnswered,
        'questions_correct': questionsCorrect,
        'quizzes_taken': quizzesTaken,
        'lessons_opened': lessonsOpened,
        'flashcards_reviewed': flashcardsReviewed,
        'study_seconds': studySeconds,
        'goals_completed': goalsCompleted,
      };

  @override
  String toString() => 'DailyActivity($userId, $localDate)';
}

/// Additive counters for one event on one local day.
///
/// Every recording path (quiz submission, flashcard review, lesson opening,
/// study session, reward claim) describes what it did with one of these, and
/// [DailyActivityDao] turns it into an additive upsert on `daily_activity`.
class ActivityDelta {
  const ActivityDelta({
    this.xpEarned = 0,
    this.questionsAnswered = 0,
    this.questionsCorrect = 0,
    this.quizzesTaken = 0,
    this.lessonsOpened = 0,
    this.flashcardsReviewed = 0,
    this.studySeconds = 0,
    this.goalsCompleted = 0,
  });

  final int xpEarned;
  final int questionsAnswered;
  final int questionsCorrect;
  final int quizzesTaken;
  final int lessonsOpened;
  final int flashcardsReviewed;
  final int studySeconds;
  final int goalsCompleted;

  /// `true` when this delta would not change anything.
  bool get isEmpty =>
      xpEarned == 0 &&
      questionsAnswered == 0 &&
      questionsCorrect == 0 &&
      quizzesTaken == 0 &&
      lessonsOpened == 0 &&
      flashcardsReviewed == 0 &&
      studySeconds == 0 &&
      goalsCompleted == 0;

  /// The delta as a `DailyActivity.toDeltaRow` argument.
  Map<String, Object?> toRow() => DailyActivity(
        id: 0,
        userId: 0,
        localDate: '',
        xpEarned: xpEarned,
        questionsAnswered: questionsAnswered,
        questionsCorrect: questionsCorrect,
        quizzesTaken: quizzesTaken,
        lessonsOpened: lessonsOpened,
        flashcardsReviewed: flashcardsReviewed,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        studySeconds: studySeconds,
        goalsCompleted: goalsCompleted,
      ).toDeltaRow();

  @override
  String toString() => 'ActivityDelta(xp: $xpEarned, questions: $questionsAnswered)';
}

/// A day that has no activity row at all, used by the last-7-days chart.
class DailyActivitySlot {
  const DailyActivitySlot({
    required this.day,
    this.activity,
  });

  /// An empty slot for [day].
  factory DailyActivitySlot.empty(LocalDay day) =>
      DailyActivitySlot(day: day, activity: null);

  final LocalDay day;
  final DailyActivity? activity;

  bool get hasActivity => activity != null;

  int get xpEarned => activity?.xpEarned ?? 0;

  int get questionsAnswered => activity?.questionsAnswered ?? 0;

  int get studyMinutes => activity?.studyMinutes ?? 0;
}