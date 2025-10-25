import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/modules/course/model/course_data.dart';
import 'package:card_mind/data/models/course.dart';
import 'package:card_mind/data/models/flashcard.dart';
import 'package:flutter/foundation.dart';

class DetailFlashCardNotifier extends ChangeNotifier {
  CourseData? _courseData;
  Course? _course;
  List<Flashcard> _originalCards = []; // Danh sách gốc
  List<Flashcard> _learnedCards = []; // Đã học
  List<Flashcard> _unlearnedCards = []; // Chưa học
  Set<String> _learnedCardIds = {};
  Set<String> _bookmarkedCardIds = {}; // Các thẻ đã bookmark
  List<Flashcard> _bookmarkedCards = []; // Danh sách thẻ đã bookmark
  bool _isLoading = false;
  String? _errorMessage;
  String? _courseId;

  CourseData? get courseData => _courseData;

  Course? get course => _course;

  // Getter cho danh sách hiện tại đang hiển thị
  List<Flashcard> get currentCards => _originalCards;

  List<Flashcard> get learnedCards => _learnedCards;

  List<Flashcard> get unlearnedCards => _unlearnedCards;

  Set<String> get learnedCardIds => _learnedCardIds;

  Set<String> get bookmarkedCardIds => _bookmarkedCardIds;

  List<Flashcard> get bookmarkedCards => _bookmarkedCards;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  String? get courseId => _courseId;

  int get totalCards {
    return _originalCards.length +
        _learnedCards.length +
        _unlearnedCards.length;
  }

  int get learnedCount => _learnedCards.length;

  int get unlearnedCount => _unlearnedCards.length;

  int get remainingCount => _originalCards.length;

