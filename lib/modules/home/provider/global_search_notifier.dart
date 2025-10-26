import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/modules/course/provider/detail_flash_card_notifier.dart';
import 'package:flutter/foundation.dart';

class GlobalSearchNotifier extends ChangeNotifier {
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<SearchResult> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  String get searchQuery => _searchQuery;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _searchQuery = query;
    notifyListeners();

    try {
      final results = await _performGlobalSearch(query);
      _searchResults = results;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tìm kiếm: $e';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<SearchResult>> _performGlobalSearch(String query) async {
    final List<SearchResult> results = [];

    
    await _searchCourses(query, results);

    
    await _searchClasses(query, results);

    
    await _searchBookmarks(query, results);

    
    results.sort(
      (a, b) => _calculateRelevance(
        b,
        query,
      ).compareTo(_calculateRelevance(a, query)),
    );

    return results;
  }

  Future<void> _searchCourses(String query, List<SearchResult> results) async {
    try {
      final courseKeys =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];

      for (final key in courseKeys) {
        final courseData = LocalStorageHelper.getValue(key as String);
        if (courseData != null) {
          final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
            courseData,
          );

          final title = jsonData['title'] as String;
          final description = jsonData['description'] as String? ?? '';
          final topic = jsonData['topic'] as String;
          final totalTerms = (jsonData['terms'] as List<dynamic>).length;

          if (_matchesQuery(query, [title, description, topic])) {
            results.add(
              SearchResult(
                id: jsonData['id'] as String,
                type: SearchResultType.course,
                title: title,
                subtitle: '$totalTerms thuật ngữ • Tác giả: User',
                description: description,
                category: topic,
                icon: Icons.school,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error searching courses: $e');
    }
  }

  Future<void> _searchClasses(String query, List<SearchResult> results) async {
    try {
      final classesData =
          LocalStorageHelper.getValue('library_classes') as List<dynamic>?;

      if (classesData != null) {
        for (final classJson in classesData) {
          final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(
            classJson,
          );

          final className = jsonMap['className'] as String;
          final description = jsonMap['description'] as String;
          final instructor = jsonMap['instructor'] as String;
          final totalStudents = jsonMap['totalStudents'] as int;

          if (_matchesQuery(query, [className, description, instructor])) {
            results.add(
              SearchResult(
                id: jsonMap['id'] as String,
                type: SearchResultType.classroom,
                title: className,
                subtitle: '$totalStudents học sinh • Giảng viên: $instructor',
                description: description,
                category: 'Chủ đề',
                icon: Icons.class_,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error searching classes: $e');
    }
  }

  Future<void> _searchBookmarks(
    String query,
    List<SearchResult> results,
  ) async {
    try {
      
      final coursesWithResults =
          await DetailFlashCardNotifier.getCoursesWithResults();

      for (final courseId in coursesWithResults) {
        final unlearnedCards = await DetailFlashCardNotifier.getUnlearnedCards(
          courseId,
        );

        if (unlearnedCards.isNotEmpty) {
          final courseData = await _getCourseData(courseId);

          if (courseData != null) {
            final courseTitle = courseData['title'] as String;
            final courseDescription =
                courseData['description'] as String? ?? '';
            final courseCategory = courseData['topic'] as String;

            if (_matchesQuery(query, [
              courseTitle,
              courseDescription,
              courseCategory,
            ])) {
              results.add(
                SearchResult(
                  id: courseId,
                  type: SearchResultType.bookmark,
                  title: courseTitle,
                  subtitle: '${unlearnedCards.length} thẻ chưa học',
                  description: courseDescription,
                  category: courseCategory,
                  icon: Icons.bookmark_border,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error searching bookmarks: $e');
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
            courseData,
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

  bool _matchesQuery(String query, List<String> fields) {
    final lowerQuery = query.toLowerCase();
    return fields.any((field) => field.toLowerCase().contains(lowerQuery));
  }

  double _calculateRelevance(SearchResult result, String query) {
    final lowerQuery = query.toLowerCase();
    double score = 0.0;

    
    if (result.title.toLowerCase().contains(lowerQuery)) {
      score += 10.0;
    }

    
    if (result.description.toLowerCase().contains(lowerQuery)) {
      score += 5.0;
    }

    
    if (result.category.toLowerCase().contains(lowerQuery)) {
      score += 3.0;
    }

    
    if (result.subtitle.toLowerCase().contains(lowerQuery)) {
      score += 2.0;
    }

    return score;
  }

  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    _errorMessage = null;
    notifyListeners();
  }
}

enum SearchResultType { course, classroom, bookmark }

class SearchResult {
  final String id;
  final SearchResultType type;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final IconData icon;

  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.icon,
  });
}
