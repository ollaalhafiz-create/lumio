// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Lumio';

  @override
  String get onboardingTitle1 => 'تعلَّم';

  @override
  String get onboardingBody1 => 'اكتشف دروسك ونظِّمها.';

  @override
  String get onboardingTitle2 => 'الدراسة بالذكاء الاصطناعي';

  @override
  String get onboardingBody2 => 'لخِّص دروسك وأنشئ اختبارات بالذكاء الاصطناعي.';

  @override
  String get onboardingTitle3 => 'تطوَّر';

  @override
  String get onboardingBody3 => 'تابع تقدُّمك وحسِّن تعلُّمك.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navQuizzes => 'الاختبارات';

  @override
  String get navChallenges => 'التحديات';

  @override
  String get navProgress => 'التقدّم';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionSkip => 'تخطي';

  @override
  String get actionStart => 'ابدأ';

  @override
  String get actionContinue => 'متابعة';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionDone => 'تم';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionDelete => 'حذف';

  @override
  String get homeGreeting => 'أهلًا بك';

  @override
  String get homeSubtitle => 'استعد للتعلّم اليوم';

  @override
  String get homeDailyGoal => 'هدف اليوم';

  @override
  String get homeContinueStudying => 'تابع التعلّم';

  @override
  String get homeNoActiveCourse => 'لا يوجد نشاط جارٍ. اختر اختبارًا للبدء.';

  @override
  String get homePoints => 'نقطة';

  @override
  String get homeStreak => 'يوم متتالٍ';

  @override
  String get quizzesTitle => 'الاختبارات';

  @override
  String get quizzesEmpty => 'لا توجد اختبارات متاحة بعد.';

  @override
  String get quizStart => 'ابدأ الاختبار';

  @override
  String quizQuestionOf(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String get quizYourAnswer => 'إجابتك';

  @override
  String get quizCorrectAnswer => 'الإجابة الصحيحة';

  @override
  String get quizCorrect => 'إجابة صحيحة';

  @override
  String get quizIncorrect => 'إجابة خاطئة';

  @override
  String get quizTimeLeft => 'الوقت المتبقي';

  @override
  String get quizResultsTitle => 'نتيجة الاختبار';

  @override
  String get quizScore => 'نتيجتك';

  @override
  String get quizPassed => 'ممتاز، لقد نجحت';

  @override
  String get quizFailed => 'لم تنجح هذه المرة';

  @override
  String get quizTryAgain => 'حاول مرة أخرى';

  @override
  String get quizReviewAnswers => 'مراجعة الإجابات';

  @override
  String get quizExitConfirm => 'هل تريد الخروج من الاختبار؟ سيفقد تقدمك.';

  @override
  String quizPassingScore(int score) {
    return 'درجة النجاح $score%';
  }

  @override
  String get quizDifficultyEasy => 'سهل';

  @override
  String get quizDifficultyMedium => 'متوسط';

  @override
  String get quizDifficultyHard => 'صعب';

  @override
  String get challengesTitle => 'التحديات';

  @override
  String get challengesEmpty => 'لا توجد تحديات متاحة.';

  @override
  String get challengeCompleted => 'مكتمل';

  @override
  String get challengeLocked => 'مقفل';

  @override
  String get challengeProgress => 'التقدم';

  @override
  String get challengeReward => 'المكافأة';

  @override
  String get challengeDaily => 'تحدي اليوم';

  @override
  String get challengeClaim => 'استلم المكافأة';

  @override
  String get challengeClaimed => 'تم الاستلام';

  @override
  String get progressTitle => 'التقدّم';

  @override
  String get progressTotalPoints => 'إجمالي النقاط';

  @override
  String get progressAccuracy => 'نسبة الدقة';

  @override
  String get progressStudyTime => 'وقت المذاكرة';

  @override
  String get progressQuizzesTaken => 'الاختبارات المنجزة';

  @override
  String get progressBestStreak => 'أفضل سلسلة';

  @override
  String get progressLast7Days => 'آخر ٧ أيام';

  @override
  String get progressNoData => 'لا توجد بيانات بعد. ابدأ باختبار أولًا.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'تلقائي';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsDailyReminder => 'تذكير يومي';

  @override
  String get settingsAbout => 'حول التطبيق';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get settingsResetProgress => 'إعادة تعيين التقدّم';

  @override
  String get settingsResetConfirm =>
      'سيتم حذف كل تقدّمك ولا يمكن التراجع. هل أنت متأكد؟';

  @override
  String get settingsData => 'البيانات';

  @override
  String get settingsClearCache => 'مسح ذاكرة التخزين المؤقت';

  @override
  String unitsMinutes(int count) {
    return '$count دقيقة';
  }

  @override
  String unitsHours(int count) {
    return '$count ساعة';
  }

  @override
  String percentValue(num value) {
    return '$value%';
  }

  @override
  String get errorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get errorDatabase => 'تعذّر الوصول إلى البيانات.';

  @override
  String get errorLoading => 'جارٍ التحميل…';

  @override
  String get errorEmptyState => 'لا توجد بيانات لعرضها.';

  @override
  String get errorNoConnection => 'لا يوجد اتصال. تحقق من الشبكة.';

  @override
  String get errorSaveFailed => 'تعذّر الحفظ.';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get searchHint => 'ابحث…';

  @override
  String ofTotal(int current, int total) {
    return '$current / $total';
  }
}
