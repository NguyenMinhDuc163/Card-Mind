import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/modules/course/model/course_data.dart';
import 'package:card_mind/data/models/course.dart';
import 'package:card_mind/data/models/flashcard.dart';
import 'package:flutter/foundation.dart';

class DetailFlashCardNotifier extends ChangeNotifier {
  CourseData? _courseData;
  Course? _course;
  List<Flashcard> _flashcards = [];
  Set<String> _learnedCardIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  String? _courseId;

  CourseData? get courseData => _courseData;

  Course? get course => _course;

  List<Flashcard> get flashcards => _flashcards;

  Set<String> get learnedCardIds => _learnedCardIds;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  String? get courseId => _courseId;

  int get totalCards => _flashcards.length;

  int get learnedCount => _learnedCardIds.length;

  int get unlearnedCount => totalCards - learnedCount;

  Future<void> initializeData({String? courseId}) async {
    _courseId = courseId;
    _isLoading = true;
    notifyListeners();
    try {
      if (courseId != null) {
        await _loadCourseFromHive(courseId);
        await _loadLearnedCards();
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCourseFromHive(String courseId) async {
    try {
      final courseKeys = LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];

      for (final key in courseKeys) {
        final courseData = LocalStorageHelper.getValue(key as String);
        if (courseData != null) {
          final Map<String, dynamic> jsonData = {};
          final Map<dynamic, dynamic> rawData = courseData as Map<dynamic, dynamic>;

          rawData.forEach((key, value) {
            jsonData[key.toString()] = _convertValue(value);
          });

          if (jsonData['id'] == courseId) {
            _courseData = CourseData.fromJson(jsonData);
            _convertToUICourse();
            break;
          }
        }
      }
    } catch (e) {
      throw Exception('Không thể load khóa học: $e');
    }
  }

  Future<void> _loadLearnedCards() async {
    try {
      final learnedCards =
          LocalStorageHelper.getValue('learned_cards_$_courseId') as List<dynamic>? ?? [];
      _learnedCardIds = learnedCards.cast<String>().toSet();
    } catch (e) {
      _learnedCardIds = <String>{};
    }
  }

  Future<void> _saveLearnedCards() async {
    try {
      LocalStorageHelper.setValue('learned_cards_$_courseId', _learnedCardIds.toList());
    } catch (e) {}
  }

  void _convertToUICourse() {
    if (_courseData == null) return;

    _flashcards =
        _courseData!.terms.map((term) {
          return Flashcard(
            id: term.id,
            frontText: term.term,
            backText: term.definition,
            category: _courseData!.topic,
            createdAt: _courseData!.createdAt,
            updatedAt: _courseData!.updatedAt,
          );
        }).toList();

    _course = Course(
      id: _courseData!.id,
      title: _courseData!.title,
      description: _courseData!.description ?? '',
      flashcards: _flashcards,
      totalTerms: _flashcards.length,
      isVerified: true,
      author: 'User',
      createdAt: _courseData!.createdAt,
      updatedAt: _courseData!.updatedAt,
      category: _courseData!.topic,
    );
  }

  void markCardAsLearned(String cardId) {
    if (!_learnedCardIds.contains(cardId)) {
      _learnedCardIds.add(cardId);
      _saveLearnedCards();
      notifyListeners();
    }
  }

  void unmarkCardAsLearned(String cardId) {
    if (_learnedCardIds.contains(cardId)) {
      _learnedCardIds.remove(cardId);
      _saveLearnedCards();
      notifyListeners();
    }
  }

  bool isCardLearned(String cardId) {
    return _learnedCardIds.contains(cardId);
  }

  dynamic _convertValue(dynamic value) {
    if (value is Map<dynamic, dynamic>) {
      final Map<String, dynamic> result = {};
      value.forEach((key, val) {
        result[key.toString()] = _convertValue(val);
      });
      return result;
    } else if (value is List<dynamic>) {
      return value.map((item) => _convertValue(item)).toList();
    } else {
      return value;
    }
  }
}
