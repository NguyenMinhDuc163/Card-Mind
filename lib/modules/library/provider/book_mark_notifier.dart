import 'dart:async';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/services/spaced_repetition_service.dart';
import 'package:card_mind/modules/course/provider/detail_flash_card_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

class BookMarkNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> _unlearnedCardsByCourse = [];
  List<Map<String, dynamic>> _filteredUnlearnedCardsByCourse = [];
  List<Map<String, dynamic>> _bookmarkedCoursesByCourse = [];
  List<Map<String, dynamic>> _filteredBookmarkedCoursesByCourse = [];
  List<Map<String, dynamic>> _coursesNeedingReview = [];
  List<Map<String, dynamic>> _filteredCoursesNeedingReview = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  Timer? _autoRefreshTimer; 

  List<Map<String, dynamic>> get unlearnedCardsByCourse =>
      _searchQuery.isEmpty
          ? _unlearnedCardsByCourse
          : _filteredUnlearnedCardsByCourse;

  List<Map<String, dynamic>> get bookmarkedCoursesByCourse =>
      _searchQuery.isEmpty
          ? _bookmarkedCoursesByCourse
          : _filteredBookmarkedCoursesByCourse;

  List<Map<String, dynamic>> get coursesNeedingReview =>
      _searchQuery.isEmpty
          ? _coursesNeedingReview
          : _filteredCoursesNeedingReview;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _loadCoursesNeedingReview();
      await _loadUnlearnedCardsByCourse();
      await _loadBookmarkedCoursesByCourse();
      _errorMessage = null;
      _setupAutoRefreshTimer();
    } catch (e) {
      _errorMessage = tr('library.common.error_loading', args: [e.toString()]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  void _setupAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();

    
    final service = SpacedRepetitionService();
    final refreshIntervalSeconds = service.autoRefreshInterval;
    final refreshInterval = Duration(seconds: refreshIntervalSeconds);

    print(
      '🔄 BookMark Auto-refresh enabled: every $refreshIntervalSeconds seconds',
    );

    _autoRefreshTimer = Timer.periodic(refreshInterval, (timer) {
      print('⏰ Auto-refreshing bookmark data...');
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    try {
      await _loadCoursesNeedingReview();
      await _loadUnlearnedCardsByCourse();
      await _loadBookmarkedCoursesByCourse();
      notifyListeners();
    } catch (e) {
      print('Error refreshing bookmark data: $e');
    }
  }

  Future<void> _loadCoursesNeedingReview() async {
    try {
      final coursesWithReview =
          await SpacedRepetitionService().getCoursesWithCardsNeedingReview();

      final List<Map<String, dynamic>> reviewCoursesList = [];

      for (final entry in coursesWithReview.entries) {
        final courseId = entry.key;
        final reviewCount = entry.value;

        final courseData = await _getCourseData(courseId);

        if (courseData != null) {
          reviewCoursesList.add({
            'courseId': courseId,
            'courseTitle':
                courseData['title'] ?? tr('library.bookmark.no_title'),
            'courseDescription': courseData['description'] ?? '',
            'courseCategory': courseData['topic'] ?? '',
            'reviewCount': reviewCount,
            'lastUpdated':
                courseData['updatedAt'] ?? DateTime.now().toIso8601String(),
          });
        }
      }

      reviewCoursesList.sort(
        (a, b) => (b['reviewCount'] as int).compareTo(a['reviewCount'] as int),
      );

      _coursesNeedingReview = reviewCoursesList;
    } catch (e) {
      print('Error loading courses needing review: $e');
      _coursesNeedingReview = [];
    }
  }

  Future<void> _loadUnlearnedCardsByCourse() async {
    try {
      final coursesWithResults =
          await DetailFlashCardNotifier.getCoursesWithResults();

      final List<Map<String, dynamic>> unlearnedCardsList = [];

      for (final courseId in coursesWithResults) {
        final unlearnedCards = await DetailFlashCardNotifier.getUnlearnedCards(
          courseId,
        );

        if (unlearnedCards.isNotEmpty) {
          final courseData = await _getCourseData(courseId);

          if (courseData != null) {
            unlearnedCardsList.add({
              'courseId': courseId,
              'courseTitle':
                  courseData['title'] ?? tr('library.bookmark.no_title'),
              'courseDescription': courseData['description'] ?? '',
              'courseCategory': courseData['topic'] ?? '',
              'unlearnedCount': unlearnedCards.length,
              'unlearnedCards': unlearnedCards,
              'lastUpdated':
                  courseData['updatedAt'] ?? DateTime.now().toIso8601String(),
            });
          }
        }
      }

      unlearnedCardsList.sort(
        (a, b) =>
            (b['unlearnedCount'] as int).compareTo(a['unlearnedCount'] as int),
      );

      _unlearnedCardsByCourse = unlearnedCardsList;
    } catch (e) {
      throw Exception(
        tr('library.bookmark.error_load_unlearned', args: [e.toString()]),
      );
    }
  }

  Future<void> _loadBookmarkedCoursesByCourse() async {
    try {
      
      final allBookmarkedCourses =
          await DetailFlashCardNotifier.getAllBookmarkedCourses();

      _bookmarkedCoursesByCourse = allBookmarkedCourses;

      print(
        '📚 Loaded ${_bookmarkedCoursesByCourse.length} courses with bookmarks',
      );
      print('📚 Bookmarked courses data: $_bookmarkedCoursesByCourse');

      
      for (var course in _bookmarkedCoursesByCourse) {
        print(
          '  - Course ${course['courseId']}: ${course['courseTitle']} (${course['bookmarkedCount']} cards)',
        );
      }
    } catch (e) {
      print('Error loading bookmarked courses: $e');
      _bookmarkedCoursesByCourse = [];
    }
  }

  Future<Map<String, dynamic>?> _getCourseData(String courseId) async {
    try {
      final courseKeys =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];

      for (final key in courseKeys) {
        final courseData = LocalStorageHelper.getValue(key as String);
        if (courseData != null) {
          final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
            courseData as Map<dynamic, dynamic>,
          );
          if (jsonData['id'] == courseId) {
            return jsonData;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  int get totalUnlearnedCards {
    return _unlearnedCardsByCourse.fold(
      0,
      (sum, course) => sum + (course['unlearnedCount'] as int),
    );
  }

  int get coursesWithUnlearnedCards => _unlearnedCardsByCourse.length;

  int get totalReviewCards {
    return _coursesNeedingReview.fold(
      0,
      (sum, course) => sum + (course['reviewCount'] as int),
    );
  }

  int get coursesWithReviewCards => _coursesNeedingReview.length;

  void searchBookmarks(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredUnlearnedCardsByCourse = [];
      _filteredBookmarkedCoursesByCourse = [];
      _filteredCoursesNeedingReview = [];
    } else {
      _filteredUnlearnedCardsByCourse =
          _unlearnedCardsByCourse.where((courseData) {
            final courseTitle = courseData['courseTitle'] as String? ?? '';
            final courseDescription =
                courseData['courseDescription'] as String? ?? '';
            final courseCategory =
                courseData['courseCategory'] as String? ?? '';

            return courseTitle.toLowerCase().contains(query.toLowerCase()) ||
                courseDescription.toLowerCase().contains(query.toLowerCase()) ||
                courseCategory.toLowerCase().contains(query.toLowerCase());
          }).toList();

      _filteredBookmarkedCoursesByCourse =
          _bookmarkedCoursesByCourse.where((courseData) {
            final courseTitle = courseData['courseTitle'] as String? ?? '';
            final courseDescription =
                courseData['courseDescription'] as String? ?? '';
            final courseTopic = courseData['courseTopic'] as String? ?? '';

            return courseTitle.toLowerCase().contains(query.toLowerCase()) ||
                courseDescription.toLowerCase().contains(query.toLowerCase()) ||
                courseTopic.toLowerCase().contains(query.toLowerCase());
          }).toList();

      _filteredCoursesNeedingReview =
          _coursesNeedingReview.where((courseData) {
            final courseTitle = courseData['courseTitle'] as String? ?? '';
            final courseDescription =
                courseData['courseDescription'] as String? ?? '';
            final courseCategory =
                courseData['courseCategory'] as String? ?? '';

            return courseTitle.toLowerCase().contains(query.toLowerCase()) ||
                courseDescription.toLowerCase().contains(query.toLowerCase()) ||
                courseCategory.toLowerCase().contains(query.toLowerCase());
          }).toList();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
