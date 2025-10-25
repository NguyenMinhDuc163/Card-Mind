import 'dart:async';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/event_service.dart';
import 'package:card_mind/modules/home/model/home_data.dart';

class HomeNotifier extends ChangeNotifier {
  HomeData _homeData = const HomeData(courses: [], classes: []);
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<CourseEvent>? _courseEventSubscription;
  StreamSubscription<ClassEvent>? _classEventSubscription;

  HomeData get homeData => _homeData;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _loadCourses();
      await _loadClasses();
      _errorMessage = null;

      // Lắng nghe các event về khóa học và lớp học
      _setupCourseEventSubscription();
      _setupClassEventSubscription();
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupCourseEventSubscription() {
    _courseEventSubscription?.cancel();
    _courseEventSubscription = EventService().courseEvents.listen((event) {
      if (event.type == CourseEventType.courseCreated ||
          event.type == CourseEventType.courseUpdated ||
          event.type == CourseEventType.courseDeleted) {
        // Tự động refresh dữ liệu khi có khóa học mới được tạo, cập nhật hoặc bị xóa
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
        // Tự động refresh dữ liệu khi có lớp học mới được tạo, cập nhật hoặc bị xóa
        _refreshData();
      }
    });
  }

  Future<void> _refreshData() async {
    try {
      await _loadCourses();
      await _loadClasses();
      notifyListeners();
    } catch (e) {
      print('Error refreshing data: $e');
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

          final courseItem = CourseItem(
            id: jsonData['id'] as String,
            title: jsonData['title'] as String,
            description: jsonData['description'] as String? ?? '',
            totalTerms: (jsonData['terms'] as List<dynamic>).length,
            author:
                jsonData['topic'] as String? ??
                'Unknown', // Sử dụng topic thay vì author
          );

          coursesList.add(courseItem);
        }
      }

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
      throw Exception('Không thể load lớp học: $e');
    }
  }

  @override
  void dispose() {
    _courseEventSubscription?.cancel();
    _classEventSubscription?.cancel();
    super.dispose();
  }
}
