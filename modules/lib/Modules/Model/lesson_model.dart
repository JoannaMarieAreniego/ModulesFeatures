//Model/lesson_module.dart
class Lesson {
  final String title;
  final String content;
  final List<String> activities;
  final List<QuizQuestion> quizQuestions;

  Lesson({
    required this.title,
    required this.content,
    required this.activities,
    required this.quizQuestions, 
  });
}

class QuizQuestion {
  final String question;
  final List<String>? options;
  final String answer;

  QuizQuestion({
    required this.question,
    this.options,
    required this.answer,
  });
}

class ExamQuestions{
  final String? examquestion;
  final List<String>? examoptions;
  final String? examanswer;

  ExamQuestions({
    this.examquestion,
    this.examoptions,
    this.examanswer
  });
}