import 'dart:async';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/event_service.dart';
import 'package:card_mind/core/services/spaced_repetition_service.dart';
import 'package:card_mind/modules/home/model/home_data.dart';

class HomeNotifier extends ChangeNotifier {
  HomeData _homeData = const HomeData(courses: [], classes: []);
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<CourseEvent>? _courseEventSubscription;
  StreamSubscription<ClassEvent>? _classEventSubscription;
  StreamSubscription<ReviewEvent>? _reviewEventSubscription;
  Timer? _autoRefreshTimer; // Timer để tự động refresh
  Map<String, int> _coursesNeedingReview = {}; // courseId -> số lượng thẻ cần ôn

  HomeData get homeData => _homeData;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  /// Lấy danh sách courses cần ôn tập (có ít nhất 1 thẻ cần ôn)
  List<CourseItem> get coursesNeedingReview {
    return _homeData.courses
        .where((course) => course.reviewCardsCount > 0)
        .toList();
  }

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _loadCoursesNeedingReview();
      await _loadCourses();
      await _loadClasses();
      _errorMessage = null;

      _setupCourseEventSubscription();
      _setupClassEventSubscription();
      _setupReviewEventSubscription();
      _setupAutoRefreshTimer();
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Setup timer để tự động refresh data theo chu kỳ
  void _setupAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();

    // Lấy autoRefreshInterval từ SpacedRepetitionService config
    final service = SpacedRepetitionService();
    final refreshIntervalSeconds = service.autoRefreshInterval;
    final refreshInterval = Duration(seconds: refreshIntervalSeconds);

    print('🔄 Home Auto-refresh enabled: every $refreshIntervalSeconds seconds');

