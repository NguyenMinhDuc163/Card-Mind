import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/modules/course/model/test_question.dart';
import 'package:card_mind/data/models/flashcard.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class TestNotifier extends ChangeNotifier {
  List<TestQuestion> _questions = [];
  List<TestAnswer> _answers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _testStartTime;
  String? _courseId;

  List<TestQuestion> get questions => _questions;

  List<TestAnswer> get answers => _answers;

  int get currentQuestionIndex => _currentQuestionIndex;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  String? get courseId => _courseId;

  TestQuestion? get currentQuestion =>
      _currentQuestionIndex < _questions.length ? _questions[_currentQuestionIndex] : null;

  bool get isTestCompleted => _currentQuestionIndex >= _questions.length;

  int get totalQuestions => _questions.length;

  int get correctAnswers => _answers.where((answer) => answer.isCorrect).length;

  double get score => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

  Future<void> initializeTest({String? courseId, List<Flashcard>? flashcards}) async {
    _isLoading = true;
    _errorMessage = null;
    _courseId = courseId;
    _testStartTime = DateTime.now();
    notifyListeners();

    try {
      if (courseId != null && flashcards != null) {
        await _generateTestQuestions(courseId, flashcards);
      }
    } catch (e) {
      _errorMessage = 'Không thể tạo bài kiểm tra: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _generateTestQuestions(String courseId, List<Flashcard> flashcards) async {
    if (flashcards.isEmpty) {
      throw Exception('Không có thẻ học để tạo bài kiểm tra');
    }

    _questions.clear();
    _answers.clear();
    _currentQuestionIndex = 0;

    final List<Flashcard> shuffledCards = List.from(flashcards)..shuffle();
    final int questionCount = min(10, flashcards.length);

    for (int i = 0; i < questionCount; i++) {
      final flashcard = shuffledCards[i];
      final question = _createQuestionFromFlashcard(flashcard, shuffledCards, i);
      _questions.add(question);
    }

    _questions.shuffle();
  }

  TestQuestion _createQuestionFromFlashcard(
    Flashcard flashcard,
    List<Flashcard> allCards,
    int index,
  ) {
    final List<String> wrongAnswers = [];
    final List<Flashcard> otherCards =
        allCards.where((card) => card.id != flashcard.id).toList()..shuffle();

    for (int i = 0; i < min(3, otherCards.length); i++) {
      wrongAnswers.add(otherCards[i].backText);
    }

    final List<String> options = [flashcard.backText, ...wrongAnswers];
    options.shuffle();

    return TestQuestion(
      id: 'test_${flashcard.id}_$index',
      question: flashcard.frontText,
      correctAnswer: flashcard.backText,
      options: options,
      category: flashcard.category,
    );
  }

  void answerQuestion(String selectedAnswer) {
    if (currentQuestion == null) return;

    final answer = TestAnswer(
      questionId: currentQuestion!.id,
      selectedAnswer: selectedAnswer,
      isCorrect: selectedAnswer == currentQuestion!.correctAnswer,
      answeredAt: DateTime.now(),
    );

    _answers.add(answer);
    _currentQuestionIndex++;
    notifyListeners();
  }

  TestResult? completeTest() {
    if (_testStartTime == null) return null;

    final testResult = TestResult(
      testId: 'test_${_courseId}_${DateTime.now().millisecondsSinceEpoch}',
      answers: List.from(_answers),
      totalQuestions: _questions.length,
      correctAnswers: correctAnswers,
      score: score,
      completedAt: DateTime.now(),
      timeSpent: DateTime.now().difference(_testStartTime!),
    );

    _saveTestResult(testResult);

    return testResult;
  }

  Future<void> _saveTestResult(TestResult result) async {
    try {
      final resultKey = 'test_result_${result.testId}';
      await LocalStorageHelper.setValue(resultKey, result.toJson());

      final existingResults = LocalStorageHelper.getValue('test_results') as List<dynamic>? ?? [];
      final List<String> updatedResults = existingResults.cast<String>();
      updatedResults.add(resultKey);
      await LocalStorageHelper.setValue('test_results', updatedResults);
    } catch (e) {
      print('Error saving test result: $e');
    }
  }

  void resetTest() {
    _questions.clear();
    _answers.clear();
    _currentQuestionIndex = 0;
    _testStartTime = null;
    _errorMessage = null;

    notifyListeners();
  }

  void resetTestCompletely() {
    _questions.clear();
    _answers.clear();
    _currentQuestionIndex = 0;
    _testStartTime = null;
    _courseId = null;
    _errorMessage = null;
    notifyListeners();
  }

  void goToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  bool isQuestionAnswered(int questionIndex) {
    return questionIndex < _answers.length;
  }

  TestAnswer? getAnswerForQuestion(int questionIndex) {
    if (questionIndex < _answers.length) {
      return _answers[questionIndex];
    }
    return null;
  }
}
