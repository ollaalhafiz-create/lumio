import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Lumio'**
  String get appName;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Learn your way'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Interactive questions designed to help you master any subject with confidence.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Daily challenges'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak alive with short challenges that take only minutes.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'See your points, accuracy and study time in one place.'**
  String get onboardingBody3;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get navQuizzes;

  /// No description provided for @navChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get navChallenges;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get actionStart;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeGreeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to learn today'**
  String get homeSubtitle;

  /// No description provided for @homeDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal for today'**
  String get homeDailyGoal;

  /// No description provided for @homeContinueStudying.
  ///
  /// In en, this message translates to:
  /// **'Continue studying'**
  String get homeContinueStudying;

  /// No description provided for @homeNoActiveCourse.
  ///
  /// In en, this message translates to:
  /// **'No activity in progress. Pick a quiz to begin.'**
  String get homeNoActiveCourse;

  /// No description provided for @homePoints.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get homePoints;

  /// No description provided for @homeStreak.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get homeStreak;

  /// No description provided for @quizzesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzesTitle;

  /// No description provided for @quizzesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No quizzes available yet.'**
  String get quizzesEmpty;

  /// No description provided for @quizStart.
  ///
  /// In en, this message translates to:
  /// **'Start quiz'**
  String get quizStart;

  /// No description provided for @quizQuestionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizQuestionOf(int current, int total);

  /// No description provided for @quizYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get quizYourAnswer;

  /// No description provided for @quizCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get quizCorrectAnswer;

  /// No description provided for @quizCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get quizCorrect;

  /// No description provided for @quizIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get quizIncorrect;

  /// No description provided for @quizTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time left'**
  String get quizTimeLeft;

  /// No description provided for @quizResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz results'**
  String get quizResultsTitle;

  /// No description provided for @quizScore.
  ///
  /// In en, this message translates to:
  /// **'Your score'**
  String get quizScore;

  /// No description provided for @quizPassed.
  ///
  /// In en, this message translates to:
  /// **'Excellent, you passed'**
  String get quizPassed;

  /// No description provided for @quizFailed.
  ///
  /// In en, this message translates to:
  /// **'Not this time'**
  String get quizFailed;

  /// No description provided for @quizTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get quizTryAgain;

  /// No description provided for @quizReviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review answers'**
  String get quizReviewAnswers;

  /// No description provided for @quizExitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave the quiz? Your progress will be lost.'**
  String get quizExitConfirm;

  /// No description provided for @quizPassingScore.
  ///
  /// In en, this message translates to:
  /// **'Pass mark {score}%'**
  String quizPassingScore(int score);

  /// No description provided for @quizDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get quizDifficultyEasy;

  /// No description provided for @quizDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get quizDifficultyMedium;

  /// No description provided for @quizDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get quizDifficultyHard;

  /// No description provided for @challengesTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challengesTitle;

  /// No description provided for @challengesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No challenges available.'**
  String get challengesEmpty;

  /// No description provided for @challengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get challengeCompleted;

  /// No description provided for @challengeLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get challengeLocked;

  /// No description provided for @challengeProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get challengeProgress;

  /// No description provided for @challengeReward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get challengeReward;

  /// No description provided for @challengeDaily.
  ///
  /// In en, this message translates to:
  /// **'Challenge of the day'**
  String get challengeDaily;

  /// No description provided for @challengeClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim reward'**
  String get challengeClaim;

  /// No description provided for @challengeClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get challengeClaimed;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressTotalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total points'**
  String get progressTotalPoints;

  /// No description provided for @progressAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get progressAccuracy;

  /// No description provided for @progressStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Study time'**
  String get progressStudyTime;

  /// No description provided for @progressQuizzesTaken.
  ///
  /// In en, this message translates to:
  /// **'Quizzes taken'**
  String get progressQuizzesTaken;

  /// No description provided for @progressBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get progressBestStreak;

  /// No description provided for @progressLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get progressLast7Days;

  /// No description provided for @progressNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet. Take your first quiz.'**
  String get progressNoData;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get settingsDailyReminder;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsResetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get settingsResetProgress;

  /// No description provided for @settingsResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'All your progress will be deleted and cannot be undone. Are you sure?'**
  String get settingsResetConfirm;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get settingsClearCache;

  /// No description provided for @unitsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String unitsMinutes(int count);

  /// No description provided for @unitsHours.
  ///
  /// In en, this message translates to:
  /// **'{count} h'**
  String unitsHours(int count);

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentValue(num value);

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorDatabase.
  ///
  /// In en, this message translates to:
  /// **'Could not access your data.'**
  String get errorDatabase;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get errorLoading;

  /// No description provided for @errorEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show here.'**
  String get errorEmptyState;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network.'**
  String get errorNoConnection;

  /// No description provided for @errorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save.'**
  String get errorSaveFailed;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get searchHint;

  /// No description provided for @ofTotal.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String ofTotal(int current, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
