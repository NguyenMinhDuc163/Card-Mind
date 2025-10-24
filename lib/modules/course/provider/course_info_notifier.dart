import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/modules/course/model/course_data.dart';
import 'package:card_mind/data/models/course.dart';
import 'package:card_mind/data/models/flashcard.dart';
import 'package:flutter/foundation.dart';

class CourseInfoNotifier extends ChangeNotifier {
  CourseData? _courseData;
  Course? _course;
  List<Flashcard> _flashcards = [];
  bool _isLoading = false;
  String? _errorMessage;

  CourseData? get courseData => _courseData;

  Course? get course => _course;

  List<Flashcard> get flashcards => _flashcards;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  Future<void> initializeData({String? courseId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (courseId != null) {
        await _loadCourseFromHive(courseId);
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
