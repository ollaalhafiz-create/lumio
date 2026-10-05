import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lumio/data/dao/level_dao.dart';
import 'package:lumio/data/dao/reward_dao.dart';
import 'package:lumio/data/dao/user_dao.dart';
import 'package:lumio/data/dao/xp_event_dao.dart';
import 'package:lumio/data/db/database.dart';
import 'package:lumio/data/db/migrations.dart';
import 'package:lumio/data/db/schema.dart';
import 'package:lumio/data/models/enums.dart';
import 'package:lumio/data/models/local_day.dart';
import 'package:lumio/data/models/user_profile.dart';
import 'package:lumio/data/models/xp_event.dart';

import '../helpers/test_database.dart';

/// Counts the rows of [table].
Future<int> _count(DatabaseExecutor executor, String table) async {
  final List<Map<String, Object?>> rows =
      await executor.rawQuery('SELECT COUNT(*) AS c FROM $table');
  final Object? value = rows.first['c'];
  return value is num ? value.toInt() : 0;
}

void main() {
  useSystemSqlite();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lumio_db_test');
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  String dbPath(String name) => '${tempDir.path}/$name';

  Future<AppDatabase> openAt(String name, {int? pinVersion}) =>
      AppDatabase.open(
        factory: testDatabaseFactory,
        path: dbPath(name),
        pinVersion: pinVersion,
      );

  group('schema', () {
    test('a fresh install lands on the current version with every table',
        () async {
      final AppDatabase database = await openAt('fresh.db');
      addTearDown(database.close);

      expect(await database.schemaVersion, Migrations.currentVersion);

      final List<String> tables = await database.tableNames();
      for (final String table in <String>[
        Tables.users,
        Tables.subjects,
        Tables.chapters,
        Tables.lessons,
        Tables.questions,
        Tables.questionOptions,
        Tables.quizzes,
        Tables.quizResults,
        Tables.quizAnswers,
        Tables.flashcards,
        Tables.settings,
        Tables.xpEvents,
        Tables.levels,
        Tables.achievements,
        Tables.challenges,
        Tables.challengeCompletions,
        Tables.rewardClaims,
        Tables.studentProgress,
        Tables.dailyActivity,
        Tables.studySessions,
        Tables.studyGoals,
        Tables.reviewNotes,
      ]) {
        expect(tables, contains(table), reason: 'missing table $table');
      }
    });

    test('foreign keys are enforced so cascades actually fire', () async {
      final AppDatabase database = await openAt('fk.db');
      addTearDown(database.close);

      // `lessons.chapter_id` has no such chapter, so this must be rejected.
      await expectLater(
        database.db.insert(Tables.lessons, <String, Object?>{
          Col.chapterId: 9999,
          Col.titleAr: 'x',
          Col.createdAt: 0,
        }),
        throwsA(isA<Object>()),
      );
    });

    test('upgrading from v1 adds the v2 tables and keeps the seed', () async {
      // A genuine v1 file: only step 1 runs, so the v2 tables really are
      // absent before the upgrade. (`pinVersion` would not do, because a fresh
      // file always goes through `createAll`, which applies every step.)
      final Database v1Handle = await testDatabaseFactory.openDatabase(
        dbPath('upgrade.db'),
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (Database db, int version) => Migrations.upgrade(db, 0, 1),
        ),
      );
      // The factory caches single connections, so the v1 handle has to go
      // before the app can reopen the file and run `onUpgrade`.
      await v1Handle.close();

      final AppDatabase v2 = await openAt('upgrade.db');
      addTearDown(v2.close);

      expect(await v2.schemaVersion, Migrations.currentVersion);
      expect(await v2.hasTable(Tables.studyGoals), isTrue);
      expect(await v2.hasTable(Tables.studySessions), isTrue);
      expect(await v2.hasTable(Tables.reviewNotes), isTrue);
      expect(await _count(v2.db, Tables.subjects), greaterThan(0));
    });

    test('replaying the migrations does not duplicate seed rows', () async {
      final AppDatabase database = await openAt('idempotent.db');
      addTearDown(database.close);

      final int subjects = await _count(database.db, Tables.subjects);
      final int questions = await _count(database.db, Tables.questions);
      final int options = await _count(database.db, Tables.questionOptions);

      await Migrations.createAll(database.db);
      await Migrations.createAll(database.db);

      expect(await _count(database.db, Tables.subjects), subjects);
      expect(await _count(database.db, Tables.questions), questions);
      expect(await _count(database.db, Tables.questionOptions), options);
    });
  });

  group('seed content', () {
    late AppDatabase database;

    setUp(() async {
      database = await openAt('seed.db');
    });

    tearDown(() async {
      await database.close();
    });

    test('the catalogue is populated', () async {
      expect(await _count(database.db, Tables.subjects), 4);
      expect(await _count(database.db, Tables.chapters), 11);
      expect(await _count(database.db, Tables.lessons), 17);
      expect(await _count(database.db, Tables.questions), greaterThanOrEqualTo(10));
      expect(await _count(database.db, Tables.quizzes), 5);
      expect(await _count(database.db, Tables.flashcards), 8);
      expect(await _count(database.db, Tables.achievements), greaterThan(0));
      expect(await _count(database.db, Tables.challenges), greaterThan(0));
      expect(await _count(database.db, Tables.levels), greaterThan(0));
    });

    test('Arabic is present on every seeded row', () async {
      for (final (String table, List<String> columns) in <(String, List<String>)>[
        (Tables.subjects, <String>[Col.nameAr, Col.descriptionAr]),
        (Tables.chapters, <String>[Col.titleAr, Col.summaryAr]),
        (Tables.lessons, <String>[Col.titleAr, Col.bodyAr]),
        (Tables.questions, <String>[Col.promptAr, Col.explanationAr]),
        (Tables.questionOptions, <String>[Col.textAr]),
        (Tables.quizzes, <String>[Col.titleAr, Col.descriptionAr]),
        (Tables.flashcards, <String>[Col.frontAr, Col.backAr]),
      ]) {
        final List<Map<String, Object?>> rows = await database.db.query(table);
        expect(rows, isNotEmpty, reason: '$table was not seeded');
        for (final Map<String, Object?> row in rows) {
          for (final String column in columns) {
            final Object? value = row[column];
            expect(
              value,
              isA<String>().having((String v) => v.trim(), 'trimmed', isNotEmpty),
              reason: '$table.$column must carry Arabic text',
            );
          }
        }
      }
    });

    test('every question has exactly one correct option', () async {
      final List<Map<String, Object?>> questions =
          await database.db.query(Tables.questions, orderBy: '${Col.id} ASC');
      expect(questions, isNotEmpty);

      for (final Map<String, Object?> question in questions) {
        final int id = question[Col.id]! as int;
        final List<Map<String, Object?>> options = await database.db.query(
          Tables.questionOptions,
          where: '${Col.questionId} = ?',
          whereArgs: <Object?>[id],
          orderBy: '${Col.sortOrder} ASC',
        );

        expect(
          options.length,
          greaterThanOrEqualTo(2),
          reason: 'question $id has too few options to be answerable',
        );
        expect(
          options.where((Map<String, Object?> o) => o[Col.isCorrect] == 1).length,
          1,
          reason: 'question $id must have exactly one correct option',
        );

        final Set<Object?> keys = <Object?>{
          for (final Map<String, Object?> o in options) o[Col.optionKey],
        };
        expect(keys.length, options.length,
            reason: 'question $id has duplicate option keys');
      }
    });

    test('option counts match the question count', () async {
      final int questions = await _count(database.db, Tables.questions);
      final List<Map<String, Object?>> rows = await database.db.rawQuery(
        'SELECT ${Col.questionId} AS qid, COUNT(*) AS c '
        'FROM ${Tables.questionOptions} GROUP BY ${Col.questionId}',
      );
      expect(rows.length, questions);
      for (final Map<String, Object?> row in rows) {
        expect(row['c'], isA<int>().having((int c) => c, 'options', greaterThan(1)));
      }
    });

    test('no seeded text carries a replacement character', () async {
      const String replacement = '\uFFFD';
      for (final String table in <String>[
        Tables.subjects,
        Tables.chapters,
        Tables.lessons,
        Tables.questions,
        Tables.questionOptions,
        Tables.quizzes,
        Tables.flashcards,
        Tables.achievements,
        Tables.challenges,
      ]) {
        final List<Map<String, Object?>> rows = await database.db.query(table);
        for (final Map<String, Object?> row in rows) {
          for (final MapEntry<String, Object?> entry in row.entries) {
            if (entry.value is! String) continue;
            expect(
              entry.value,
              isNot(contains(replacement)),
              reason: '$table.${entry.key} contains U+FFFD',
            );
          }
        }
      }
    });
  });

  group('gamification', () {
    late AppDatabase database;
    late int userId;

    setUp(() async {
      database = await openAt('gamification.db');
      userId = await UserDao(database.executor).insert(
        UserProfile(
          id: 0,
          displayNameAr: 'متعلم',
          createdAt: DateTime.now(),
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('the XP ledger totals and can be re-read per day', () async {
      final XpEventDao xp = XpEventDao(database.executor);
      final DateTime now = DateTime.now();

      await xp.append(
        XpEvent(
          id: 0,
          userId: userId,
          amount: 30,
          reason: XpReason.lessonReward,
          createdAt: now,
          localDate: '2026-01-01',
        ),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await xp.append(
        XpEvent(
          id: 0,
          userId: userId,
          amount: 12,
          reason: XpReason.quizReward,
          createdAt: now,
          localDate: '2026-01-02',
        ),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      expect(await xp.totalXp(userId), 42);
      expect(await xp.earnedOn(userId, LocalDay(2026, 1, 1)), 30);
      expect(await xp.countForUser(userId), 2);
    });

    test('a repeated source key cannot add XP twice', () async {
      final XpEventDao xp = XpEventDao(database.executor);
      final DateTime now = DateTime.now();

      Future<int> write() => xp.append(
            XpEvent(
              id: 0,
              userId: userId,
              amount: 50,
              reason: XpReason.goalReward,
              sourceKey: 'goal:daily:2026-01-01',
              createdAt: now,
              localDate: '2026-01-01',
            ),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );

      expect(await write(), greaterThan(0));
      expect(await write(), 0, reason: 'the unique index must reject the row');
      expect(await xp.totalXp(userId), 50);
      expect(await xp.hasSourceKey('goal:daily:2026-01-01'), isTrue);
    });

    test('a reward can only be claimed once per period', () async {
      final RewardDao rewards = RewardDao(database.executor);
      final XpEventDao xp = XpEventDao(database.executor);
      final DateTime claimedAt = DateTime(2026, 1, 1, 10);

      final bool first = await rewards.tryClaim(
        userId: userId,
        type: RewardType.achievement,
        rewardId: 7,
        periodKey: '2026-01-01',
        claimedAt: claimedAt,
        xpAwarded: 25,
      );
      final bool second = await rewards.tryClaim(
        userId: userId,
        type: RewardType.achievement,
        rewardId: 7,
        periodKey: '2026-01-01',
        claimedAt: claimedAt.add(const Duration(seconds: 5)),
        xpAwarded: 25,
      );

      expect(first, isTrue);
      expect(second, isFalse);
      expect(await rewards.isClaimed(
        userId: userId,
        type: RewardType.achievement,
        rewardId: 7,
        periodKey: '2026-01-01',
      ), isTrue);
      expect(await rewards.countClaims(userId), 1);
      expect(await xp.totalXp(userId), 0,
          reason: 'claiming must not invent XP without a ledger row');
    });

    test('the same reward is claimable again in a new period', () async {
      final RewardDao rewards = RewardDao(database.executor);
      final DateTime claimedAt = DateTime(2026, 1, 1, 10);

      expect(
        await rewards.tryClaim(
          userId: userId,
          type: RewardType.challenge,
          rewardId: 3,
          periodKey: '2026-01-01',
          claimedAt: claimedAt,
        ),
        isTrue,
      );
      expect(
        await rewards.tryClaim(
          userId: userId,
          type: RewardType.challenge,
          rewardId: 3,
          periodKey: '2026-01-02',
          claimedAt: claimedAt.add(const Duration(days: 1)),
        ),
        isTrue,
      );
      expect(await rewards.countClaims(userId), 2);
    });

    test('levels are derived from the seeded curve', () async {
      final LevelDao levels = LevelDao(database.executor);
      final List<dynamic> all = await levels.all();
      expect(all, isNotEmpty);

      final int? next = await levels.minXpOfNextLevel(1);
      expect(next, isNotNull);
      expect(next, greaterThan(0));
      expect(await levels.byLevel(9999), isNull);
    });
  });
}
