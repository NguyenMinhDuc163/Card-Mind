import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/event_service.dart';
import 'package:card_mind/core/services/data_sync_service.dart';
import 'package:card_mind/modules/create_course/model/create_course_data.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateCourseNotifier extends ChangeNotifier {
  CreateCourseData _courseData = CreateCourseData.createNew();
  bool _isLoading = false;
  String? _errorMessage;

  CreateCourseData get courseData => _courseData;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  Future<void> initializeData() async {
    _isLoading = true;
    try {
      _courseData = CreateCourseData.createNew();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = tr(
        'create_course.error_initialize',
        args: [e.toString()],
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> saveData() async {
    try {
      _courseData = _courseData.copyWith(updatedAt: DateTime.now());
      LocalStorageHelper.setValue('create_course_data', _courseData.toJson());
      _clearError();
    } catch (e) {
      _setError(tr('create_course.error_save', args: [e.toString()]));
    }
  }

  Future<void> completeCourse({String? author}) async {
    try {
      
      final validTerms =
          _courseData.terms.where((term) {
            final hasTerm = term.term.trim().isNotEmpty;
            final hasDefinition = term.definition.trim().isNotEmpty;
            
            return hasTerm && hasDefinition;
          }).toList();

      final courseKey = _generateCourseKey(
        _courseData.topic,
        _courseData.title,
      );
      print('Generated key: $courseKey');

      final now = DateTime.now();
      final newCourseData = _courseData.copyWith(
        id: now.millisecondsSinceEpoch.toString(),
        author:
            author ??
            _courseData
                .author, 
        terms: validTerms,
        createdAt: now,
        updatedAt: now,
      );

      LocalStorageHelper.setValue(courseKey, newCourseData.toJson());
      print('Saved course data with key: $courseKey');

      final existingKeys =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];
      final List<String> courseKeys = existingKeys.cast<String>();
      if (!courseKeys.contains(courseKey)) {
        courseKeys.add(courseKey);
        LocalStorageHelper.setValue('course_keys', courseKeys);
        print('Added key to course_keys list');
      }

      
      DataSyncService().syncCourse(newCourseData).catchError((error) {
        print('⚠️ [CreateCourseNotifier] Sync failed (will retry): $error');
        
      });

      _clearError();

      EventService().emitCourseEvent(
        CourseEvent(
          type: CourseEventType.courseCreated,
          courseId: newCourseData.id,
        ),
      );

      _courseData = CreateCourseData.createNew();
      print('Created new course data for next time');
      print('==================');
    } catch (e) {
      print('ERROR: $e');
      _setError(tr('create_course.error_complete', args: [e.toString()]));
    }
  }

  String _generateCourseKey(String topic, String title) {
    final cleanTopic =
        topic
            .replaceAll(RegExp(r'[^\w\s]'), '')
            .replaceAll(' ', '_')
            .toLowerCase();
    final cleanTitle =
        title
            .replaceAll(RegExp(r'[^\w\s]'), '')
            .replaceAll(' ', '_')
            .toLowerCase();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'course_${cleanTopic}_${cleanTitle}_$timestamp';
  }

  void updateCourseInfo({String? topic, String? title, String? description}) {
    _courseData = _courseData.copyWith(
      topic: topic ?? _courseData.topic,
      title: title ?? _courseData.title,
      description: description ?? _courseData.description,
    );
    notifyListeners();
  }

  void addTerm() {
    final newTerm = TermData.createNew();
    _courseData = _courseData.copyWith(terms: [..._courseData.terms, newTerm]);
    notifyListeners();
  }

  void addTermDirectly(TermData term) {
    _courseData = _courseData.copyWith(terms: [..._courseData.terms, term]);
    notifyListeners();
  }

  void updateTerm(int index, TermData term) {
    if (index >= 0 && index < _courseData.terms.length) {
      final updatedTerms = List<TermData>.from(_courseData.terms);
      updatedTerms[index] = term;
      _courseData = _courseData.copyWith(terms: updatedTerms);
      notifyListeners();
    }
  }

  void removeTerm(int index) {
    if (index >= 0 && index < _courseData.terms.length) {
      final updatedTerms = List<TermData>.from(_courseData.terms);
      updatedTerms.removeAt(index);
      _courseData = _courseData.copyWith(terms: updatedTerms);
      notifyListeners();
    }
  }

  void clearData() {
    _courseData = CreateCourseData.createNew();
    LocalStorageHelper.deleteValue('create_course_data');
    _clearError();
    notifyListeners();
  }

  bool get isDataValid {
    if (_courseData.topic.isEmpty || _courseData.title.isEmpty) {
      return false;
    }

    final validTerms =
        _courseData.terms
            .where(
              (term) =>
                  term.term.trim().isNotEmpty ||
                  term.definition.trim().isNotEmpty,
            )
            .toList();

    if (validTerms.isEmpty) {
      return false;
    }

    for (final term in _courseData.terms) {
      final hasTerm = term.term.trim().isNotEmpty;
      final hasDefinition = term.definition.trim().isNotEmpty;

      if (!hasTerm && !hasDefinition) {
        continue;
      }

      if ((hasTerm && !hasDefinition) || (!hasTerm && hasDefinition)) {
        return false;
      }
    }

    return true;
  }

  int get termsCount => _courseData.terms.length;

  List<TermData> get completedTerms =>
      _courseData.terms
          .where((term) => term.term.isNotEmpty && term.definition.isNotEmpty)
          .toList();

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
