import 'dart:async';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/services/spaced_repetition_service.dart';
import 'package:card_mind/modules/course/model/course_data.dart';
import 'package:card_mind/data/models/course.dart';
import 'package:card_mind/data/models/flashcard.dart';
import 'package:card_mind/core/event_service.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';

class CourseInfoNotifier extends ChangeNotifier {
  CourseData? _courseData;
  Course? _course;
  List<Flashcard> _flashcards = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentCourseId;
  int _reviewCardsCount = 0;

  CourseData? get courseData => _courseData;

  Course? get course => _course;

  List<Flashcard> get flashcards => _flashcards;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  int get reviewCardsCount => _reviewCardsCount;

  StreamSubscription<CourseEvent>? _eventSubscription;
  StreamSubscription<ReviewEvent>? _reviewEventSubscription;

  Future<void> initializeData({String? courseId}) async {
    _isLoading = true;
    _currentCourseId = courseId;
    notifyListeners();
    try {
      if (courseId != null) {
        await _loadCourseFromHive(courseId);
        await _loadReviewCardsCount(courseId);
        _setupEventListeners();
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = tr('course_info.error_loading', args: [e.toString()]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupEventListeners() {
    _eventSubscription?.cancel();
    _eventSubscription = EventService().courseEvents.listen((event) {
      if (event.type == CourseEventType.courseUpdated &&
          event.courseId == _currentCourseId) {
        _loadCourseFromHive(_currentCourseId!);
        notifyListeners();
      }
    });

    _reviewEventSubscription?.cancel();
    _reviewEventSubscription = EventService().reviewEvents.listen((event) {
      if (event.courseId == _currentCourseId) {
        // Refresh số lượng thẻ cần ôn tập khi có thay đổi
        _loadReviewCardsCount(_currentCourseId!);
      }
    });
  }

  Future<void> _loadReviewCardsCount(String courseId) async {
    try {
      final cardsNeedingReview = await SpacedRepetitionService()
          .getCardsNeedingReview(courseId);
      _reviewCardsCount = cardsNeedingReview.length;

      // Log thông tin repetitions của từng card trong course
      await _printCourseRepetitionsInfo(courseId);

      notifyListeners();
    } catch (e) {
      print('❌ Error loading review cards count: $e');
      _reviewCardsCount = 0;
    }
  }

  Future<void> _printCourseRepetitionsInfo(String courseId) async {
    try {
      final service = SpacedRepetitionService();
      final allReviewData = await service.getCourseReviewData(courseId);

      if (allReviewData.isEmpty) {
        print('\n📚 [Course Info] Khóa học này chưa có dữ liệu ôn tập');
        return;
      }

      print('\n📚 ============================================');
      print('📚 [Course Info] Thông tin ôn tập - Course: $courseId');
      print('📚 ============================================');

      for (var reviewData in allReviewData) {
        final card = _flashcards.firstWhere(
          (c) => c.id == reviewData.cardId,
          orElse:
              () => Flashcard(
                id: reviewData.cardId,
                frontText: 'Unknown',
                backText: '',
                category: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
        );

        final needsReview = reviewData.needsReview();
        final status = needsReview ? '⏰ CẦN ÔN TẬP' : '✅ Chưa đến lúc';

        print('📝 Card: "${card.frontText}"');
        print('   - Số lần ôn tập: ${reviewData.repetitions} lần');
        print(
          '   - Interval hiện tại: ${reviewData.intervalDays} ${service.timeUnitVi}',
        );
        print(
          '   - Lần ôn cuối: ${_formatDateTime(reviewData.lastReviewDate)}',
        );
        print(
          '   - Lần ôn tiếp theo: ${_formatDateTime(reviewData.nextReviewDate)}',
        );
        print('   - Trạng thái: $status');
        print('   - Ease factor: ${reviewData.easeFactor.toStringAsFixed(2)}');
        print('');
      }

      print(
        '📚 Tổng số thẻ đã học: ${allReviewData.length}/${_flashcards.length}',
      );
      print('📚 Số thẻ cần ôn tập: $_reviewCardsCount');
      print('📚 ============================================\n');
    } catch (e) {
      print('❌ Error printing course repetitions info: $e');
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _reviewEventSubscription?.cancel();
    super.dispose();
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
        tr('course_info.error_loading_course', args: [e.toString()]),
      );
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

  Future<bool> deleteCourse(String courseId) async {
    try {
      final courseKeys =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];
      String? actualCourseKey;

      for (final key in courseKeys) {
        final courseData = LocalStorageHelper.getValue(key as String);
        if (courseData != null) {
          final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
            courseData,
          );
          if (jsonData['id'] == courseId) {
            actualCourseKey = key.toString();
            break;
          }
        }
      }

      if (actualCourseKey == null) {
        return false;
      }

      await LocalStorageHelper.removeValue(actualCourseKey);

      final List<String> updatedKeys = courseKeys.cast<String>();
      updatedKeys.remove(actualCourseKey);
      LocalStorageHelper.setValue('course_keys', updatedKeys);

      await LocalStorageHelper.removeValue('learned_cards_$courseId');
      await LocalStorageHelper.removeValue('unlearned_cards_$courseId');

      final coursesWithResults =
          LocalStorageHelper.getValue('courses_with_results')
              as List<dynamic>? ??
          [];
      final List<String> updatedResults = coursesWithResults.cast<String>();
      updatedResults.remove(courseId);
      LocalStorageHelper.setValue('courses_with_results', updatedResults);

      final allResults =
          LocalStorageHelper.getValue('all_learning_results')
              as List<dynamic>? ??
          [];
      final List<String> updatedAllResults = allResults.cast<String>();
      updatedAllResults.removeWhere(
        (key) => key.contains('learning_result_${courseId}_'),
      );
      LocalStorageHelper.setValue('all_learning_results', updatedAllResults);

      EventService().emitCourseEvent(
        CourseEvent(type: CourseEventType.courseDeleted, courseId: courseId),
      );

      return true;
    } catch (e) {
      print('Error deleting course: $e');
      return false;
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
