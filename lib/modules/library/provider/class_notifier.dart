import 'dart:async';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/event_service.dart';
import 'package:card_mind/modules/library/model/class_data.dart';
import 'package:card_mind/modules/library/model/content_data.dart';
import 'package:easy_localization/easy_localization.dart';

class ClassNotifier extends ChangeNotifier {
  List<ClassData> _classes = [];
  List<ClassData> _filteredClasses = [];
  List<ContentData> _availableContents = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  StreamSubscription<CourseEvent>? _courseEventSubscription;

  List<ClassData> get classes =>
      _searchQuery.isEmpty ? _classes : _filteredClasses;

  List<ContentData> get availableContents => _availableContents;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _loadClasses();
      await _loadAvailableContents();
      _errorMessage = null;

      _setupCourseEventSubscription();
    } catch (e) {
      _errorMessage = tr('library.common.error_loading', args: [e.toString()]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupCourseEventSubscription() {
    _courseEventSubscription?.cancel();
    _courseEventSubscription = EventService().courseEvents.listen((event) {
      if (event.type == CourseEventType.courseCreated) {
        _refreshData();
      }
    });
  }

  Future<void> _refreshData() async {
    try {
      await _loadClasses();
      await _loadAvailableContents();
      notifyListeners();
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  Future<void> _loadClasses() async {
    try {
      final classesData =
          LocalStorageHelper.getValue('library_classes') as List<dynamic>?;

      if (classesData == null) {
        print('DEBUG: No classes data found, initializing empty list');
        _classes = [];
        return;
      }

      print('DEBUG: classesData type: ${classesData.runtimeType}');
      print('DEBUG: classesData length: ${classesData.length}');

      _classes =
          classesData.map((json) {
            print('DEBUG: json type: ${json.runtimeType}');
            print('DEBUG: json content: $json');

            final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(
              json,
            );
            return ClassData.fromJson(jsonMap);
          }).toList();

      print('DEBUG: _classes length: ${_classes.length}');
    } catch (e) {
      print('DEBUG: Error in _loadClasses: $e');
      throw Exception(
        tr('library.class_screen.error_load_classes', args: [e.toString()]),
      );
    }
  }

  Future<void> _loadAvailableContents() async {
    try {
      final courseKeys =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>?;

      if (courseKeys == null) {
        print('DEBUG: No course keys found, initializing empty list');
        _availableContents = [];
        return;
      }

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

      _availableContents = contentsList;
    } catch (e) {
      throw Exception(
        tr('library.class_screen.error_load_contents', args: [e.toString()]),
      );
    }
  }

  Future<void> saveClass(ClassData classData) async {
    try {
      final existingIndex = _classes.indexWhere((c) => c.id == classData.id);
      final bool isNewClass = existingIndex < 0;

      if (existingIndex >= 0) {
        _classes[existingIndex] = classData;
      } else {
        _classes.add(classData);
      }

      await _saveClassesToStorage();
      notifyListeners();

      EventService().emitClassEvent(
        ClassEvent(
          type:
              isNewClass
                  ? ClassEventType.classCreated
                  : ClassEventType.classUpdated,
          classId: classData.id,
        ),
      );
    } catch (e) {
      _setError(
        tr('library.class_screen.error_save_class', args: [e.toString()]),
      );
    }
  }

  Future<void> _saveClassesToStorage() async {
    final classesJson =
        _classes.map((classData) => classData.toJson()).toList();
    LocalStorageHelper.setValue('library_classes', classesJson);
  }

  Future<void> deleteClass(String classId) async {
    try {
      _classes.removeWhere((classData) => classData.id == classId);
      await _saveClassesToStorage();
      notifyListeners();

      EventService().emitClassEvent(
        ClassEvent(type: ClassEventType.classDeleted, classId: classId),
      );
    } catch (e) {
      _setError(
        tr('library.class_screen.error_delete_class', args: [e.toString()]),
      );
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void searchClasses(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredClasses = [];
    } else {
      _filteredClasses =
          _classes.where((classData) {
            return classData.className.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                classData.description.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                classData.instructor.toLowerCase().contains(
                  query.toLowerCase(),
                );
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
