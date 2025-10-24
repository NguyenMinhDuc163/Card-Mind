import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/modules/course/model/course_data.dart';
import 'package:card_mind/data/models/course.dart';
import 'package:flutter/foundation.dart';

class CourseResultNotifier extends ChangeNotifier {
  CourseData? _courseData;
  Course? _course;
  Set<String> _learnedCardIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  String? _courseId;

  CourseData? get courseData => _courseData;

  Course? get course => _course;

  Set<String> get learnedCardIds => _learnedCardIds;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  int get totalCards => _courseData?.terms.length ?? 0;

  int get learnedCount => _learnedCardIds.length;

  int get unlearnedCount => totalCards - learnedCount;

  double get progressPercentage => totalCards > 0 ? learnedCount / totalCards : 0.0;

  int get knownCount => learnedCount;

  int get learningCount => 0;

  int get remainingCount => unlearnedCount;

  Future<void> initializeData({String? courseId}) async {
    _courseId = courseId;
    _isLoading = true;
    notifyListeners();
    try {
      if (courseId != null) {
        await _loadCourseFromHive(courseId);
        await _loadLearnedCards();
        await _saveLearningResult();
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

  Future<void> _saveLearningResult() async {
    try {
      final resultData = {
        'courseId': _courseId,
        'courseTitle': _courseData?.title ?? '',
        'totalCards': totalCards,
        'learnedCount': learnedCount,
        'unlearnedCount': unlearnedCount,
        'progressPercentage': progressPercentage,
        'completedAt': DateTime.now().toIso8601String(),
        'learnedCardIds': _learnedCardIds.toList(),
      };

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final resultKey = 'learning_result_${_courseId}_$timestamp';

      LocalStorageHelper.setValue(resultKey, resultData);

      LocalStorageHelper.setValue('latest_result_$_courseId', resultData);

      final allResults =
          LocalStorageHelper.getValue('all_learning_results') as List<dynamic>? ?? [];
      allResults.add(resultKey);
      LocalStorageHelper.setValue('all_learning_results', allResults);
    } catch (e) {}
  }

  String get congratulationMessage {
    if (progressPercentage >= 1.0) {
      return 'Tuyệt vời! Bạn đã hoàn thành tất cả!';
    } else if (progressPercentage >= 0.8) {
      return 'Bạn đang làm rất tuyệt!';
    } else if (progressPercentage >= 0.5) {
      return 'Tiến bộ tốt! Hãy tiếp tục!';
    } else {
      return 'Hãy tiếp tục cố gắng!';
    }
  }

  String get descriptionMessage {
    if (progressPercentage >= 1.0) {
      return 'Bạn đã thành thạo tất cả thuật ngữ trong khóa học này.';
    } else if (progressPercentage >= 0.8) {
      return 'Hãy tiếp tục tập trung vào các thuật ngữ khó.';
    } else if (progressPercentage >= 0.5) {
      return 'Bạn đang tiến bộ tốt, hãy tiếp tục luyện tập.';
    } else {
      return 'Hãy dành thêm thời gian để học các thuật ngữ còn lại.';
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
