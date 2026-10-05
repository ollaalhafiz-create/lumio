import 'package:sqflite/sqflite.dart';

import '../models/enums.dart';
import 'schema.dart';

/// The Arabic-first seed catalogue.
///
/// Every row carries Arabic text as the primary value and an English
/// translation beside it, so the app is fully usable in both languages without
/// a second seed pass. Content is written in Modern Standard Arabic and is
/// factual, so explanations shown after a question are meaningful.
abstract final class SeedContent {
  const SeedContent._();

  // ---------------------------------------------------------------- subjects

  /// Subjects, ordered as they appear on the home screen.
  static const List<SubjectSeed> subjects = <SubjectSeed>[
    SubjectSeed(
      nameAr: 'الرياضيات',
      nameEn: 'Mathematics',
      descriptionAr: 'الأعداد والعمليات والجبر والإحصاء.',
      descriptionEn: 'Numbers, operations, algebra and statistics.',
      iconKey: 'subject_math',
      colorHex: '#1E88E5',
    ),
    SubjectSeed(
      nameAr: 'العلوم',
      nameEn: 'Science',
      descriptionAr: 'الفيزياء والكيمياء والأحياء.',
      descriptionEn: 'Physics, chemistry and biology.',
      iconKey: 'subject_science',
      colorHex: '#43A047',
    ),
    SubjectSeed(
      nameAr: 'اللغة العربية',
      nameEn: 'Arabic Language',
      descriptionAr: 'النحو والصرف والإملاء والقراءة الصحيحة.',
      descriptionEn: 'Grammar, morphology and spelling.',
      iconKey: 'subject_arabic',
      colorHex: '#8E24AA',
    ),
    SubjectSeed(
      nameAr: 'اللغة الإنجليزية',
      nameEn: 'English',
      descriptionAr: 'المفردات والقواعد والنطق.',
      descriptionEn: 'Vocabulary, grammar and pronunciation.',
      iconKey: 'subject_english',
      colorHex: '#FB8C00',
    ),
  ];

  static Future<void> insertSubjects(DatabaseExecutor db) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final Batch batch = db.batch();
    for (int i = 0; i < subjects.length; i++) {
      final SubjectSeed subject = subjects[i];
      batch.insert(Tables.subjects, <String, Object?>{
        Col.nameAr: subject.nameAr,
        Col.nameEn: subject.nameEn,
        Col.descriptionAr: subject.descriptionAr,
        Col.descriptionEn: subject.descriptionEn,
        Col.iconKey: subject.iconKey,
        Col.colorHex: subject.colorHex,
        Col.sortOrder: i,
        Col.isArchived: 0,
        Col.createdAt: now,
      });
    }
    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------- chapters

