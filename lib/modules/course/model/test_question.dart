import 'package:equatable/equatable.dart';

class TestQuestion extends Equatable {
  final String id;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String category;

  const TestQuestion({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.category,
  });

  @override
  List<Object?> get props => [id, question, correctAnswer, options, category];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'correctAnswer': correctAnswer,
      'options': options,
      'category': category,
    };
  }

  factory TestQuestion.fromJson(Map<String, dynamic> json) {
    return TestQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      correctAnswer: json['correctAnswer'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      category: json['category'] as String,
    );
  }
}

class TestAnswer extends Equatable {
  final String questionId;
  final String selectedAnswer;
  final bool isCorrect;
  final DateTime answeredAt;

  const TestAnswer({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.answeredAt,
  });

  @override
  List<Object?> get props => [
    questionId,
    selectedAnswer,
    isCorrect,
    answeredAt,
  ];

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  factory TestAnswer.fromJson(Map<String, dynamic> json) {
    return TestAnswer(
      questionId: json['questionId'] as String,
      selectedAnswer: json['selectedAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
    );
  }
}

class TestResult extends Equatable {
  final String testId;
  final List<TestAnswer> answers;
  final int totalQuestions;
  final int correctAnswers;
  final double score;
  final DateTime completedAt;
  final Duration timeSpent;

  const TestResult({
    required this.testId,
    required this.answers,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.completedAt,
    required this.timeSpent,
  });

  @override
  List<Object?> get props => [
    testId,
    answers,
    totalQuestions,
    correctAnswers,
    score,
    completedAt,
    timeSpent,
  ];

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'answers': answers.map((x) => x.toJson()).toList(),
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'score': score,
      'completedAt': completedAt.toIso8601String(),
      'timeSpent': timeSpent.inMilliseconds,
    };
  }

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      testId: json['testId'] as String,
      answers:
          (json['answers'] as List<dynamic>)
              .map((x) => TestAnswer.fromJson(x as Map<String, dynamic>))
              .toList(),
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      score: (json['score'] as num).toDouble(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      timeSpent: Duration(milliseconds: json['timeSpent'] as int),
    );
  }
}