  Future<void> initializeData({String? courseId}) async {
    _courseId = courseId;
    _isLoading = true;
    notifyListeners();
    try {
      if (courseId != null) {
        // Luôn reset dữ liệu học tập khi vào màn hình học
        // Người dùng muốn học lại từ đầu mỗi lần vào
        _resetAllData();
        await _loadCourseFromHive(courseId);
        // Không load dữ liệu cũ nữa - mỗi lần vào học phần mới
        // await _loadLearnedCards();
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _resetAllData() {
    _originalCards = [];
    _learnedCards = [];
    _unlearnedCards = [];
    _learnedCardIds = <String>{};
    _bookmarkedCardIds = <String>{};
    _bookmarkedCards = [];
  }

  Future<void> _saveBookmarkedCards() async {
    try {
      final now = DateTime.now();
      final bookmarkedData = {
        'courseId': _courseData?.id,
        'courseTitle': _courseData?.title,
        'courseTopic': _courseData?.topic,
        'courseDescription': _courseData?.description,
        'cards':
            _bookmarkedCards
                .map(
                  (card) => {
                    'id': card.id,
                    'frontText': card.frontText,
                    'backText': card.backText,
                    'frontImage': card.frontImage,
                    'backImage': card.backImage,
                    'category': card.category,
                    'createdAt': card.createdAt.toIso8601String(),
                    'updatedAt': card.updatedAt.toIso8601String(),
                  },
                )
                .toList(),
        'lastUpdated': now.toIso8601String(),
      };
      LocalStorageHelper.setValue('bookmarked_cards', bookmarkedData);
    } catch (e) {
      print('Error saving bookmarked cards: $e');
    }
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
      throw Exception('Không thể load khóa học: $e');
    }
  }

  Future<void> _saveLearnedCards() async {
    try {
      LocalStorageHelper.setValue(
        'learned_cards_$_courseId',
        _learnedCardIds.toList(),
      );
    } catch (e) {}
  }

  void _convertToUICourse() {
    if (_courseData == null) return;

    _originalCards =
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
      flashcards: _originalCards,
      totalTerms: _originalCards.length,
      isVerified: true,
      author: 'User',
      createdAt: _courseData!.createdAt,
      updatedAt: _courseData!.updatedAt,
      category: _courseData!.topic,
    );
  }

  // Xử lý swipe sang phải (đã học)
  void onSwipeRight(Flashcard card) {
    // Xóa khỏi danh sách gốc
    _originalCards.removeWhere((c) => c.id == card.id);
    // Thêm vào danh sách đã học
    _learnedCards.add(card);
    // Cập nhật learnedCardIds
    _learnedCardIds.add(card.id);
    _saveLearnedCards();
    notifyListeners();
  }

  // Xử lý swipe sang trái (chưa học)
  void onSwipeLeft(Flashcard card) {
    // Xóa khỏi danh sách gốc
    _originalCards.removeWhere((c) => c.id == card.id);
    // Thêm vào danh sách chưa học
    _unlearnedCards.add(card);
    notifyListeners();
  }

  // Kiểm tra xem còn thẻ nào để học không
  bool get hasCardsToStudy => _originalCards.isNotEmpty;

  // Lấy thẻ hiện tại (thẻ đầu tiên trong danh sách gốc)
  Flashcard? get currentCard =>
      _originalCards.isNotEmpty ? _originalCards.first : null;

  // Revert thẻ cuối cùng được swipe
  void revertLastCard() {
    // Lấy thẻ cuối cùng từ learnedCards hoặc unlearnedCards
    if (_learnedCards.isNotEmpty) {
      final lastLearnedCard = _learnedCards.removeLast();
      _originalCards.insert(0, lastLearnedCard); // Thêm vào đầu danh sách
      _learnedCardIds.remove(lastLearnedCard.id);
      _saveLearnedCards();
    } else if (_unlearnedCards.isNotEmpty) {
      final lastUnlearnedCard = _unlearnedCards.removeLast();
      _originalCards.insert(0, lastUnlearnedCard); // Thêm vào đầu danh sách
    }

    notifyListeners();
  }

  // Lưu kết quả học tập khi hoàn thành
  Future<void> saveLearningResult() async {
    if (_courseData == null) return;

    try {
      final now = DateTime.now();
      final resultKey =
          'learning_result_${_courseData!.id}_${now.millisecondsSinceEpoch}';

      final result = {
        'courseId': _courseData!.id,
        'courseTitle': _courseData!.title,
        'courseTopic': _courseData!.topic,
        'courseDescription': _courseData!.description,
        'learnedCount': _learnedCards.length,
        'unlearnedCount': _unlearnedCards.length,
        'bookmarkedCount': _bookmarkedCards.length,
        'totalCards': totalCards,
        'progressPercentage': _learnedCards.length / totalCards,
        'completedAt': now.toIso8601String(),
        'learnedCards': _learnedCards.map((card) => card.id).toList(),
        'unlearnedCards': _unlearnedCards.map((card) => card.id).toList(),
        'bookmarkedCards': _bookmarkedCards.map((card) => card.id).toList(),
      };

      // Lưu kết quả học tập
      LocalStorageHelper.setValue(resultKey, result);

      // Lưu danh sách thẻ đã học cho khóa học này
      final learnedCardsKey = 'learned_cards_${_courseData!.id}';
      final learnedCardsData = {
        'courseId': _courseData!.id,
        'courseTitle': _courseData!.title,
        'cards':
            _learnedCards
                .map(
                  (card) => {
                    'id': card.id,
                    'frontText': card.frontText,
                    'backText': card.backText,
                    'frontImage': card.frontImage,
                    'backImage': card.backImage,
                    'category': card.category,
                    'createdAt': card.createdAt.toIso8601String(),
                    'updatedAt': card.updatedAt.toIso8601String(),
                  },
                )
                .toList(),
        'lastUpdated': now.toIso8601String(),
      };
      LocalStorageHelper.setValue(learnedCardsKey, learnedCardsData);

      // Lưu danh sách thẻ chưa học cho khóa học này
      final unlearnedCardsKey = 'unlearned_cards_${_courseData!.id}';
      final unlearnedCardsData = {
        'courseId': _courseData!.id,
        'courseTitle': _courseData!.title,
        'cards':
            _unlearnedCards
                .map(
                  (card) => {
                    'id': card.id,
                    'frontText': card.frontText,
                    'backText': card.backText,
                    'frontImage': card.frontImage,
                    'backImage': card.backImage,
                    'category': card.category,
                    'createdAt': card.createdAt.toIso8601String(),
                    'updatedAt': card.updatedAt.toIso8601String(),
                  },
                )
                .toList(),
        'lastUpdated': now.toIso8601String(),
      };
      LocalStorageHelper.setValue(unlearnedCardsKey, unlearnedCardsData);

      // Cập nhật danh sách tất cả kết quả
      final allResults =
          LocalStorageHelper.getValue('all_learning_results')
              as List<dynamic>? ??
          [];
      allResults.add(resultKey);
      LocalStorageHelper.setValue('all_learning_results', allResults);

      // Cập nhật danh sách khóa học có kết quả học tập
      final coursesWithResults =
          LocalStorageHelper.getValue('courses_with_results')
              as List<dynamic>? ??
          [];
      if (!coursesWithResults.contains(_courseData!.id)) {
        coursesWithResults.add(_courseData!.id);
        LocalStorageHelper.setValue('courses_with_results', coursesWithResults);
      }
    } catch (e) {
      print('Error saving learning result: $e');
    }
  }

  // Lấy danh sách thẻ đã học cho khóa học
  static Future<List<Map<String, dynamic>>> getLearnedCards(
    String courseId,
  ) async {
    try {
      final learnedCardsKey = 'learned_cards_$courseId';
      final data = LocalStorageHelper.getValue(learnedCardsKey);
      if (data != null) {
        final Map<String, dynamic> learnedData = Map<String, dynamic>.from(
          data as Map<dynamic, dynamic>,
        );
        return List<Map<String, dynamic>>.from(learnedData['cards'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting learned cards: $e');
      return [];
    }
  }

  // Lấy danh sách thẻ chưa học cho khóa học
  static Future<List<Map<String, dynamic>>> getUnlearnedCards(
    String courseId,
  ) async {
    try {
      if (courseId.isEmpty) {
        return [];
      }

      final unlearnedCardsKey = 'unlearned_cards_$courseId';
      final data = LocalStorageHelper.getValue(unlearnedCardsKey);

      if (data != null) {
        final Map<String, dynamic> unlearnedData = Map<String, dynamic>.from(
          data as Map<dynamic, dynamic>,
        );
        return List<Map<String, dynamic>>.from(unlearnedData['cards'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting unlearned cards: $e');
      return [];
    }
  }

  // Lấy tất cả khóa học có kết quả học tập
  static Future<List<String>> getCoursesWithResults() async {
    try {
      final courses =
          LocalStorageHelper.getValue('courses_with_results')
              as List<dynamic>? ??
          [];
      return courses.cast<String>();
    } catch (e) {
      print('Error getting courses with results: $e');
      return [];
    }
  }

  // Lấy danh sách thẻ đã bookmark
  static Future<List<Map<String, dynamic>>> getBookmarkedCards() async {
    try {
      final data = LocalStorageHelper.getValue('bookmarked_cards');
      if (data != null) {
        final Map<String, dynamic> bookmarkedData = Map<String, dynamic>.from(
          data as Map<dynamic, dynamic>,
        );
        return List<Map<String, dynamic>>.from(bookmarkedData['cards'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting bookmarked cards: $e');
      return [];
    }
  }

  // Lấy thông tin khóa học của các thẻ đã bookmark
  static Future<Map<String, dynamic>?> getBookmarkedCourseInfo() async {
    try {
      final data = LocalStorageHelper.getValue('bookmarked_cards');
      if (data != null) {
        final Map<String, dynamic> bookmarkedData = Map<String, dynamic>.from(
          data as Map<dynamic, dynamic>,
        );
        return {
          'courseId': bookmarkedData['courseId'],
          'courseTitle': bookmarkedData['courseTitle'],
          'courseTopic': bookmarkedData['courseTopic'],
          'courseDescription': bookmarkedData['courseDescription'],
          'lastUpdated': bookmarkedData['lastUpdated'],
        };
      }
      return null;
    } catch (e) {
      print('Error getting bookmarked course info: $e');
      return null;
    }
  }

  void markCardAsLearned(String cardId) {
    if (!_learnedCardIds.contains(cardId)) {
      _learnedCardIds.add(cardId);
      _saveLearnedCards();
      notifyListeners();
    }
  }

  void unmarkCardAsLearned(String cardId) {
    if (_learnedCardIds.contains(cardId)) {
      _learnedCardIds.remove(cardId);
      _saveLearnedCards();
      notifyListeners();
    }
  }

  bool isCardLearned(String cardId) {
    return _learnedCardIds.contains(cardId);
  }

  void toggleBookmark(Flashcard card) {
    final cardId = card.id;
    if (_bookmarkedCardIds.contains(cardId)) {
      _bookmarkedCardIds.remove(cardId);
      _bookmarkedCards.removeWhere((c) => c.id == cardId);
    } else {
      _bookmarkedCardIds.add(cardId);
      _bookmarkedCards.add(card);
    }
    _saveBookmarkedCards();
    notifyListeners();
  }

  bool isCardBookmarked(String cardId) {
    return _bookmarkedCardIds.contains(cardId);
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