  /// Chapters, keyed by the 1-based index of their subject in [subjects].
  static Future<void> insertChapters(DatabaseExecutor db) async {
    final List<int> subjectIds = await _subjectIdsInOrder(db);
    _require(subjectIds.length >= subjects.length, 'subjects', subjects.length, subjectIds.length);

    final Batch batch = db.batch();
    for (int s = 0; s < chapters.length; s++) {
      final List<ChapterSeed> forSubject = chapters[s];
      for (int c = 0; c < forSubject.length; c++) {
        final ChapterSeed chapter = forSubject[c];
        batch.insert(Tables.chapters, <String, Object?>{
          Col.subjectId: subjectIds[s],
          Col.titleAr: chapter.titleAr,
          Col.titleEn: chapter.titleEn,
          Col.summaryAr: chapter.summaryAr,
          Col.summaryEn: chapter.summaryEn,
          Col.estimatedMinutes: chapter.estimatedMinutes,
          Col.sortOrder: c,
        });
      }
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertLessons(DatabaseExecutor db) async {
    final List<int> chapterIds = await _chapterIdsInOrder(db);
    final List<List<LessonSeed>> flattened = lessons;
    // Each group of [lessons] belongs to one chapter, so the catalogue needs at
    // least one chapter per group. Comparing against the flattened lesson count
    // here would reject the seed, because chapters and lessons are not 1:1.
    if (chapterIds.length < flattened.length) {
      throw StateError(
        'Cannot seed lessons: ${flattened.length} chapter groups need a chapter '
        'each, but only ${chapterIds.length} exist.',
      );
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final Batch batch = db.batch();
    // One group of [lessons] per chapter, so the cursor walks the chapter list
    // once per group and not once per lesson.
    int chapterCursor = 0;
    for (final List<LessonSeed> forChapter in flattened) {
      final int chapterId = chapterIds[chapterCursor++];
      for (int l = 0; l < forChapter.length; l++) {
        final LessonSeed lesson = forChapter[l];
        batch.insert(Tables.lessons, <String, Object?>{
          Col.chapterId: chapterId,
          Col.titleAr: lesson.titleAr,
          Col.titleEn: lesson.titleEn,
          Col.bodyAr: lesson.bodyAr,
          Col.bodyEn: lesson.bodyEn,
          Col.lessonType: lesson.lessonType.key,
          Col.difficulty: lesson.difficulty,
          Col.durationMinutes: lesson.durationMinutes,
          Col.sortOrder: l,
          Col.isPublished: 1,
          Col.createdAt: now,
        });
      }
    }
    await batch.commit(noResult: true);
  }

  // --------------------------------------------------------------- questions

  static Future<void> insertQuestions(DatabaseExecutor db) async {
    final List<int> subjectIds = await _subjectIdsInOrder(db);
    final List<int> lessonIds = await _lessonIdsInOrder(db);
    final List<int> chapterIds = await _chapterIdsInOrder(db);
    if (questions.isEmpty) return;
    _require(subjectIds.length >= subjects.length, 'subjects', subjects.length, subjectIds.length);
    _require(
      questions.every((QuestionSeed q) => q.lesson < lessonIds.length),
      'lessons for questions',
      questions.length,
      lessonIds.length,
    );
    _require(
      questions.every(
        (QuestionSeed q) => q.chapter == null || q.chapter! < chapterIds.length,
      ),
      'chapters for questions',
      questions.length,
      chapterIds.length,
    );

    final Batch batch = db.batch();
    for (final QuestionSeed seed in questions) {
      batch.insert(Tables.questions, <String, Object?>{
        Col.lessonId: lessonIds[seed.lesson],
        Col.subjectId: subjectIds[seed.subject],
        Col.chapterId: seed.chapter == null ? null : chapterIds[seed.chapter!],
        Col.promptAr: seed.promptAr,
        Col.promptEn: seed.promptEn,
        Col.explanationAr: seed.explanationAr,
        Col.explanationEn: seed.explanationEn,
        Col.questionType: seed.type.key,
        Col.difficulty: seed.difficulty,
        Col.points: seed.points,
        Col.sortOrder: seed.order,
      });
    }
    await batch.commit(noResult: true);
    await _insertQuestionOptions(db);
  }

  /// Writes the answer options of every seeded question.
  ///
  /// The options are inserted after the questions, so their ids are read back
  /// in insertion order: the table is guaranteed to be empty before this runs
  /// (see `Migrations._seedContent`), which keeps the mapping from a
  /// [QuestionSeed] to its row id one to one.
  static Future<void> _insertQuestionOptions(DatabaseExecutor db) async {
    final List<Map<String, Object?>> rows = await db.query(
      Tables.questions,
      columns: <String>[Col.id],
      orderBy: '${Col.id} ASC',
    );
    if (rows.length != questions.length) {
      throw StateError(
        'Expected ${questions.length} seeded questions but found ${rows.length}.',
      );
    }

    final Batch batch = db.batch();
    for (int i = 0; i < questions.length; i++) {
      final QuestionSeed seed = questions[i];
      final Object? rawId = rows[i][Col.id];
      final int questionId = rawId is int ? rawId : 0;

      batch.insert(Tables.questionOptions, <String, Object?>{
        Col.questionId: questionId,
        Col.optionKey: seed.correctKey,
        Col.textAr: seed.correctAr,
        Col.textEn: seed.correctEn,
        Col.isCorrect: 1,
        Col.sortOrder: 0,
      });

      for (int w = 0; w < seed.wrongKeys.length; w++) {
        batch.insert(Tables.questionOptions, <String, Object?>{
          Col.questionId: questionId,
          Col.optionKey: seed.wrongKeys[w],
          Col.textAr: seed.wrongAr[w],
          Col.textEn: seed.wrongEn[w],
          Col.isCorrect: 0,
          Col.sortOrder: w + 1,
        });
      }
    }
    await batch.commit(noResult: true);
  }

  // ----------------------------------------------------------------- quizzes

  static Future<void> insertQuizzes(DatabaseExecutor db) async {
    final List<int> subjectIds = await _subjectIdsInOrder(db);
    final List<int> chapterIds = await _chapterIdsInOrder(db);
    final List<int> lessonIds = await _lessonIdsInOrder(db);
    if (quizzes.isEmpty) return;
    _require(subjectIds.length >= subjects.length, 'subjects', subjects.length, subjectIds.length);
    _require(
      quizzes.every((QuizSeed q) => q.chapter == null || q.chapter! < chapterIds.length),
      'chapters for quizzes',
      quizzes.length,
      chapterIds.length,
    );
    _require(
      quizzes.every((QuizSeed q) => q.lesson == null || q.lesson! < lessonIds.length),
      'lessons for quizzes',
      quizzes.length,
      lessonIds.length,
    );

    final int now = DateTime.now().millisecondsSinceEpoch;
    final Batch batch = db.batch();
    for (int i = 0; i < quizzes.length; i++) {
      final QuizSeed quiz = quizzes[i];
      batch.insert(Tables.quizzes, <String, Object?>{
        Col.subjectId: subjectIds[quiz.subject],
        Col.chapterId:
            quiz.chapter == null ? null : chapterIds[quiz.chapter!],
        Col.lessonId: quiz.lesson == null ? null : lessonIds[quiz.lesson!],
        Col.titleAr: quiz.titleAr,
        Col.titleEn: quiz.titleEn,
        Col.descriptionAr: quiz.descriptionAr,
        Col.descriptionEn: quiz.descriptionEn,
        Col.passingScore: quiz.passingScore,
        Col.timeLimitSeconds: quiz.timeLimitSeconds,
        Col.difficulty: quiz.difficulty,
        Col.isRandomOrder: quiz.isRandomOrder ? 1 : 0,
        Col.maxAttempts: quiz.maxAttempts,
        Col.xpReward: quiz.xpReward,
        Col.sortOrder: i,
        Col.isPublished: 1,
        Col.createdAt: now,
      });
    }
    await batch.commit(noResult: true);
  }

  // -------------------------------------------------------------- flashcards

  static Future<void> insertFlashcards(DatabaseExecutor db) async {
    final List<int> subjectIds = await _subjectIdsInOrder(db);
    final List<int> chapterIds = await _chapterIdsInOrder(db);
    final List<int> lessonIds = await _lessonIdsInOrder(db);
    if (flashcards.isEmpty) return;
    _require(subjectIds.length >= subjects.length, 'subjects', subjects.length, subjectIds.length);
    _require(
      flashcards.every(
        (FlashcardSeed c) => c.chapter == null || c.chapter! < chapterIds.length,
      ),
      'chapters for flashcards',
      flashcards.length,
      chapterIds.length,
    );
    _require(
      flashcards.every(
        (FlashcardSeed c) => c.lesson == null || c.lesson! < lessonIds.length,
      ),
      'lessons for flashcards',
      flashcards.length,
      lessonIds.length,
    );

    final int now = DateTime.now().millisecondsSinceEpoch;
    final Batch batch = db.batch();
    for (int i = 0; i < flashcards.length; i++) {
      final FlashcardSeed card = flashcards[i];
      batch.insert(Tables.flashcards, <String, Object?>{
        Col.subjectId: subjectIds[card.subject],
        Col.chapterId: card.chapter == null ? null : chapterIds[card.chapter!],
        Col.lessonId: card.lesson == null ? null : lessonIds[card.lesson!],
        Col.frontAr: card.frontAr,
        Col.frontEn: card.frontEn,
        Col.backAr: card.backAr,
        Col.backEn: card.backEn,
        Col.hintAr: card.hintAr,
        Col.difficulty: card.difficulty,
        Col.sortOrder: i,
        Col.isArchived: 0,
        Col.createdAt: now,
      });
    }
    await batch.commit(noResult: true);
  }

  // ----------------------------------------------------------- gamification

  static Future<void> insertAchievements(DatabaseExecutor db) async {
    final Batch batch = db.batch();
    for (int i = 0; i < achievements.length; i++) {
      final AchievementSeed seed = achievements[i];
      batch.insert(Tables.achievements, <String, Object?>{
        Col.code: seed.code,
        Col.nameAr: seed.nameAr,
        Col.nameEn: seed.nameEn,
        Col.descriptionAr: seed.descriptionAr,
        Col.descriptionEn: seed.descriptionEn,
        Col.iconKey: seed.iconKey,
        Col.metric: seed.metric.name,
        Col.threshold: seed.threshold,
        Col.xpReward: seed.xpReward,
        Col.sortOrder: i,
        Col.isActive: 1,
      });
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertChallenges(DatabaseExecutor db) async {
    final List<int> subjectIds = await _subjectIdsInOrder(db);
    final Batch batch = db.batch();
    for (int i = 0; i < challenges.length; i++) {
      final ChallengeSeed seed = challenges[i];
      batch.insert(Tables.challenges, <String, Object?>{
        Col.code: seed.code,
        Col.nameAr: seed.nameAr,
        Col.nameEn: seed.nameEn,
        Col.descriptionAr: seed.descriptionAr,
        Col.descriptionEn: seed.descriptionEn,
        Col.period: seed.period.name,
        Col.metric: seed.metric.name,
        Col.target: seed.target,
        Col.xpReward: seed.xpReward,
        Col.difficulty: seed.difficulty,
        Col.subjectId:
            seed.subject == null ? null : subjectIds[seed.subject!],
        Col.iconKey: seed.iconKey,
        Col.sortOrder: i,
        Col.isActive: 1,
      });
    }
    await batch.commit(noResult: true);
  }

  /// Default daily and weekly goals written for a freshly created learner.
  static List<Map<String, Object?>> studyGoalRows(int userId, int now) =>
      <Map<String, Object?>>[
        for (final GoalSeed goal in studyGoals)
          <String, Object?>{
            Col.userId: userId,
            Col.period: goal.period,
            Col.targetType: goal.targetType.key,
            Col.targetValue: goal.targetValue,
            Col.rewardXp: goal.rewardXp,
            Col.isActive: 1,
            Col.createdAt: now,
          },
      ];


  // ---------------------------------------------------------------- chapters

  /// Chapters grouped per subject, in the same order as [subjects].
  static const List<List<ChapterSeed>> chapters = <List<ChapterSeed>>[
    // الرياضيات
    <ChapterSeed>[
      ChapterSeed(
        titleAr: 'الكسور والنسب',
        titleEn: 'Fractions and ratios',
        summaryAr: 'عمليات الكسور والنسبة والتناسب.',
        summaryEn: 'Fraction operations, ratios and proportion.',
        estimatedMinutes: 25,
      ),
      ChapterSeed(
        titleAr: 'الجبر',
        titleEn: 'Algebra',
        summaryAr: 'المعادلات والمتراجحات والمقادير الجبرية.',
        summaryEn: 'Equations, inequalities and expressions.',
        estimatedMinutes: 30,
      ),
      ChapterSeed(
        titleAr: 'الهندسة',
        titleEn: 'Geometry',
        summaryAr: 'المساحات والمحيطات والزوايا.',
        summaryEn: 'Areas, perimeters and angles.',
        estimatedMinutes: 20,
      ),
    ],
    // العلوم
    <ChapterSeed>[
      ChapterSeed(
        titleAr: 'الحركة والقوى',
        titleEn: 'Motion and forces',
        summaryAr: 'قوانين نيوتن وقوى الحركة.',
        summaryEn: "Newton's laws and forces.",
        estimatedMinutes: 30,
      ),
      ChapterSeed(
        titleAr: 'المادة والطاقة',
        titleEn: 'Matter and energy',
        summaryAr: 'العناصر والروابط الكيميائية.',
        summaryEn: 'Elements and chemical bonds.',
        estimatedMinutes: 25,
      ),
      ChapterSeed(
        titleAr: 'علوم الحياة',
        titleEn: 'Life sciences',
        summaryAr: 'الخلية والوراثة والتصنيف.',
        summaryEn: 'Cells, genetics and classification.',
        estimatedMinutes: 25,
      ),
    ],
    // اللغة العربية
    <ChapterSeed>[
      ChapterSeed(
        titleAr: 'النحو: الجملة',
        titleEn: 'Grammar: the sentence',
        summaryAr: 'أقسام الكلام والجملة الاسمية والفعلية.',
        summaryEn: 'Parts of speech and sentence types.',
        estimatedMinutes: 20,
      ),
      ChapterSeed(
        titleAr: 'النحو: الصرف',
        titleEn: 'Grammar: morphology',
        summaryAr: 'أنواع الاسم وفاعل ونائب فاعل.',
        summaryEn: 'Nouns and their roles.',
        estimatedMinutes: 25,
      ),
      ChapterSeed(
        titleAr: 'الإملاء',
        titleEn: 'Spelling',
        summaryAr: 'علامات الإملاء والهمزات.',
        summaryEn: 'Spelling marks and hamza.',
        estimatedMinutes: 20,
      ),
    ],
    // اللغة الإنجليزية
    <ChapterSeed>[
      ChapterSeed(
        titleAr: 'الأزمنة',
        titleEn: 'Tenses',
        summaryAr: 'Present simple and past simple.',
        summaryEn: 'Present simple and past simple.',
        estimatedMinutes: 20,
      ),
      ChapterSeed(
        titleAr: 'الأسماء المعدودة',
        titleEn: 'Countable nouns',
        summaryAr: 'المفرد والجمع وصيغة الـ s.',
        summaryEn: 'Singular, plural and the -s form.',
        estimatedMinutes: 15,
      ),
    ],
  ];

  // ----------------------------------------------------------------- lessons

  /// Lessons grouped per chapter, flattened in the same order as [chapters].
  static const List<List<LessonSeed>> lessons = <List<LessonSeed>>[
    <LessonSeed>[
      LessonSeed(
        titleAr: 'جمع الكسور وتكافؤها',
        titleEn: 'Adding fractions and equivalence',
        bodyAr: 'عند جمع الكسور ذات المقام نفسه نجمع البسوط ونبقي المقام كما هو. '
            'مثال: ٣/٤ + ١/٤ = ٤/٤ = ١. أمّا إذا اختلف المقام فيجب أولًا توحيد المقامات '
            'بتصغيرها إلى أبسط صورة.',
        bodyEn: 'To add fractions with the same denominator, add the numerators '
            'and keep the denominator. To combine different denominators, '
            'convert them to a common denominator first.',
        durationMinutes: 12,
      ),
      LessonSeed(
        titleAr: 'النسبة والتناسب',
        titleEn: 'Ratio and proportion',
        bodyAr: 'النسبة مقارنة بين كميتين بالقسمة. مثال: ٣ إلى ٢ تعني ٣/٢. '
            'والتناسب هو تساوي نسبتين، ويُحل بالتربيع وسنستخدمه كثيرًا في مسائل السعة والسرعة.',
        bodyEn: 'A ratio compares two quantities by division. A proportion states '
            'that two ratios are equal, and is solved by cross multiplication.',
        durationMinutes: 13,
        lessonType: LessonType.practice,
        difficulty: 2,
      ),
    ],
    <LessonSeed>[
      LessonSeed(
        titleAr: 'حل المعادلات الخطية',
        titleEn: 'Solving linear equations',
        bodyAr: 'المعادلة الخطية مجهول واحد أُسّه واحد. نحلها بجمع ما على الطرفين '
            'وطرح ما على الطرفين، أو بضرب الطرفين في عدد أو القسمة عليه. '
            'مثال: ٢س + ٣ = ١١ تنقص ٣ فيصير ٢س = ٨، ومن ثم س = ٤.',
        bodyEn: 'A linear equation has one unknown to the first power. Add or '
            'subtract the same amount on both sides, then divide.',
        durationMinutes: 15,
        difficulty: 2,
      ),
      LessonSeed(
        titleAr: 'المتراجحات',
        titleEn: 'Inequalities',
        bodyAr: 'المتراجحة تشبه المعادلة لكن العلاقة هي < أو > أو ≤ أو ≥. '
            'انتبه: عند الضرب في عدد سالب تنعكس العلاقة.',
        bodyEn: 'Inequalities behave like equations but use <, >, <= or >=. '
            'Multiplying by a negative number reverses the sign.',
        durationMinutes: 15,
        difficulty: 3,
        lessonType: LessonType.practice,
      ),
    ],
    <LessonSeed>[
      LessonSeed(
        titleAr: 'مساحة المستطيل والمثلث',
        titleEn: 'Area of rectangles and triangles',
        bodyAr: 'مساحة المستطيل = الطول × العرض. ومساحة المثلث = (القاعدة × الارتفاع) ÷ ٢. '
            'أما محيط المربع فيكون مجموع أضلاعه الأربعة.',
        bodyEn: 'Rectangle area = length x width. Triangle area = (base x height) / 2.',
        durationMinutes: 10,
      ),
    ],
    <LessonSeed>[
      LessonSeed(
        titleAr: 'قوانين نيوتن الثلاثة',
        titleEn: "Newton's three laws",
        bodyAr: 'قانون نيوتن الأول: يبقى الجسم ساكنًا أو متحركًا بسرعة ثابتة '
            'في خط مستقيم ما لم تؤثر عليه قوة خارجية. '
            'الثاني: تسارع الجسم يتناسب مع القوة المؤثرة وعكسًا مع كتلته. '
            'الثالث: لكل فعل رد فعل متساوية وعكسية.',
        bodyEn: 'First law: an object stays at rest or in uniform motion unless '
            'acted on by an external force. Second: acceleration is '
            'proportional to force and inversely proportional to mass. '
            'Third: every action has an equal and opposite reaction.',
        durationMinutes: 18,
        difficulty: 2,
      ),
      LessonSeed(
        titleAr: 'السرعة والتسارع',
        titleEn: 'Speed and acceleration',
        bodyAr: 'السرعة = المسافة ÷ الزمن. والتسارع = تغيّر السرعة ÷ الزمن. '
            'ووحداتها في النظام الدولي هي متر لكل ثانية، ومتر لكل ثانية مربعة.',
        bodyEn: 'Speed = distance / time. Acceleration = change in speed / time.',
        durationMinutes: 12,
      ),
    ],
    <LessonSeed>[
      LessonSeed(
        titleAr: 'الجدول الدوري',
        titleEn: 'The periodic table',
        bodyAr: 'ينظّم الجدول الدوري العناصر حسب العدد الذري. وتُصنّف العناصر '
            'ينتمي بعض العناصر إلى معادن فلزية، وبعضها فلزيات، وأشباه فلزات. '
            'تكوّن الفلزات في العمود الواحد عائلة لها خواص متشابهة.',
        bodyEn: 'The periodic table arranges elements by atomic number and '
            'groups them into metals, nonmetals and metalloids.',
        durationMinutes: 14,
      ),
      LessonSeed(
        titleAr: 'الروابط الكيميائية',
        titleEn: 'Chemical bonds',
        bodyAr: 'الروابط الأيونية تنشأ بين ذرات تفقد وتكتسب إلكترونات، '
            'بينما الروابط التساهمية تنشأ ب 공유 زوج من الإلكترونات.',
        bodyEn: 'Ionic bonds form by electron transfer; covalent bonds form by '
            'sharing an electron pair.',
        durationMinutes: 11,
        difficulty: 2,
      ),
    ],
    <LessonSeed>[
      LessonSeed(
        titleAr: 'الخلية الحية',
        titleEn: 'The living cell',
        bodyAr: 'الخلية الوحدة الأساسية للحياة. تتكون من غشاء خلوي، وسيتوبلازم، '
            'ونواة تحوي المادة الوراثية. والخلية النباتية تحتوي دائمًا على جدار '
            'خلوي وفجوات كبيرة، بخلاف الخلية الحيوانية.',
        bodyEn: 'The cell is the basic unit of life: a membrane, cytoplasm and a '
            'nucleus. Plant cells additionally have a cell wall and large vacuoles.',
        durationMinutes: 13,
      ),
    ],
    <LessonSeed>[
      LessonSeed(
        titleAr: 'أقسام الكلام والجملة الاسمية',
        titleEn: 'Parts of speech and the nominal sentence',
        bodyAr: 'الكلام ينقسم إلى: اسم، وفعل، وحرف. والجملة الاسمية تبدأ باسم '
            'وتنتهي باسم، مثل: «الطالبُ مجتهدٌ»، ومبتدؤها الاسم الأول وخبرها الثاني.',
        bodyEn: 'Speech divides into noun, verb and particle. A nominal sentence '
            'begins and ends with a noun, e.g. "the diligent student".',
        durationMinutes: 12,
      ),
      LessonSeed(
        titleAr: 'الجملة الفعلية',
        titleEn: 'The verbal sentence',
        bodyAr: 'الجملة الفعلية تبدأ بفعل. وقد تتكون من فعل وفاعل فقط، '
            'مثل: «سافَرَ الولدُ»، وقد يزيد عليها مفعول به أو جملة عاطفة.',
        bodyEn: 'A verbal sentence begins with a verb and may include a subject, '
            'an object or a predicate.',
        durationMinutes: 10,
      ),
    ],
    <LessonSeed>[
      LessonSeed(
        titleAr: 'أنواع الاسم',
        titleEn: 'Types of noun',
        bodyAr: 'الاسم يطلق على كل شيء له وجود حقيقي أو معنوي. '
            'ينقسم إلى: علم، وشائع، ومذكر ومؤنث، ومفرد وجمع، وجمع تكسير، '
            'واسم جامد واسم مشتق.',
        bodyEn: 'A noun names a real or abstract thing. It can be a proper noun, '
            'a common noun, masculine or feminine, singular or plural.',
        durationMinutes: 12,
      ),
    ],
    <LessonSeed>[
      LessonSeed(
        titleAr: 'الهمزة وطرق كتابتها',
        titleEn: 'The hamza',
        bodyAr: 'الهمزة نوعان: همزة قطع ووصل، وهمزة قطع تُكتب على الأكثر نقلة '
            'وقطعًا. وتُكتب همزة الوصل في: إن، أن، إذا، إذ، إلا، أل، والاستفهام: '
            'أ، إ، آ، أي.',
        bodyEn: 'The hamza is either cut or connected. The connected hamza appears '
            'in إن، أن، إذا، إذ، إلا، أل and the question words أ، إ، آ.',
        durationMinutes: 11,
      ),
    ],
    <LessonSeed>[
      LessonSeed(
        titleAr: 'Present simple tense',
        titleEn: 'Present simple tense',
        bodyAr: 'نستخدم المضارع البسيط للعادة والحقائق العامة. '
            'مع الغائب المفرد نضيف s إلى الفعل، مثل he و she. '
            'مثال: He studies Arabic.',
        bodyEn: 'Use the present simple for habits and facts. Add -s to the verb '
            'with he, she and it.',
        durationMinutes: 10,
      ),
      LessonSeed(
        titleAr: 'Past simple tense',
        titleEn: 'Past simple tense',
        bodyAr: 'نستخدم الماضي البسيط للأحداث المنتهية في الماضي البعيد. '
            'الأفعال الشاذة مثل go / went، و have / had.',
        bodyEn: 'Use the past simple for finished past events. Watch irregular '
            'verbs: go / went, have / had.',
        durationMinutes: 10,
        lessonType: LessonType.practice,
      ),
    ],
    <LessonSeed>[
      LessonSeed(
        titleAr: 'صيغة الجمع',
        titleEn: 'Plural forms',
        bodyAr: 'تُضاف s إلى معظم الأسماء المفرد. وتُضاف es إلى الأسماء '
            'المنتهية بـ s أو sh أو ch أو x أو o (فحص heroes).',
        bodyEn: 'Add -s to most singular nouns, and -es after s, sh, ch, x or o.',
        durationMinutes: 8,
      ),
    ],
  ];

  // --------------------------------------------------------------- questions

  /// Multiple-choice questions. Each carries an Arabic explanation that the
  /// quiz screen shows straight after the learner answers.
  static const List<QuestionSeed> questions = <QuestionSeed>[
    QuestionSeed(
      subject: 0,
      chapter: 0,
      lesson: 0,
      order: 0,
      promptAr: 'ما ناتج جمع الكسرين ٣/٤ + ١/٤ ؟',
      promptEn: 'What is 3/4 + 1/4?',
      correctKey: 'A',
      correctAr: '١',
      correctEn: '1',
      wrongKeys: <String>['B', 'C', 'D'],
      wrongAr: <String>['٣/٨', '١/٢', '٢/٤'],
      wrongEn: <String>['3/8', '1/2', '2/4'],
      explanationAr: 'المقامات متشابهة، لذلك نجمع البسوط: ٣ + ١ = ٤، فيكون الناتج ٤/٤ وهي تساوي ١.',
      explanationEn: 'The denominators match, so add the numerators: 3 + 1 = 4, '
          'giving 4/4 which equals 1.',
    ),
    QuestionSeed(
      subject: 0,
      chapter: 0,
      lesson: 1,
      order: 1,
      promptAr: 'إذا كانت النسبة ٣ إلى ٢ فإن ٦ إلى ؟',
      promptEn: 'If the ratio is 3 to 2, then 6 is to what?',
      correctKey: 'B',
      correctAr: '٤',
      correctEn: '4',
      wrongKeys: <String>['A', 'C', 'D'],
      wrongAr: <String>['٢', '٣', '٦'],
      wrongEn: <String>['2', '3', '6'],
      explanationAr: 'نضرب ٣ في ٢ لتصبح ٦، ونضرب ٢ في العدد نفسه لتصبح ٤. '
          'إذن النسبة ٦ إلى ٤ تكافئ ٣ إلى ٢.',
      explanationEn: 'Double both parts of 3:2 to get 6:4, which is the same ratio.',
    ),
    QuestionSeed(
      subject: 0,
      chapter: 1,
      lesson: 2,
      order: 2,
      promptAr: 'حل المعادلة: ٢س + ٣ = ١١',
      promptEn: 'Solve: 2x + 3 = 11',
      correctKey: 'C',
      correctAr: 'س = ٤',
      correctEn: 'x = 4',
      wrongKeys: <String>['A', 'B', 'D'],
      wrongAr: <String>['س = ٣', 'س = ٥', 'س = ٧'],
      wrongEn: <String>['x = 3', 'x = 5', 'x = 7'],
      explanationAr: 'نطرح ٣ من الطرفين: ٢س = ٨، ثم نقسم الطرفين على ٢ لتصبح س = ٤.',
      explanationEn: 'Subtract 3 from both sides to get 2x = 8, then divide by 2 to get x = 4.',
      difficulty: 2,
      points: 15,
    ),
    QuestionSeed(
      subject: 1,
      chapter: 3,
      lesson: 5,
      order: 3,
      promptAr: 'بحسب قانون نيوتن الثاني، يتناسب تسارع الجسم مع:',
      promptEn: "By Newton's second law, acceleration is proportional to:",
      correctKey: 'A',
      correctAr: 'القوة المؤثرة',
      correctEn: 'the applied force',
      wrongKeys: <String>['B', 'C', 'D'],
      wrongAr: <String>['كتلة الجسم', 'سرعة الجسم', 'اتجاه الحركة'],
      wrongEn: <String>['the mass', 'the velocity', 'the direction of motion'],
      explanationAr: 'القانون الثاني ينص على أن التسارع يتناسب طرديًا مع القوة '
          'المؤثرة وعكسيًا مع الكتلة: ق = ك × ت.',
      explanationEn: 'The second law states acceleration is directly proportional '
          'to force and inversely proportional to mass (F = ma).',
      difficulty: 2,
      points: 15,
    ),
    QuestionSeed(
      subject: 1,
      chapter: 5,
      lesson: 9,
      order: 4,
      promptAr: 'أي مما يلي لا يوجد في الخلية الحيوانية؟',
      promptEn: 'Which of these is absent from an animal cell?',
      correctKey: 'D',
      correctAr: 'الجدار الخلوي',
      correctEn: 'the cell wall',
      wrongKeys: <String>['A', 'B', 'C'],
      wrongAr: <String>['النواة', 'الغشاء الخلوي', 'السيتوبلازم'],
      wrongEn: <String>['the nucleus', 'the cell membrane', 'the cytoplasm'],
      explanationAr: 'الجدار الخلوي والفجوات الكبيرة من خصائص الخلية النباتية، '
          'أما الخلية الحيوانية فتفقدهما.',
      explanationEn: 'Cell walls and large vacuoles belong to plant cells; animal '
          'cells lack them.',
    ),
    QuestionSeed(
      subject: 2,
      chapter: 6,
      lesson: 10,
      order: 5,
      promptAr: 'الجملة «الطالبُ مجتهدٌ» هي جملة:',
      promptEn: '"The diligent student" is a(n):',
      correctKey: 'B',
      correctAr: 'اسمية',
      correctEn: 'nominal',
      wrongKeys: <String>['A', 'C', 'D'],
      wrongAr: <String>['فعلية', 'شرطية', 'إنشائية'],
      wrongEn: <String>['verbal', 'conditional', 'interrogative'],
      explanationAr: 'هي جملة اسمية لأنها تبدأ باسم وتنتهي باسم. '
          'المبتدأ هو «الطالبُ» والخبر هو «مجتهدٌ».',
      explanationEn: 'It is a nominal sentence because it begins and ends with a '
          'noun: the subject is "the student" and the predicate "diligent".',
      difficulty: 2,
      points: 15,
    ),
    QuestionSeed(
      subject: 2,
      chapter: 8,
      lesson: 13,
      order: 6,
      promptAr: 'أي الكلمات الآتية بهمزة قطع؟',
      promptEn: 'Which of these carries a cut hamza?',
      correctKey: 'C',
      correctAr: 'أخذ',
      correctEn: 'akhadh',
      wrongKeys: <String>['A', 'B', 'D'],
      wrongAr: <String>['إنّ', 'أنّ', 'إنما'],
      wrongEn: <String>['inna', 'anna', 'inima'],
      explanationAr: 'همزة الوصل تُكتب في «إنّ» و«أنّ» و«إنما»، أما «أخذ» '
          'فهمزة قطع لأن ما قبلها ساكن.',
      explanationEn: 'Inna, anna and inima take a connected hamza, while the '
          'hamza in akhadh is cut because the preceding letter is silent.',
      difficulty: 3,
      points: 20,
    ),
    QuestionSeed(
      subject: 3,
      chapter: 9,
      lesson: 14,
      order: 7,
      promptAr: 'اختر الجملة الصحيحة:',
      promptEn: 'Choose the correct sentence:',
      correctKey: 'A',
      correctAr: 'She studies math.',
      correctEn: 'She studies math.',
      wrongKeys: <String>['B', 'C', 'D'],
      wrongAr: <String>[
        'He study Arabic.',
        'They studies English.',
        'She study math.',
      ],
      wrongEn: <String>[
        'He study Arabic.',
        'They studies English.',
        'She study math.',
      ],
      explanationAr: 'مع he و she و it نضيف s إلى الفعل، ومع I و you و we و they '
          'يبقى الفعل كما هو.',
      explanationEn: 'With he, she and it the verb takes -s; with I, you, we and '
          'they the verb stays unchanged.',
    ),
    QuestionSeed(
      subject: 3,
      chapter: 9,
      lesson: 15,
      order: 8,
      promptAr: 'الشكل الماضي للفعل go هو:',
      promptEn: 'The past form of "go" is:',
      correctKey: 'B',
      correctAr: 'went',
      correctEn: 'went',
      wrongKeys: <String>['A', 'C', 'D'],
      wrongAr: <String>['goed', 'gone', 'going'],
      wrongEn: <String>['goed', 'gone', 'going'],
      explanationAr: 'الأفعال الشاذة لا تتبع القاعدة العامة، و go / went / gone '
          'من أشهر الأمثلة.',
      explanationEn: 'Irregular verbs do not follow the -ed rule: go, went, gone.',
      difficulty: 2,
      points: 15,
    ),
    QuestionSeed(
      subject: 1,
      chapter: 4,
      lesson: 8,
      order: 9,
      promptAr: 'الرابطة الكيميائية التي تنشأ بمشاركة زوج من الإلكترونات تُسمى:',
      promptEn: 'A bond formed by sharing an electron pair is called a:',
      correctKey: 'C',
      correctAr: 'رابطة تساهمية',
      correctEn: 'a covalent bond',
      wrongKeys: <String>['A', 'B', 'D'],
      wrongAr: <String>['رابطة أيونية', 'رابطة فلزية', 'رابطة هيدروجينية'],
      wrongEn: <String>['an ionic bond', 'a metallic bond', 'a hydrogen bond'],
      explanationAr: 'التساهمية تنشأ بمشاركة الإلكترونات، أما الأيونية فتنتقل '
          'الإلكترونات من ذرة إلى أخرى.',
      explanationEn: 'Covalent bonds share electrons; ionic bonds transfer them.',
      difficulty: 3,
      points: 20,
    ),
    QuestionSeed(
      subject: 3,
      chapter: 9,
      lesson: 14,
      order: 10,
      type: QuestionType.trueFalse,
      promptAr: 'في المضارع البسيط نضيف s إلى الفعل مع he و she و it.',
      promptEn: 'In the present simple we add -s to the verb with he, she and it.',
      correctKey: 'A',
      correctAr: 'صحيح',
      correctEn: 'True',
      wrongKeys: <String>['B'],
      wrongAr: <String>['خطأ'],
      wrongEn: <String>['False'],
      explanationAr: 'هذا صحيح: الأفعال الغيبية المفرد تنتهي بـ s في المضارع البسيط.',
      explanationEn: 'Correct: third-person singular verbs take -s in the '
          'present simple.',
    ),
  ];

  // ----------------------------------------------------------------- quizzes

  static const List<QuizSeed> quizzes = <QuizSeed>[
    QuizSeed(
      subject: 0,
      chapter: 0,
      lesson: 0,
      titleAr: 'اختبار الكسور السريعة',
      titleEn: 'Quick fractions quiz',
      descriptionAr: 'خمسة أسئلة سريعة على جمع الكسور والنسب.',
      descriptionEn: 'Five quick questions on fractions and ratios.',
      passingScore: 60,
      timeLimitSeconds: 180,
      xpReward: 60,
      difficulty: 1,
    ),
    QuizSeed(
      subject: 0,
      chapter: 1,
      lesson: 2,
      titleAr: 'اختبار المعادلات الخطية',
      titleEn: 'Linear equations quiz',
      descriptionAr: 'حل المعادلات خطوة بخطوة.',
      descriptionEn: 'Solve linear equations step by step.',
      passingScore: 70,
      xpReward: 80,
      difficulty: 2,
    ),
    QuizSeed(
      subject: 1,
      chapter: 3,
      lesson: 5,
      titleAr: 'قوانين نيوتن',
      titleEn: "Newton's laws quiz",
      descriptionAr: 'اختبر فهمك لقوانين الحركة الثلاثة.',
      descriptionEn: 'Test the three laws of motion.',
      passingScore: 70,
      xpReward: 75,
      difficulty: 2,
    ),
    QuizSeed(
      subject: 2,
      chapter: 6,
      lesson: 10,
      titleAr: 'أساسيات النحو العربي',
      titleEn: 'Arabic grammar basics',
      descriptionAr: 'الجملة الاسمية والفعلية وأنواع الكلام.',
      descriptionEn: 'Sentence types and parts of speech.',
      passingScore: 60,
      xpReward: 65,
      difficulty: 1,
    ),
    QuizSeed(
      subject: 3,
      chapter: 9,
      lesson: 14,
      titleAr: 'الأزمنة الإنجليزية',
      titleEn: 'English tenses quiz',
      descriptionAr: 'Present simple and past simple.',
      descriptionEn: 'Present simple and past simple.',
      passingScore: 60,
      timeLimitSeconds: 240,
      xpReward: 70,
      difficulty: 1,
    ),
  ];

  // -------------------------------------------------------------- flashcards

  static const List<FlashcardSeed> flashcards = <FlashcardSeed>[
    FlashcardSeed(
      subject: 1,
      chapter: 3,
      lesson: 5,
      frontAr: 'ما هو قانون نيوتن الثاني؟',
      frontEn: "What is Newton's first law?",
      backAr: 'يبقى الجسم ساكنًا أو متحركًا بسرعة ثابتة في خط مستقيم ما لم تؤثر عليه قوة خارجية.',
      backEn: 'An object remains at rest or in uniform straight-line motion '
          'unless an external force acts on it.',
      hintAr: 'اكتشفها نيوتن في القرن السابع عشر.',
    ),
    FlashcardSeed(
      subject: 0,
      chapter: 0,
      lesson: 0,
      frontAr: 'كيف نجمع كسرين مختلفين؟',
      frontEn: 'How do you add two different fractions?',
      backAr: 'وحد المقامات أولًا إلى أبسط صورة مشتركة، ثم اجمع البسوط.',
      backEn: 'Bring the denominators to a common form first, then add the '
          'numerators.',
      hintAr: 'الخطوة الأولى دائمًا توحيد المقام.',
    ),
    FlashcardSeed(
      subject: 1,
      chapter: 5,
      lesson: 9,
      frontAr: 'ما الفرق بين الخلية النباتية والحيوانية؟',
      frontEn: 'Plant cell vs animal cell?',
      backAr: 'النباتية فيها جدار خلوي وفجوات كبيرة، الحيوانية بدونهما.',
      backEn: 'Plant cells have a cell wall and large vacuoles; animal cells do not.',
      hintAr: 'فكر في شكل النبات وصلابته.',
    ),
    FlashcardSeed(
      subject: 1,
      chapter: 3,
      lesson: 5,
      frontAr: 'ما وحدة القوة في النظام الدولي؟',
      frontEn: 'The SI unit of force?',
      backAr: 'نيوتن (N)، وتُقاس بـ كجم·م/ث².',
      backEn: 'The newton (N), measured in kg·m/s².',
      hintAr: 'سُمّيت على اسم العالم.',
    ),
    FlashcardSeed(
      subject: 2,
      chapter: 6,
      lesson: 10,
      frontAr: 'ما الجملة الاسمية؟',
      frontEn: 'What is a nominal sentence?',
      backAr: 'جملة تبدأ باسم وتنتهي باسم، مثل: «العلمُ نورٌ».',
      backEn: 'A sentence that begins and ends with a noun.',
      hintAr: 'اسأل: ما الذي يبدأ الجملة وينتهيها؟',
    ),
    FlashcardSeed(
      subject: 2,
      chapter: 6,
      lesson: 10,
      frontAr: 'أقسام الكلام في العربية؟',
      frontEn: 'The three parts of Arabic speech?',
      backAr: 'اسم، وفعل، وحرف.',
      backEn: 'Noun, verb and particle.',
      hintAr: 'ثلاثة فقط.',
    ),
    FlashcardSeed(
      subject: 3,
      chapter: 9,
      lesson: 14,
      frontAr: 'متى نستخدم المضارع البسيط؟',
      frontEn: 'When do we use the present simple?',
      backAr: 'للعادة والحقائق العامة، ومع الغائب المفرد نضيف s.',
      backEn: 'For habits and general facts; add -s with he/she/it.',
      hintAr: 'العادة تتكرر، والحقيقة لا تتغير.',
    ),
    FlashcardSeed(
      subject: 3,
      chapter: 9,
      lesson: 15,
      frontAr: 'أفعال شاذة شائعة؟',
      frontEn: 'Common irregular verbs?',
      backAr: 'go/went، have/had، eat/ate.',
      backEn: 'go/went, have/had, eat/ate.',
      hintAr: 'لا تتبع قاعدة -ed.',
    ),
  ];

  // ----------------------------------------------------------- gamification

  static const List<AchievementSeed> achievements = <AchievementSeed>[
    AchievementSeed(
      code: 'first_quiz',
      nameAr: 'الخطوة الأولى',
      nameEn: 'First step',
      descriptionAr: 'أنهِ أول اختبار لك.',
      descriptionEn: 'Complete your first quiz.',
      metric: AchievementMetric.quizzesTaken,
      threshold: 1,
      iconKey: 'achievement_first',
      xpReward: 20,
    ),
    AchievementSeed(
      code: 'quiz_master',
      nameAr: 'سيّد الاختبارات',
      nameEn: 'Quiz master',
      descriptionAr: 'أنهِ عشرة اختبارات.',
      descriptionEn: 'Complete ten quizzes.',
      metric: AchievementMetric.quizzesTaken,
      threshold: 10,
      iconKey: 'achievement_master',
      xpReward: 120,
    ),
    AchievementSeed(
      code: 'perfect_score',
      nameAr: 'العلامة الكاملة',
      nameEn: 'Perfect score',
      descriptionAr: 'احصل على ١٠٠٪ في اختبار واحد.',
      descriptionEn: 'Score 100% on a single quiz.',
      metric: AchievementMetric.perfectQuizzes,
      threshold: 1,
      iconKey: 'achievement_perfect',
      xpReward: 60,
    ),
    AchievementSeed(
      code: 'sharp_eye',
      nameAr: 'العين الدقيقة',
      nameEn: 'Sharp eye',
      descriptionAr: 'اجعل دقة إجاباتك تتجاوز ٩٠٪.',
      descriptionEn: 'Reach over 90% answer accuracy.',
      metric: AchievementMetric.accuracyPercent,
      threshold: 90,
      iconKey: 'achievement_accuracy',
      xpReward: 100,
    ),
    AchievementSeed(
      code: 'bookworm',
      nameAr: 'مهووس المعرفة',
      nameEn: 'Bookworm',
      descriptionAr: 'أكمل عشرين درسًا.',
      descriptionEn: 'Complete twenty lessons.',
      metric: AchievementMetric.lessonsCompleted,
      threshold: 20,
      iconKey: 'achievement_lessons',
      xpReward: 150,
    ),
    AchievementSeed(
      code: 'card_master',
      nameAr: 'سيّد البطاقات',
      nameEn: 'Card master',
      descriptionAr: 'راجع خمسين بطاقة تعليمية.',
      descriptionEn: 'Review fifty flashcards.',
      metric: AchievementMetric.flashcardsReviewed,
      threshold: 50,
      iconKey: 'achievement_cards',
      xpReward: 90,
    ),
    AchievementSeed(
      code: 'week_streak',
      nameAr: 'أسبوع من الالتزام',
      nameEn: 'Seven-day streak',
      descriptionAr: 'ادرس سبعة أيام متتالية.',
      descriptionEn: 'Study seven days in a row.',
      metric: AchievementMetric.streakDays,
      threshold: 7,
      iconKey: 'achievement_streak',
      xpReward: 200,
    ),
    AchievementSeed(
      code: 'explorer',
      nameAr: 'المستكشف',
      nameEn: 'Explorer',
      descriptionAr: 'تصفّح جميع المواد الدراسية.',
      descriptionEn: 'Explore every subject.',
      metric: AchievementMetric.subjectsExplored,
      threshold: 4,
      iconKey: 'achievement_explorer',
      xpReward: 80,
    ),
  ];

  static const List<ChallengeSeed> challenges = <ChallengeSeed>[
    ChallengeSeed(
      code: 'daily_questions',
      nameAr: 'تحدي الأسئلة اليومي',
      nameEn: 'Daily question challenge',
      descriptionAr: 'أجب عن عشرة أسئلة اليوم مهما كانت.',
      descriptionEn: 'Answer ten questions today.',
      period: RepeatPeriod.daily,
      metric: ChallengeMetric.correctAnswers,
      target: 10,
      xpReward: 40,
      iconKey: 'challenge_daily_questions',
    ),
    ChallengeSeed(
      code: 'daily_study',
      nameAr: 'خمس عشرة دقيقة',
      nameEn: 'Fifteen minutes',
      descriptionAr: 'ادرس لمدة خمس عشرة دقيقة على الأقل اليوم.',
      descriptionEn: 'Study for at least fifteen minutes today.',
      period: RepeatPeriod.daily,
      metric: ChallengeMetric.studyMinutes,
      target: 15,
      xpReward: 35,
      iconKey: 'challenge_daily_study',
    ),
    ChallengeSeed(
      code: 'daily_quiz',
      nameAr: 'اختبار واحد كل يوم',
      nameEn: 'One quiz a day',
      descriptionAr: 'أنهِ اختبارًا واحدًا على الأقل اليوم.',
      descriptionEn: 'Finish at least one quiz today.',
      period: RepeatPeriod.daily,
      metric: ChallengeMetric.quizzesTaken,
      target: 1,
      xpReward: 50,
      iconKey: 'challenge_daily_quiz',
    ),
    ChallengeSeed(
      code: 'daily_flashcards',
      nameAr: 'مراجعة البطاقات',
      nameEn: 'Card review',
      descriptionAr: 'راجع خمس بطاقات تعليمية اليوم.',
      descriptionEn: 'Review five flashcards today.',
      period: RepeatPeriod.daily,
      metric: ChallengeMetric.flashcardsReviewed,
      target: 5,
      xpReward: 30,
      iconKey: 'challenge_daily_cards',
    ),
    ChallengeSeed(
      code: 'weekly_questions',
      nameAr: 'تحدي الأسبوع',
      nameEn: 'Weekly challenge',
      descriptionAr: 'أجب عن خمسين سؤالًا خلال الأسبوع.',
      descriptionEn: 'Answer fifty questions this week.',
      period: RepeatPeriod.weekly,
      metric: ChallengeMetric.correctAnswers,
      target: 50,
      xpReward: 200,
      difficulty: 2,
      iconKey: 'challenge_weekly_questions',
    ),
    ChallengeSeed(
      code: 'weekly_quizzes',
      nameAr: 'خمسة اختبارات أسبوعيًا',
      nameEn: 'Five quizzes a week',
      descriptionAr: 'أنهِ خمسة اختبارات خلال الأسبوع.',
      descriptionEn: 'Finish five quizzes this week.',
      period: RepeatPeriod.weekly,
      metric: ChallengeMetric.quizzesTaken,
      target: 5,
      xpReward: 180,
      difficulty: 2,
      iconKey: 'challenge_weekly_quizzes',
    ),
    ChallengeSeed(
      code: 'weekly_streak',
      nameAr: 'حضور أسبوعي',
      nameEn: 'Weekly attendance',
      descriptionAr: 'كن نشطًا في خمسة أيام خلال الأسبوع.',
      descriptionEn: 'Be active on five days this week.',
      period: RepeatPeriod.weekly,
      metric: ChallengeMetric.activeDays,
      target: 5,
      xpReward: 150,
      difficulty: 2,
      iconKey: 'challenge_weekly_days',
    ),
    ChallengeSeed(
      code: 'accuracy_challenge',
      nameAr: 'دقة عالية',
      nameEn: 'High accuracy',
      descriptionAr: 'حقق دقة لا تقل عن ٨٥٪ في اختبارات اليوم.',
      descriptionEn: 'Reach at least 85% accuracy in today\'s quizzes.',
      period: RepeatPeriod.daily,
      metric: ChallengeMetric.accuracyPercent,
      target: 85,
      xpReward: 60,
      difficulty: 3,
      iconKey: 'challenge_accuracy',
    ),
  ];

  static const List<GoalSeed> studyGoals = <GoalSeed>[
    GoalSeed(
      period: 'daily',
      targetType: GoalTargetType.questions,
      targetValue: 10,
      rewardXp: 40,
    ),
    GoalSeed(
      period: 'daily',
      targetType: GoalTargetType.minutes,
      targetValue: 15,
      rewardXp: 35,
    ),
    GoalSeed(
      period: 'weekly',
      targetType: GoalTargetType.questions,
      targetValue: 50,
      rewardXp: 200,
    ),
    GoalSeed(
      period: 'weekly',
      targetType: GoalTargetType.minutes,
      targetValue: 120,
      rewardXp: 180,
    ),
  ];

  // ------------------------------------------------------------------ lookup

  /// Fails loudly when the catalogue and the database disagree, instead of
  /// letting a seed index run off the end of an id list.
  static void _require(bool condition, String what, int needed, int available) {
    if (condition) return;
    throw StateError(
      'Cannot seed $what: the catalogue needs $needed but the database has '
      '$available.',
    );
  }

  static Future<List<int>> _subjectIdsInOrder(DatabaseExecutor db) async {
    final List<Map<String, Object?>> rows = await db.query(
      Tables.subjects,
      columns: <String>[Col.id],
      orderBy: '${Col.sortOrder} ASC',
    );
    return <int>[
      for (final Map<String, Object?> row in rows)
        if (row[Col.id] is int) row[Col.id]! as int,
    ];
  }

  static Future<List<int>> _chapterIdsInOrder(DatabaseExecutor db) async {
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT ${Col.id} FROM ${Tables.chapters} '
      'ORDER BY ${Col.subjectId} ASC, ${Col.sortOrder} ASC',
    );
    return <int>[
      for (final Map<String, Object?> row in rows)
        if (row[Col.id] is int) row[Col.id]! as int,
    ];
  }

  static Future<List<int>> _lessonIdsInOrder(DatabaseExecutor db) async {
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT ${Col.id} FROM ${Tables.lessons} '
      'ORDER BY ${Col.chapterId} ASC, ${Col.sortOrder} ASC',
    );
    return <int>[
      for (final Map<String, Object?> row in rows)
        if (row[Col.id] is int) row[Col.id]! as int,
    ];
  }
}

// ======================================================================== data

final class SubjectSeed {
  const SubjectSeed({
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.iconKey,
    required this.colorHex,
  });

  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final String iconKey;
  final String colorHex;
}

final class ChapterSeed {
  const ChapterSeed({
    required this.titleAr,
    required this.titleEn,
    required this.summaryAr,
    required this.summaryEn,
    required this.estimatedMinutes,
  });

  final String titleAr;
  final String titleEn;
  final String summaryAr;
  final String summaryEn;
  final int estimatedMinutes;
}

final class LessonSeed {
  const LessonSeed({
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.durationMinutes,
    this.lessonType = LessonType.reading,
    this.difficulty = 1,
  });

  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final LessonType lessonType;
  final int difficulty;
  final int durationMinutes;
}

final class QuestionSeed {
  const QuestionSeed({
    required this.subject,
    required this.lesson,
    required this.order,
    required this.promptAr,
    required this.promptEn,
    required this.explanationAr,
    required this.explanationEn,
    required this.correctKey,
    required this.correctAr,
    required this.correctEn,
    required this.wrongKeys,
    required this.wrongAr,
    required this.wrongEn,
    this.chapter,
    this.type = QuestionType.single,
    this.difficulty = 1,
    this.points = 10,
  });

  final int subject;
  final int? chapter;
  final int lesson;
  final int order;
  final String promptAr;
  final String promptEn;
  final String explanationAr;
  final String explanationEn;
  final String correctKey;
  final String correctAr;
  final String correctEn;
  final List<String> wrongKeys;
  final List<String> wrongAr;
  final List<String> wrongEn;
  final QuestionType type;
  final int difficulty;
  final int points;
}

final class QuizSeed {
  const QuizSeed({
    required this.subject,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.passingScore,
    required this.xpReward,
    this.chapter,
    this.lesson,
    this.timeLimitSeconds = 0,
    this.difficulty = 1,
    this.isRandomOrder = true,
    this.maxAttempts = 0,
  });

  final int subject;
  final int? chapter;
  final int? lesson;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final int passingScore;
  final int timeLimitSeconds;
  final int difficulty;
  final bool isRandomOrder;
  final int maxAttempts;
  final int xpReward;
}

final class FlashcardSeed {
  const FlashcardSeed({
    required this.subject,
    required this.frontAr,
    required this.frontEn,
    required this.backAr,
    required this.backEn,
    required this.hintAr,
    this.chapter,
    this.lesson,
    this.difficulty = 1,
  });

  final int subject;
  final int? chapter;
  final int? lesson;
  final String frontAr;
  final String frontEn;
  final String backAr;
  final String backEn;
  final String hintAr;
  final int difficulty;
}

final class AchievementSeed {
  const AchievementSeed({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.metric,
    required this.threshold,
    required this.iconKey,
    required this.xpReward,
  });

  final String code;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final AchievementMetric metric;
  final int threshold;
  final String iconKey;
  final int xpReward;
}

final class ChallengeSeed {
  const ChallengeSeed({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.period,
    required this.metric,
    required this.target,
    required this.xpReward,
    required this.iconKey,
    this.difficulty = 1,
    this.subject,
  });

  final String code;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final RepeatPeriod period;
  final ChallengeMetric metric;
  final int target;
  final int xpReward;
  final String iconKey;
  final int difficulty;
  final int? subject;
}

final class GoalSeed {
  const GoalSeed({
    required this.period,
    required this.targetType,
    required this.targetValue,
    required this.rewardXp,
  });

  final String period;
  final GoalTargetType targetType;
  final int targetValue;
  final int rewardXp;
}