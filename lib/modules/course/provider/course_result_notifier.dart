import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/modules/course/model/course_data.dart';
import 'package:card_mind/data/models/course.dart';
import 'package:flutter/foundation.dart';
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
      _errorMessage = 'Không thể tải dữ liệu: $e';
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
      throw Exception('Không thể load khóa học: $e');
    }
  }

  Future<void> _loadCardLists(String courseId) async {
    try {
      // Load danh sách thẻ đã học
      _learnedCards = await DetailFlashCardNotifier.getLearnedCards(courseId);

      // Load danh sách thẻ chưa học
      _unlearnedCards = await DetailFlashCardNotifier.getUnlearnedCards(
        courseId,
      );

      // Cập nhật learnedCardIds từ danh sách đã học
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