    _autoRefreshTimer = Timer.periodic(refreshInterval, (timer) {
      print('⏰ Auto-refreshing courses needing review...');
      _refreshData();
    });
  }

  void _setupCourseEventSubscription() {
    _courseEventSubscription?.cancel();
    _courseEventSubscription = EventService().courseEvents.listen((event) {
      if (event.type == CourseEventType.courseCreated ||
          event.type == CourseEventType.courseUpdated ||
          event.type == CourseEventType.courseDeleted) {
        _refreshData();
      }
    });
  }

  void _setupClassEventSubscription() {
    _classEventSubscription?.cancel();
    _classEventSubscription = EventService().classEvents.listen((event) {
      if (event.type == ClassEventType.classCreated ||
          event.type == ClassEventType.classUpdated ||
          event.type == ClassEventType.classDeleted) {
        _refreshData();
      }
    });
  }

  void _setupReviewEventSubscription() {
    _reviewEventSubscription?.cancel();
    _reviewEventSubscription = EventService().reviewEvents.listen((event) {
      if (event.type == ReviewEventType.reviewUpdated ||
          event.type == ReviewEventType.reviewCompleted) {
        // Refresh lại danh sách courses cần ôn tập
        _refreshData();
      }
    });
  }

  Future<void> _refreshData() async {
    try {
      await _loadCoursesNeedingReview();
      await _loadCourses();
      await _loadClasses();
      notifyListeners();
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  Future<void> _loadCoursesNeedingReview() async {
    try {
      _coursesNeedingReview =
          await SpacedRepetitionService().getCoursesWithCardsNeedingReview();
      print('📚 Loaded courses needing review: $_coursesNeedingReview');
    } catch (e) {
      print('Error loading courses needing review: $e');
      _coursesNeedingReview = {};
    }
  }

  Future<void> _loadCourses() async {
    try {
      final courseKeys =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];
      final List<CourseItem> coursesList = [];

      for (final key in courseKeys) {
        final courseData = LocalStorageHelper.getValue(key as String);
        if (courseData != null) {
          final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
            courseData,
          );

          final courseId = jsonData['id'] as String;
          final reviewCardsCount = _coursesNeedingReview[courseId] ?? 0;

          final courseItem = CourseItem(
            id: courseId,
            title: jsonData['title'] as String,
            description: jsonData['description'] as String? ?? '',
            totalTerms: (jsonData['terms'] as List<dynamic>).length,
            author: jsonData['topic'] as String? ?? 'Unknown',
            reviewCardsCount: reviewCardsCount,
          );

          coursesList.add(courseItem);
        }
      }

      // Sắp xếp theo ID (mới nhất lên đầu - vì ID = timestamp)
      coursesList.sort((a, b) {
        final idA = int.tryParse(a.id) ?? 0;
        final idB = int.tryParse(b.id) ?? 0;
        return idB.compareTo(idA); // Giảm dần (mới nhất trước)
      });

      _homeData = _homeData.copyWith(courses: coursesList);
    } catch (e) {
      throw Exception('Không thể load khóa học: $e');
    }
  }

  Future<void> _loadClasses() async {
    try {
      final classesData =
          LocalStorageHelper.getValue('library_classes') as List<dynamic>?;
      final List<ClassItem> classesList = [];

      if (classesData != null) {
        for (final classJson in classesData) {
          final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(
            classJson,
          );

          final classItem = ClassItem(
            id: jsonMap['id'] as String,
            className: jsonMap['className'] as String,
            description: jsonMap['description'] as String,
            instructor: jsonMap['instructor'] as String,
            totalStudents: jsonMap['totalStudents'] as int,
            status: jsonMap['status'] as String,
          );

          classesList.add(classItem);
        }
      }

      _homeData = _homeData.copyWith(classes: classesList);
    } catch (e) {
      throw Exception('Không thể load Chủ đề học: $e');
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    try {
      print('🗑️ Deleting course: $courseId');

      // Tìm course key từ courseId
      final courseKeys =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];
      String? courseKey;

      for (final key in courseKeys) {
        final courseData = LocalStorageHelper.getValue(key as String);
        if (courseData != null) {
          final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
            courseData,
          );
          if (jsonData['id'] == courseId) {
            courseKey = key;
            break;
          }
        }
      }

      if (courseKey == null) {
        print('❌ Course key not found for courseId: $courseId');
        return false;
      }

      // Xóa course data từ Hive
      LocalStorageHelper.deleteValue(courseKey);

      // Xóa course key khỏi danh sách
      courseKeys.remove(courseKey);
      LocalStorageHelper.setValue('course_keys', courseKeys);

      // Xóa các dữ liệu liên quan (learning results, bookmarks, etc.)
      await _deleteRelatedCourseData(courseId);

      // Refresh data
      await _refreshData();

      // Emit event
      EventService().emitCourseEvent(
        CourseEvent(type: CourseEventType.courseDeleted, courseId: courseId),
      );

      print('✅ Successfully deleted course: $courseId');
      return true;
    } catch (e) {
      print('❌ Error deleting course: $e');
      return false;
    }
  }

  Future<void> _deleteRelatedCourseData(String courseId) async {
    try {
      // Xóa learning results
      final allResults =
          LocalStorageHelper.getValue('all_learning_results')
              as List<dynamic>? ??
          [];
      final courseResults =
          allResults
              .where(
                (resultKey) => resultKey.toString().contains(
                  'learning_result_${courseId}_',
                ),
              )
              .toList();

      for (final resultKey in courseResults) {
        LocalStorageHelper.deleteValue(resultKey.toString());
      }

      // Cập nhật danh sách all_learning_results
      allResults.removeWhere(
        (resultKey) =>
            resultKey.toString().contains('learning_result_${courseId}_'),
      );
      LocalStorageHelper.setValue('all_learning_results', allResults);

      // Xóa khỏi courses_with_results
      final coursesWithResults =
          LocalStorageHelper.getValue('courses_with_results')
              as List<dynamic>? ??
          [];
      coursesWithResults.removeWhere((id) => id == courseId);
      LocalStorageHelper.setValue('courses_with_results', coursesWithResults);

      // Xóa learned/unlearned cards
      LocalStorageHelper.deleteValue('learned_cards_$courseId');
      LocalStorageHelper.deleteValue('unlearned_cards_$courseId');

      print('✅ Deleted related data for course: $courseId');
    } catch (e) {
      print('❌ Error deleting related course data: $e');
    }
  }

  Future<bool> deleteClass(String classId) async {
    try {
      print('🗑️ Deleting class: $classId');

      // Lấy danh sách classes
      final classesData =
          LocalStorageHelper.getValue('library_classes') as List<dynamic>? ??
          [];

      // Tìm và xóa class
      final updatedClasses =
          classesData.where((classJson) {
            final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(
              classJson,
            );
            return jsonMap['id'] != classId;
          }).toList();

      // Cập nhật danh sách classes
      LocalStorageHelper.setValue('library_classes', updatedClasses);

      // Refresh data
      await _refreshData();

      // Emit event
      EventService().emitClassEvent(
        ClassEvent(type: ClassEventType.classDeleted, classId: classId),
      );

      print('✅ Successfully deleted class: $classId');
      return true;
    } catch (e) {
      print('❌ Error deleting class: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _courseEventSubscription?.cancel();
    _classEventSubscription?.cancel();
    _reviewEventSubscription?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
