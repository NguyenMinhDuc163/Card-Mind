import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/modules/course/provider/detail_flash_card_notifier.dart';
import 'package:flutter/foundation.dart';

class BookMarkNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> _unlearnedCardsByCourse = [];
  List<Map<String, dynamic>> _filteredUnlearnedCardsByCourse = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Map<String, dynamic>> get unlearnedCardsByCourse =>
      _searchQuery.isEmpty
          ? _unlearnedCardsByCourse
          : _filteredUnlearnedCardsByCourse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _loadUnlearnedCardsByCourse();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUnlearnedCardsByCourse() async {
    try {
      // Lấy danh sách tất cả khóa học có kết quả học tập
      final coursesWithResults =
          await DetailFlashCardNotifier.getCoursesWithResults();

      final List<Map<String, dynamic>> unlearnedCardsList = [];

      for (final courseId in coursesWithResults) {
        // Lấy danh sách thẻ chưa học của khóa học này
        final unlearnedCards = await DetailFlashCardNotifier.getUnlearnedCards(
          courseId,
        );

        if (unlearnedCards.isNotEmpty) {
          // Lấy thông tin khóa học
          final courseData = await _getCourseData(courseId);

          if (courseData != null) {
            unlearnedCardsList.add({
              'courseId': courseId,
              'courseTitle': courseData['title'],
              'courseDescription': courseData['description'] ?? '',
              'courseCategory': courseData['topic'],
              'unlearnedCount': unlearnedCards.length,
              'unlearnedCards': unlearnedCards,
              'lastUpdated': courseData['updatedAt'],
            });
          }
        }
      }

      // Sắp xếp theo số lượng thẻ chưa học (nhiều nhất trước)
      unlearnedCardsList.sort(
        (a, b) =>
            (b['unlearnedCount'] as int).compareTo(a['unlearnedCount'] as int),
      );

      _unlearnedCardsByCourse = unlearnedCardsList;
    } catch (e) {
      throw Exception('Không thể load thẻ chưa học: $e');
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

  // Lấy tổng số thẻ chưa học
  int get totalUnlearnedCards {
    return _unlearnedCardsByCourse.fold(
      0,
      (sum, course) => sum + (course['unlearnedCount'] as int),
    );
  }

  // Lấy số khóa học có thẻ chưa học
  int get coursesWithUnlearnedCards => _unlearnedCardsByCourse.length;

  void searchBookmarks(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredUnlearnedCardsByCourse = [];
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
    }
    notifyListeners();
  }
}
