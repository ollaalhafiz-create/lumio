// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lumio';

  @override
  String get onboardingTitle1 => 'Learn';

  @override
  String get onboardingBody1 => 'Discover and organize your lessons.';

  @override
  String get onboardingTitle2 => 'AI Study';

  @override
  String get onboardingBody2 =>
      'Summarize lessons and generate quizzes using AI.';

  @override
  String get onboardingTitle3 => 'Grow';

  @override
  String get onboardingBody3 =>
      'Track your progress and improve your learning.';

  @override
  String get navHome => 'Home';

  @override
  String get navQuizzes => 'Quizzes';

  @override
  String get navChallenges => 'Challenges';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Back';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionStart => 'Start';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionDone => 'Done';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDelete => 'Delete';

  @override
  String get homeGreeting => 'Welcome back';

  @override
  String get homeSubtitle => 'Ready to learn today';

  @override
  String get homeDailyGoal => 'Goal for today';

  @override
  String get homeContinueStudying => 'Continue studying';

  @override
  String get homeNoActiveCourse =>
      'No activity in progress. Pick a quiz to begin.';

  @override
  String get homePoints => 'pts';

  @override
  String get homeStreak => 'day streak';

  @override
  String get quizzesTitle => 'Quizzes';

  @override
  String get quizzesEmpty => 'No quizzes available yet.';

  @override
  String get quizStart => 'Start quiz';

  @override
  String quizQuestionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quizYourAnswer => 'Your answer';

  @override
  String get quizCorrectAnswer => 'Correct answer';

  @override
  String get quizCorrect => 'Correct';

  @override
  String get quizIncorrect => 'Incorrect';

  @override
  String get quizTimeLeft => 'Time left';

  @override
  String get quizResultsTitle => 'Quiz results';

  @override
  String get quizScore => 'Your score';

  @override
  String get quizPassed => 'Excellent, you passed';

  @override
  String get quizFailed => 'Not this time';

  @override
  String get quizTryAgain => 'Try again';

  @override
  String get quizReviewAnswers => 'Review answers';

  @override
  String get quizExitConfirm => 'Leave the quiz? Your progress will be lost.';

  @override
  String quizPassingScore(int score) {
    return 'Pass mark $score%';
  }

  @override
  String get quizDifficultyEasy => 'Easy';

  @override
  String get quizDifficultyMedium => 'Medium';

  @override
  String get quizDifficultyHard => 'Hard';

  @override
  String get challengesTitle => 'Challenges';

  @override
  String get challengesEmpty => 'No challenges available.';

  @override
  String get challengeCompleted => 'Completed';

  @override
  String get challengeLocked => 'Locked';

  @override
  String get challengeProgress => 'Progress';

  @override
  String get challengeReward => 'Reward';

  @override
  String get challengeDaily => 'Challenge of the day';

  @override
  String get challengeClaim => 'Claim reward';

  @override
  String get challengeClaimed => 'Claimed';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressTotalPoints => 'Total points';

  @override
  String get progressAccuracy => 'Accuracy';

  @override
  String get progressStudyTime => 'Study time';

  @override
  String get progressQuizzesTaken => 'Quizzes taken';

  @override
  String get progressBestStreak => 'Best streak';

  @override
  String get progressLast7Days => 'Last 7 days';

  @override
  String get progressNoData => 'No data yet. Take your first quiz.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDailyReminder => 'Daily reminder';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsResetProgress => 'Reset progress';

  @override
  String get settingsResetConfirm =>
      'All your progress will be deleted and cannot be undone. Are you sure?';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsClearCache => 'Clear cache';

  @override
  String unitsMinutes(int count) {
    return '$count min';
  }

  @override
  String unitsHours(int count) {
    return '$count h';
  }

  @override
  String percentValue(num value) {
    return '$value%';
  }

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorDatabase => 'Could not access your data.';

  @override
  String get errorLoading => 'Loading…';

  @override
  String get errorEmptyState => 'Nothing to show here.';

  @override
  String get errorNoConnection => 'No connection. Check your network.';

  @override
  String get errorSaveFailed => 'Could not save.';

  @override
  String get loading => 'Loading…';

  @override
  String get searchHint => 'Search…';

  @override
  String ofTotal(int current, int total) {
    return '$current / $total';
  }
}
