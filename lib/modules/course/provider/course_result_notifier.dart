import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/modules/course/model/course_data.dart';
import 'package:card_mind/data/models/course.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'detail_flash_card_notifier.dart';

class CourseResultNotifier extends ChangeNotifier {
  CourseData? _courseData;
  Course? _course;
  Set<String> _learnedCardIds = {};
  List<Map<String, dynamic>> _learnedCards = [];
  List<Map<String, dynamic>> _unlearnedCards = [];
  bool _isLoading = false;
  String? _errorMessage;

  CourseData? get courseData => _courseData;

  Course? get course => _course;

  Set<String> get learnedCardIds => _learnedCardIds;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  int get totalCards => _learnedCards.length + _unlearnedCards.length;

  int get learnedCount => _learnedCards.length;

  int get unlearnedCount => _unlearnedCards.length;

  double get progressPercentage =>
      totalCards > 0 ? learnedCount / totalCards : 0.0;

  int get knownCount => learnedCount;

  int get learningCount => 0;

  int get remainingCount => unlearnedCount;

  List<Map<String, dynamic>> get learnedCards => _learnedCards;

  List<Map<String, dynamic>> get unlearnedCards => _unlearnedCards;

  Future<void> initializeData({String? courseId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (courseId != null) {
        await _loadCourseFromHive(courseId);
        await _loadCardLists(courseId);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = tr('course_result.error_loading', args: [e.toString()]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCourseFromHive(String courseId) async {
    try {
      final courseKeys =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];

      for (final key in courseKeys) {
        final courseData = LocalStorageHelper.getValue(key as String);
        if (courseData != null) {
          final Map<String, dynamic> jsonData = {};
          final Map<dynamic, dynamic> rawData =
              courseData as Map<dynamic, dynamic>;

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
      throw Exception(
        tr('course_result.error_loading_course', args: [e.toString()]),
      );
    }
  }

  Future<void> _loadCardLists(String courseId) async {
    try {
      _learnedCards = await DetailFlashCardNotifier.getLearnedCards(courseId);

      _unlearnedCards = await DetailFlashCardNotifier.getUnlearnedCards(
        courseId,
      );

      _learnedCardIds =
          _learnedCards.map((card) => card['id'] as String).toSet();
    } catch (e) {
      _learnedCards = [];
      _unlearnedCards = [];
      _learnedCardIds = <String>{};
    }
  }

  void _convertToUICourse() {
    if (_courseData == null) return;

    _course = Course(
      id: _courseData!.id,
      title: _courseData!.title,
      description: _courseData!.description ?? '',
      flashcards: [],
      totalTerms: _courseData!.terms.length,
      isVerified: true,
      author: 'User',
      createdAt: _courseData!.createdAt,
      updatedAt: _courseData!.updatedAt,
      category: _courseData!.topic,
    );
  }

  String get congratulationMessage {
    if (progressPercentage >= 1.0) {
      return tr('course_result.congrats.excellent');
    } else if (progressPercentage >= 0.8) {
      return tr('course_result.congrats.great');
    } else if (progressPercentage >= 0.5) {
      return tr('course_result.congrats.good');
    } else {
      return tr('course_result.congrats.keep_going');
    }
  }

  String get descriptionMessage {
    if (progressPercentage >= 1.0) {
      return tr('course_result.description.excellent');
    } else if (progressPercentage >= 0.8) {
      return tr('course_result.description.great');
    } else if (progressPercentage >= 0.5) {
      return tr('course_result.description.good');
    } else {
      return tr('course_result.description.keep_going');
    }
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
