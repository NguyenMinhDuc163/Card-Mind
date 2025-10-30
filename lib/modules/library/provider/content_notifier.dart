import 'dart:async';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/event_service.dart';
import 'package:card_mind/modules/library/model/content_data.dart';

class ContentNotifier extends ChangeNotifier {
  List<ContentData> _contents = [];
  List<ContentData> _filteredContents = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  StreamSubscription<CourseEvent>? _courseEventSubscription;

  List<ContentData> get contents =>
      _searchQuery.isEmpty ? _contents : _filteredContents;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _loadContents();
      _errorMessage = null;

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
      if (event.type == CourseEventType.courseCreated ||
          event.type == CourseEventType.courseUpdated ||
          event.type == CourseEventType.courseDeleted) {
        _refreshData();
      }
    });
  }

  Future<void> _refreshData() async {
    try {
      await _loadContents();
      notifyListeners();
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  Future<void> _loadContents() async {
    try {
      final courseKeys =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];
      final List<ContentData> contentsList = [];

      for (final key in courseKeys) {
        final courseData = LocalStorageHelper.getValue(key as String);
        if (courseData != null) {
          final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
            courseData,
          );

          final contentData = ContentData(
            id: jsonData['id'] as String,
            title: jsonData['title'] as String,
            description: jsonData['description'] as String? ?? '',
            author: 'User',
            totalTerms: (jsonData['terms'] as List<dynamic>).length,
            createdAt: DateTime.parse(jsonData['createdAt'] as String),
            updatedAt: DateTime.parse(jsonData['updatedAt'] as String),
            category: jsonData['topic'] as String,
            isCompleted: false,
          );
          contentsList.add(contentData);
        }
      }

      // Sắp xếp theo thời gian tạo (mới nhất lên đầu)
      contentsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _contents = contentsList;
    } catch (e) {
      throw Exception('Không thể load nội dung: $e');
    }
  }

  void searchContents(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredContents = [];
    } else {
      _filteredContents =
          _contents.where((content) {
            return content.title.toLowerCase().contains(query.toLowerCase()) ||
                content.description.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                content.author.toLowerCase().contains(query.toLowerCase()) ||
                content.category.toLowerCase().contains(query.toLowerCase());
          }).toList();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _courseEventSubscription?.cancel();
    super.dispose();
  }
}
