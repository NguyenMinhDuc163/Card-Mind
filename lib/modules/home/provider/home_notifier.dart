import 'dart:async';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/event_service.dart';
import 'package:card_mind/modules/home/model/home_data.dart';

class HomeNotifier extends ChangeNotifier {
  HomeData _homeData = const HomeData(courses: []);
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<CourseEvent>? _courseEventSubscription;

  HomeData get homeData => _homeData;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _loadCourses();
      _errorMessage = null;

      // Lắng nghe các event về khóa học
      _setupCourseEventSubscription();
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
      if (event.type == CourseEventType.courseCreated) {
        // Tự động refresh dữ liệu khi có khóa học mới được tạo
        _refreshData();
      }
    });
  }

  Future<void> _refreshData() async {
    try {
      await _loadCourses();
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
            author: jsonData['author'] as String? ?? 'Unknown',
          );
          coursesList.add(courseItem);
        }
      }

      _homeData = _homeData.copyWith(courses: coursesList);
    } catch (e) {
      throw Exception('Không thể load khóa học: $e');
    }
  }

  @override
  void dispose() {
    _courseEventSubscription?.cancel();
    super.dispose();
  }
}
