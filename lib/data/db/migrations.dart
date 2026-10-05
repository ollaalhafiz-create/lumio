import 'package:sqflite/sqflite.dart';

import '../models/level.dart';
import 'schema.dart';
import 'seed_data.dart';

/// One entry of the versioned migration list.
final class Migration {
  const Migration({
    required this.version,
    required this.description,
    required this.run,
  });

  /// The schema version this step produces.
  final int version;

  /// Human readable summary, shown in logs and asserted by the tests.
  final String description;

  /// The step body. It receives an open database and its own target version.
  final Future<void> Function(DatabaseExecutor db, int version) run;

  @override
  String toString() => 'Migration(v$version, $description)';
}

/// The ordered, versioned schema history.
///
/// Every step is written so that running it twice is harmless:
/// `CREATE TABLE IF NOT EXISTS`, guarded seeding with `hasTable` /
/// `isEmpty` checks, and `CREATE INDEX IF NOT EXISTS`. A fresh install replays
/// the whole list through [createAll], an upgrade replays only the steps above
/// the version already stored in `PRAGMA user_version` through [upgrade].
abstract final class Migrations {
  /// The schema version this build of the app writes.
  static const int currentVersion = 2;

  /// The full history, oldest first.
  static const List<Migration> steps = <Migration>[
    Migration(
      version: 1,
      description: 'core catalogue, gamification tables and Arabic seed content',
      run: _applyVersion1,
    ),
    Migration(
      version: 2,
      description: 'study sessions, study goals and bilingual review notes',
      run: _applyVersion2,
    ),
  ];

  /// The version numbers that [upgrade] would run when moving from [from] to
  /// [to]. Used by the tests to assert which steps a migration replays.
  static List<int> versionsBetween(int from, int to) => <int>[
        for (final Migration step in steps)
          if (step.version > from && step.version <= to) step.version,
      ];

  /// Replays every step; used as `onCreate` for a brand new database file.
  static Future<void> createAll(DatabaseExecutor db) async {
    for (final Migration step in steps) {
      await _guard(db, step);
    }
  }

  /// Replays the steps between [from] and [to] inclusive; used as `onUpgrade`.
  static Future<void> upgrade(
    DatabaseExecutor db,
    int from,
    int to,
  ) async {
    if (to < from) {
      throw StateError(
        'Refusing to downgrade the database from v$from to v$to.',
      );
    }
    for (final Migration step in steps) {
      if (step.version > from && step.version <= to) {
        await _guard(db, step);
      }
    }
  }

  /// Runs one step, converting an already-applied step into a no-op instead of
  /// crashing the upgrade: the guards inside each step do that, this wrapper
  /// only makes sure a failing step keeps the version untouched.
  static Future<void> _guard(DatabaseExecutor db, Migration step) async {
    if (step.version <= 0) {
      throw ArgumentError('Migration versions start at 1.');
    }
    await step.run(db, step.version);
  }

