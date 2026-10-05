import '../db/schema.dart';
import '../models/user_profile.dart';
import 'dao.dart';

/// Reads and writes the local learner profile.
class UserDao extends Dao {
  UserDao(super.executor);

  /// Id of the profile created by the seed migration.
  static const int defaultUserId = 1;

  Future<UserProfile?> byId(int id) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.users,
      where: '${Col.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserProfile.fromRow(rows.first);
  }

  /// The first profile of the device, which is the only one the app uses.
  Future<UserProfile?> first() async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.users,
      orderBy: '${Col.id} ASC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserProfile.fromRow(rows.first);
  }

  Future<int> insert(UserProfile profile) =>
      insertRow(Tables.users, profile.toInsertRow());

  Future<int> update(UserProfile profile) => executor.update(
        Tables.users,
        profile.toRow(),
        where: '${Col.id} = ?',
        whereArgs: <Object?>[profile.id],
      );

  Future<int> count() => countRows(Tables.users);

  /// Deletes every row that belongs to the learner.
  ///
  /// Content (`subjects`, `chapters`, ...) is seeded content and stays; only
  /// the learner's own history is removed.
  Future<void> deleteLearningData(int userId) async {
    for (final String table in <String>[
      Tables.quizAnswers,
      Tables.quizResults,
      Tables.studySessions,
      Tables.challengeCompletions,
      Tables.rewardClaims,
      Tables.studyGoals,
      Tables.studentProgress,
      Tables.dailyActivity,
      Tables.xpEvents,
      Tables.reviewNotes,
      Tables.settings,
    ]) {
      await executor.delete(
        table,
        where: '${Col.userId} = ?',
        whereArgs: <Object?>[userId],
      );
    }
  }
}