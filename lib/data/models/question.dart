import 'enums.dart';
import 'localized_text.dart';
import 'row_values.dart';

/// One answer option of a [Question].
///
/// Options live in their own table so a question can have any number of them
/// (two for a true/false question, four for a multiple-choice one) and so each
/// option keeps its own Arabic and English text.
class QuestionOption {
  const QuestionOption({
    this.id = 0,
    required this.questionId,
    required this.optionKey,
    required this.text,
    this.isCorrect = false,
    this.sortOrder = 0,
  });

  factory QuestionOption.fromRow(Map<String, Object?> row) => QuestionOption(
        id: intValue(row['id']),
        questionId: intValue(row['question_id']),
        optionKey: textValue(row['option_key']),
        text: LocalizedText.fromColumns(row['text_ar'], row['text_en']),
        isCorrect: boolValue(row['is_correct']),
        sortOrder: intValue(row['sort_order']),
      );

  /// `0` when the option has not been persisted yet.
  final int id;

  final int questionId;

  /// Short label shown before the text, for example `أ` or `A`.
  final String optionKey;

  /// Bilingual option text; Arabic is primary.
  final LocalizedText text;

  final bool isCorrect;
  final int sortOrder;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'question_id': questionId,
        'option_key': optionKey,
        'text_ar': text.ar,
        'text_en': text.en,
        'is_correct': boolToInt(isCorrect),
        'sort_order': sortOrder,
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  QuestionOption copyWith({int? id, int? questionId, bool? isCorrect}) =>
      QuestionOption(
        id: id ?? this.id,
        questionId: questionId ?? this.questionId,
        optionKey: optionKey,
        text: text,
        isCorrect: isCorrect ?? this.isCorrect,
        sortOrder: sortOrder,
      );
}

/// A question of a lesson, with its options.
class Question {
  const Question({
    required this.id,
    required this.lessonId,
    required this.subjectId,
    this.chapterId,
    required this.prompt,
    this.explanation = LocalizedText.empty,
    this.type = QuestionType.single,
    this.difficulty = Difficulty.easy,
    this.points = 10,
    this.sortOrder = 0,
    this.options = const <QuestionOption>[],
  });

  factory Question.fromRow(
    Map<String, Object?> row, {
    List<QuestionOption> options = const <QuestionOption>[],
  }) =>
      Question(
        id: intValue(row['id']),
        lessonId: intValue(row['lesson_id']),
        subjectId: intValue(row['subject_id']),
        chapterId: intOrNull(row['chapter_id']),
        prompt: LocalizedText.fromColumns(row['prompt_ar'], row['prompt_en']),
        explanation: LocalizedText.fromColumns(
          row['explanation_ar'],
          row['explanation_en'],
        ),
        type: QuestionType.fromValue(row['question_type']),
        difficulty: Difficulty.fromValue(row['difficulty']),
        points: intValue(row['points'], orElse: 10),
        sortOrder: intValue(row['sort_order']),
        options: options,
      );

  final int id;
  final int lessonId;

  /// Denormalised for subject-level question queries.
  final int subjectId;

  final int? chapterId;

  /// Bilingual question text; Arabic is primary.
  final LocalizedText prompt;

  /// Bilingual explanation shown after answering.
  final LocalizedText explanation;

  final QuestionType type;
  final Difficulty difficulty;

  /// Points awarded for a correct answer.
  final int points;

  final int sortOrder;

  /// Answer options, ordered by [QuestionOption.sortOrder].
  final List<QuestionOption> options;

  /// The keys of the correct options.
  List<String> get correctKeys => <String>[
        for (final QuestionOption option in options)
          if (option.isCorrect) option.optionKey,
      ];

  /// Whether [selected] answers the question correctly.
  ///
  /// Single-answer questions compare the picked key, multiple-answer questions
  /// compare the whole set, so picking extra options is never rewarded.
  bool isAnsweredCorrectly(Set<String> selected) {
    final Set<String> correct = correctKeys.toSet();
    if (correct.isEmpty) return false;
    if (type == QuestionType.multiple) {
      if (selected.length != correct.length) return false;
      return selected.containsAll(correct);
    }
    return selected.length == 1 && correct.contains(selected.first);
  }

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'lesson_id': lessonId,
        'subject_id': subjectId,
        'chapter_id': chapterId,
        'prompt_ar': prompt.ar,
        'prompt_en': prompt.en,
        'explanation_ar': explanation.ar,
        'explanation_en': explanation.en,
        'question_type': type.key,
        'difficulty': difficulty.level,
        'points': points,
        'sort_order': sortOrder,
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  Question copyWith({
    int? id,
    int? lessonId,
    LocalizedText? prompt,
    LocalizedText? explanation,
    List<QuestionOption>? options,
  }) =>
      Question(
        id: id ?? this.id,
        lessonId: lessonId ?? this.lessonId,
        subjectId: subjectId,
        chapterId: chapterId,
        prompt: prompt ?? this.prompt,
        explanation: explanation ?? this.explanation,
        type: type,
        difficulty: difficulty,
        points: points,
        sortOrder: sortOrder,
        options: options ?? this.options,
      );

  @override
  String toString() => 'Question($id)';
}