  /// `true` when [table] already exists.
  static Future<bool> hasTable(DatabaseExecutor db, String table) async {
    final List<Map<String, Object?>> rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>[table],
    );
    return rows.isNotEmpty;
  }

  /// `true` when [column] exists on [table].
  static Future<bool> hasColumn(
    DatabaseExecutor db,
    String table,
    String column,
  ) async {
    if (!await hasTable(db, table)) return false;
    final List<Map<String, Object?>> rows =
        await db.rawQuery('PRAGMA table_info($table)');
    return rows.any(
      (Map<String, Object?> row) => row['name'] == column,
    );
  }

  /// `true` when [table] holds no rows.
  static Future<bool> isEmpty(DatabaseExecutor db, String table) async {
    final List<Map<String, Object?>> rows =
        await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
    final Object? count = rows.first['c'];
    return count is num && count.toInt() == 0;
  }

  // ---------------------------------------------------------------- version 1

  static Future<void> _applyVersion1(DatabaseExecutor db, int version) async {
    await _createCoreTables(db);
    await _createGamificationTables(db);
    await _createProgressTables(db);
    await _seedContent(db);
    await _seedLevels(db);
  }

  static Future<void> _createCoreTables(DatabaseExecutor db) async {
    final Batch batch = db.batch();

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.users} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.displayNameAr} TEXT NOT NULL,
  ${Col.displayNameEn} TEXT,
  ${Col.avatarEmoji} TEXT,
  ${Col.gradeLevelAr} TEXT,
  ${Col.gradeLevelEn} TEXT,
  ${Col.isActive} INTEGER NOT NULL DEFAULT 1,
  ${Col.createdAt} INTEGER NOT NULL,
  ${Col.updatedAt} INTEGER
)''');

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.subjects} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.nameAr} TEXT NOT NULL,
  ${Col.nameEn} TEXT,
  ${Col.descriptionAr} TEXT NOT NULL DEFAULT '',
  ${Col.descriptionEn} TEXT,
  ${Col.iconKey} TEXT NOT NULL DEFAULT 'subject_book',
  ${Col.colorHex} TEXT NOT NULL DEFAULT '#1E88E5',
  ${Col.sortOrder} INTEGER NOT NULL DEFAULT 0,
  ${Col.isArchived} INTEGER NOT NULL DEFAULT 0,
  ${Col.createdAt} INTEGER NOT NULL
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.subjectsSortOrder} '
      'ON ${Tables.subjects} (${Col.sortOrder})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.chapters} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.subjectId} INTEGER NOT NULL,
  ${Col.titleAr} TEXT NOT NULL,
  ${Col.titleEn} TEXT,
  ${Col.summaryAr} TEXT NOT NULL DEFAULT '',
  ${Col.summaryEn} TEXT,
  ${Col.estimatedMinutes} INTEGER NOT NULL DEFAULT 0,
  ${Col.sortOrder} INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (${Col.subjectId}) REFERENCES ${Tables.subjects} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.chaptersSubjectSort} '
      'ON ${Tables.chapters} (${Col.subjectId}, ${Col.sortOrder})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.lessons} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.chapterId} INTEGER NOT NULL,
  ${Col.titleAr} TEXT NOT NULL,
  ${Col.titleEn} TEXT,
  ${Col.bodyAr} TEXT NOT NULL DEFAULT '',
  ${Col.bodyEn} TEXT,
  ${Col.lessonType} TEXT NOT NULL DEFAULT 'reading',
  ${Col.difficulty} INTEGER NOT NULL DEFAULT 1,
  ${Col.durationMinutes} INTEGER NOT NULL DEFAULT 0,
  ${Col.sortOrder} INTEGER NOT NULL DEFAULT 0,
  ${Col.isPublished} INTEGER NOT NULL DEFAULT 1,
  ${Col.createdAt} INTEGER NOT NULL,
  FOREIGN KEY (${Col.chapterId}) REFERENCES ${Tables.chapters} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.lessonsChapterSort} '
      'ON ${Tables.lessons} (${Col.chapterId}, ${Col.sortOrder})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.questions} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.lessonId} INTEGER NOT NULL,
  ${Col.subjectId} INTEGER NOT NULL,
  ${Col.chapterId} INTEGER,
  ${Col.promptAr} TEXT NOT NULL,
  ${Col.promptEn} TEXT,
  ${Col.explanationAr} TEXT NOT NULL DEFAULT '',
  ${Col.explanationEn} TEXT,
  ${Col.questionType} TEXT NOT NULL DEFAULT 'single',
  ${Col.difficulty} INTEGER NOT NULL DEFAULT 1,
  ${Col.points} INTEGER NOT NULL DEFAULT 10,
  ${Col.sortOrder} INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (${Col.lessonId}) REFERENCES ${Tables.lessons} (${Col.id}) ON DELETE CASCADE,
  FOREIGN KEY (${Col.subjectId}) REFERENCES ${Tables.subjects} (${Col.id}) ON DELETE CASCADE,
  FOREIGN KEY (${Col.chapterId}) REFERENCES ${Tables.chapters} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE INDEX IF NOT EXISTS ${Constraints.questionsLesson} '
      'ON ${Tables.questions} (${Col.lessonId}, ${Col.sortOrder})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.questionOptions} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.questionId} INTEGER NOT NULL,
  ${Col.optionKey} TEXT NOT NULL,
  ${Col.textAr} TEXT NOT NULL,
  ${Col.textEn} TEXT,
  ${Col.isCorrect} INTEGER NOT NULL DEFAULT 0,
  ${Col.sortOrder} INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (${Col.questionId}) REFERENCES ${Tables.questions} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.questionOptionsQuestion} '
      'ON ${Tables.questionOptions} (${Col.questionId}, ${Col.optionKey})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.quizzes} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.subjectId} INTEGER NOT NULL,
  ${Col.chapterId} INTEGER,
  ${Col.lessonId} INTEGER,
  ${Col.titleAr} TEXT NOT NULL,
  ${Col.titleEn} TEXT,
  ${Col.descriptionAr} TEXT NOT NULL DEFAULT '',
  ${Col.descriptionEn} TEXT,
  ${Col.passingScore} INTEGER NOT NULL DEFAULT 60,
  ${Col.timeLimitSeconds} INTEGER NOT NULL DEFAULT 0,
  ${Col.difficulty} INTEGER NOT NULL DEFAULT 1,
  ${Col.isRandomOrder} INTEGER NOT NULL DEFAULT 1,
  ${Col.maxAttempts} INTEGER NOT NULL DEFAULT 0,
  ${Col.xpReward} INTEGER NOT NULL DEFAULT 50,
  ${Col.sortOrder} INTEGER NOT NULL DEFAULT 0,
  ${Col.isPublished} INTEGER NOT NULL DEFAULT 1,
  ${Col.createdAt} INTEGER NOT NULL,
  FOREIGN KEY (${Col.subjectId}) REFERENCES ${Tables.subjects} (${Col.id}) ON DELETE CASCADE,
  FOREIGN KEY (${Col.chapterId}) REFERENCES ${Tables.chapters} (${Col.id}) ON DELETE SET NULL,
  FOREIGN KEY (${Col.lessonId}) REFERENCES ${Tables.lessons} (${Col.id}) ON DELETE SET NULL
)''');
    batch.execute(
      'CREATE INDEX IF NOT EXISTS ${Constraints.quizzesLesson} '
      'ON ${Tables.quizzes} (${Col.lessonId})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.quizResults} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.quizId} INTEGER NOT NULL,
  ${Col.userId} INTEGER NOT NULL,
  ${Col.startedAt} INTEGER NOT NULL,
  ${Col.completedAt} INTEGER,
  ${Col.score} INTEGER NOT NULL DEFAULT 0,
  ${Col.maxScore} INTEGER NOT NULL DEFAULT 0,
  ${Col.correctCount} INTEGER NOT NULL DEFAULT 0,
  ${Col.questionCount} INTEGER NOT NULL DEFAULT 0,
  ${Col.durationSeconds} INTEGER NOT NULL DEFAULT 0,
  ${Col.passed} INTEGER NOT NULL DEFAULT 0,
  ${Col.accuracy} REAL NOT NULL DEFAULT 0,
  ${Col.xpAwarded} INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (${Col.quizId}) REFERENCES ${Tables.quizzes} (${Col.id}) ON DELETE CASCADE,
  FOREIGN KEY (${Col.userId}) REFERENCES ${Tables.users} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE INDEX IF NOT EXISTS ${Constraints.quizResultsUser} '
      'ON ${Tables.quizResults} (${Col.userId}, ${Col.completedAt})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.quizAnswers} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.resultId} INTEGER NOT NULL,
  ${Col.questionId} INTEGER NOT NULL,
  ${Col.selectedOptionKeys} TEXT NOT NULL DEFAULT '',
  ${Col.isCorrect} INTEGER NOT NULL DEFAULT 0,
  ${Col.earnedPoints} INTEGER NOT NULL DEFAULT 0,
  ${Col.timeSpentSeconds} INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (${Col.resultId}) REFERENCES ${Tables.quizResults} (${Col.id}) ON DELETE CASCADE,
  FOREIGN KEY (${Col.questionId}) REFERENCES ${Tables.questions} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE INDEX IF NOT EXISTS ${Constraints.quizAnswersResult} '
      'ON ${Tables.quizAnswers} (${Col.resultId})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.flashcards} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.subjectId} INTEGER NOT NULL,
  ${Col.chapterId} INTEGER,
  ${Col.lessonId} INTEGER,
  ${Col.frontAr} TEXT NOT NULL,
  ${Col.frontEn} TEXT,
  ${Col.backAr} TEXT NOT NULL,
  ${Col.backEn} TEXT,
  ${Col.hintAr} TEXT NOT NULL DEFAULT '',
  ${Col.hintEn} TEXT,
  ${Col.difficulty} INTEGER NOT NULL DEFAULT 1,
  ${Col.sortOrder} INTEGER NOT NULL DEFAULT 0,
  ${Col.isArchived} INTEGER NOT NULL DEFAULT 0,
  ${Col.createdAt} INTEGER NOT NULL,
  FOREIGN KEY (${Col.subjectId}) REFERENCES ${Tables.subjects} (${Col.id}) ON DELETE CASCADE,
  FOREIGN KEY (${Col.chapterId}) REFERENCES ${Tables.chapters} (${Col.id}) ON DELETE CASCADE,
  FOREIGN KEY (${Col.lessonId}) REFERENCES ${Tables.lessons} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE INDEX IF NOT EXISTS ${Constraints.flashcardsLesson} '
      'ON ${Tables.flashcards} (${Col.lessonId}, ${Col.sortOrder})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.settings} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.userId} INTEGER NOT NULL,
  ${Col.key} TEXT NOT NULL,
  ${Col.value} TEXT,
  ${Col.valueType} TEXT NOT NULL DEFAULT 'string',
  ${Col.updatedAt} INTEGER NOT NULL,
  FOREIGN KEY (${Col.userId}) REFERENCES ${Tables.users} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.settingsUserKey} '
      'ON ${Tables.settings} (${Col.userId}, ${Col.key})',
    );

    await batch.commit(noResult: true);
  }

  static Future<void> _createGamificationTables(DatabaseExecutor db) async {
    final Batch batch = db.batch();

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.xpEvents} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.userId} INTEGER NOT NULL,
  ${Col.amount} INTEGER NOT NULL,
  ${Col.reason} TEXT NOT NULL,
  ${Col.sourceKey} TEXT,
  ${Col.sourceType} TEXT,
  ${Col.sourceId} INTEGER,
  ${Col.createdAt} INTEGER NOT NULL,
  ${Col.localDate} TEXT NOT NULL,
  FOREIGN KEY (${Col.userId}) REFERENCES ${Tables.users} (${Col.id}) ON DELETE CASCADE
)''');
    // The partial unique index is the second half of the reward guarantee: a
    // reward that pays XP can only ever write one ledger row for its key.
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.xpEventsSourceKey} '
      'ON ${Tables.xpEvents} (${Col.sourceKey}) '
      'WHERE ${Col.sourceKey} IS NOT NULL',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS ${Constraints.xpEventsUserCreated} '
      'ON ${Tables.xpEvents} (${Col.userId}, ${Col.id} DESC)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS ${Constraints.xpEventsUserDate} '
      'ON ${Tables.xpEvents} (${Col.userId}, ${Col.localDate})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.levels} (
  ${Col.level} INTEGER PRIMARY KEY,
  ${Col.titleAr} TEXT NOT NULL,
  ${Col.titleEn} TEXT,
  ${Col.minXp} INTEGER NOT NULL,
  ${Col.iconKey} TEXT NOT NULL DEFAULT 'level_seed'
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.levelsMinXp} '
      'ON ${Tables.levels} (${Col.minXp})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.achievements} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.code} TEXT NOT NULL,
  ${Col.nameAr} TEXT NOT NULL,
  ${Col.nameEn} TEXT,
  ${Col.descriptionAr} TEXT NOT NULL DEFAULT '',
  ${Col.descriptionEn} TEXT,
  ${Col.iconKey} TEXT NOT NULL DEFAULT 'achievement_badge',
  ${Col.metric} TEXT NOT NULL,
  ${Col.threshold} INTEGER NOT NULL,
  ${Col.xpReward} INTEGER NOT NULL DEFAULT 25,
  ${Col.sortOrder} INTEGER NOT NULL DEFAULT 0,
  ${Col.isActive} INTEGER NOT NULL DEFAULT 1
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.achievementsCode} '
      'ON ${Tables.achievements} (${Col.code})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.challenges} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.code} TEXT NOT NULL,
  ${Col.nameAr} TEXT NOT NULL,
  ${Col.nameEn} TEXT,
  ${Col.descriptionAr} TEXT NOT NULL DEFAULT '',
  ${Col.descriptionEn} TEXT,
  ${Col.period} TEXT NOT NULL DEFAULT 'daily',
  ${Col.metric} TEXT NOT NULL,
  ${Col.target} INTEGER NOT NULL,
  ${Col.xpReward} INTEGER NOT NULL DEFAULT 25,
  ${Col.difficulty} INTEGER NOT NULL DEFAULT 1,
  ${Col.subjectId} INTEGER,
  ${Col.iconKey} TEXT NOT NULL DEFAULT 'challenge_flag',
  ${Col.sortOrder} INTEGER NOT NULL DEFAULT 0,
  ${Col.isActive} INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (${Col.subjectId}) REFERENCES ${Tables.subjects} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.challengesCode} '
      'ON ${Tables.challenges} (${Col.code})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.challengeCompletions} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.challengeId} INTEGER NOT NULL,
  ${Col.userId} INTEGER NOT NULL,
  ${Col.periodKey} TEXT NOT NULL,
  ${Col.progress} INTEGER NOT NULL DEFAULT 0,
  ${Col.target} INTEGER NOT NULL,
  ${Col.status} TEXT NOT NULL DEFAULT 'in_progress',
  ${Col.completedAt} INTEGER,
  ${Col.claimedAt} INTEGER,
  ${Col.xpAwarded} INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (${Col.challengeId}) REFERENCES ${Tables.challenges} (${Col.id}) ON DELETE CASCADE,
  FOREIGN KEY (${Col.userId}) REFERENCES ${Tables.users} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.challengeCompletionsPeriod} '
      'ON ${Tables.challengeCompletions} (${Col.challengeId}, ${Col.userId}, ${Col.periodKey})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.rewardClaims} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.userId} INTEGER NOT NULL,
  ${Col.rewardType} TEXT NOT NULL,
  ${Col.rewardId} INTEGER NOT NULL,
  ${Col.periodKey} TEXT NOT NULL DEFAULT '',
  ${Col.claimedAt} INTEGER NOT NULL,
  ${Col.xpAwarded} INTEGER NOT NULL DEFAULT 0,
  ${Col.xpEventId} INTEGER,
  FOREIGN KEY (${Col.userId}) REFERENCES ${Tables.users} (${Col.id}) ON DELETE CASCADE,
  FOREIGN KEY (${Col.xpEventId}) REFERENCES ${Tables.xpEvents} (${Col.id}) ON DELETE SET NULL
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.rewardClaimsReward} '
      'ON ${Tables.rewardClaims} (${Col.userId}, ${Col.rewardType}, ${Col.rewardId}, ${Col.periodKey})',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS ${Constraints.rewardClaimsXpEvent} '
      'ON ${Tables.rewardClaims} (${Col.xpEventId})',
    );

    await batch.commit(noResult: true);
  }

  static Future<void> _createProgressTables(DatabaseExecutor db) async {
    final Batch batch = db.batch();

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.studentProgress} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.userId} INTEGER NOT NULL,
  ${Col.entityType} TEXT NOT NULL,
  ${Col.entityId} INTEGER NOT NULL,
  ${Col.progressPercent} INTEGER NOT NULL DEFAULT 0,
  ${Col.bestScore} INTEGER NOT NULL DEFAULT 0,
  ${Col.attempts} INTEGER NOT NULL DEFAULT 0,
  ${Col.timeSpentSeconds} INTEGER NOT NULL DEFAULT 0,
  ${Col.lastActivityAt} INTEGER,
  ${Col.completedAt} INTEGER,
  FOREIGN KEY (${Col.userId}) REFERENCES ${Tables.users} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.studentProgressEntity} '
      'ON ${Tables.studentProgress} (${Col.userId}, ${Col.entityType}, ${Col.entityId})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.dailyActivity} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.userId} INTEGER NOT NULL,
  ${Col.localDate} TEXT NOT NULL,
  ${Col.xpEarned} INTEGER NOT NULL DEFAULT 0,
  ${Col.questionsAnswered} INTEGER NOT NULL DEFAULT 0,
  ${Col.questionsCorrect} INTEGER NOT NULL DEFAULT 0,
  ${Col.quizzesTaken} INTEGER NOT NULL DEFAULT 0,
  ${Col.lessonsOpened} INTEGER NOT NULL DEFAULT 0,
  ${Col.flashcardsReviewed} INTEGER NOT NULL DEFAULT 0,
  ${Col.studySeconds} INTEGER NOT NULL DEFAULT 0,
  ${Col.goalsCompleted} INTEGER NOT NULL DEFAULT 0,
  ${Col.updatedAt} INTEGER NOT NULL,
  FOREIGN KEY (${Col.userId}) REFERENCES ${Tables.users} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.dailyActivityUserDate} '
      'ON ${Tables.dailyActivity} (${Col.userId}, ${Col.localDate})',
    );

    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------- version 2

  static Future<void> _applyVersion2(DatabaseExecutor db, int version) async {
    final Batch batch = db.batch();

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.studySessions} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.userId} INTEGER NOT NULL,
  ${Col.entityType} TEXT,
  ${Col.entityId} INTEGER,
  ${Col.startedAt} INTEGER NOT NULL,
  ${Col.endedAt} INTEGER,
  ${Col.durationSeconds} INTEGER NOT NULL DEFAULT 0,
  ${Col.localDate} TEXT NOT NULL,
  ${Col.completed} INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (${Col.userId}) REFERENCES ${Tables.users} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE INDEX IF NOT EXISTS ${Constraints.studySessionsUserDate} '
      'ON ${Tables.studySessions} (${Col.userId}, ${Col.localDate})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.studyGoals} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.userId} INTEGER NOT NULL,
  ${Col.period} TEXT NOT NULL DEFAULT 'daily',
  ${Col.targetType} TEXT NOT NULL,
  ${Col.targetValue} INTEGER NOT NULL,
  ${Col.rewardXp} INTEGER NOT NULL DEFAULT 0,
  ${Col.isActive} INTEGER NOT NULL DEFAULT 1,
  ${Col.createdAt} INTEGER NOT NULL,
  FOREIGN KEY (${Col.userId}) REFERENCES ${Tables.users} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ${Constraints.studyGoalsUserPeriod} '
      'ON ${Tables.studyGoals} (${Col.userId}, ${Col.period}, ${Col.targetType})',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS ${Tables.reviewNotes} (
  ${Col.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${Col.userId} INTEGER NOT NULL,
  ${Col.entityType} TEXT NOT NULL,
  ${Col.entityId} INTEGER NOT NULL,
  ${Col.bodyAr} TEXT NOT NULL,
  ${Col.bodyEn} TEXT,
  ${Col.isPinned} INTEGER NOT NULL DEFAULT 0,
  ${Col.createdAt} INTEGER NOT NULL,
  ${Col.updatedAt} INTEGER,
  FOREIGN KEY (${Col.userId}) REFERENCES ${Tables.users} (${Col.id}) ON DELETE CASCADE
)''');
    batch.execute(
      'CREATE INDEX IF NOT EXISTS ${Constraints.reviewNotesEntity} '
      'ON ${Tables.reviewNotes} (${Col.userId}, ${Col.entityType}, ${Col.entityId})',
    );

    await batch.commit(noResult: true);
    await _seedStudyGoals(db);
  }

  // ------------------------------------------------------------------- seeding

  /// Writes the Arabic seed catalogue, but only while the tables are empty.
  static Future<void> _seedContent(DatabaseExecutor db) async {
    if (await isEmpty(db, Tables.subjects)) {
      await SeedContent.insertSubjects(db);
    }
    if (await isEmpty(db, Tables.chapters)) {
      await SeedContent.insertChapters(db);
    }
    if (await isEmpty(db, Tables.lessons)) {
      await SeedContent.insertLessons(db);
    }
    if (await isEmpty(db, Tables.questions)) {
      await SeedContent.insertQuestions(db);
    }
    if (await isEmpty(db, Tables.quizzes)) {
      await SeedContent.insertQuizzes(db);
    }
    if (await isEmpty(db, Tables.flashcards)) {
      await SeedContent.insertFlashcards(db);
    }
    if (await isEmpty(db, Tables.achievements)) {
      await SeedContent.insertAchievements(db);
    }
    if (await isEmpty(db, Tables.challenges)) {
      await SeedContent.insertChallenges(db);
    }
  }

  /// Writes the generated level curve so the table matches [LevelCurve].
  static Future<void> _seedLevels(DatabaseExecutor db) async {
    if (!await hasTable(db, Tables.levels)) return;
    if (!await isEmpty(db, Tables.levels)) return;
    final Batch batch = db.batch();
    for (final LevelDef definition in LevelCurve.definitions) {
      batch.insert(Tables.levels, <String, Object?>{
        Col.level: definition.level,
        Col.titleAr: definition.title.ar,
        Col.titleEn: definition.title.en,
        Col.minXp: definition.minXp,
        Col.iconKey: definition.iconKey,
      });
    }
    await batch.commit(noResult: true);
  }

  /// Writes the default study goals, still in Arabic-first order.
  static Future<void> _seedStudyGoals(DatabaseExecutor db) async {
    if (!await hasTable(db, Tables.studyGoals)) return;
    if (await isEmpty(db, Tables.users)) return;
    final List<Map<String, Object?>> users = await db.query(
      Tables.users,
      columns: <String>[Col.id],
      orderBy: '${Col.id} ASC',
    );
    if (users.isEmpty) return;
    if (!await isEmpty(db, Tables.studyGoals)) return;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final Batch batch = db.batch();
    for (final Map<String, Object?> user in users) {
      for (final Map<String, Object?> goal in SeedContent.studyGoalRows(
        intValueOf(user[Col.id]),
        now,
      )) {
        batch.insert(Tables.studyGoals, goal);
      }
    }
    await batch.commit(noResult: true);
  }

  static int intValueOf(Object? value) => value is num ? value.toInt() : 0;
}