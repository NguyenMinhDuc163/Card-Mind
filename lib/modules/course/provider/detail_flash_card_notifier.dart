import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/modules/course/model/course_data.dart';
import 'package:card_mind/data/models/course.dart';
import 'package:card_mind/data/models/flashcard.dart';
import 'package:flutter/foundation.dart';

enum LearningMode {
  fullCourse, // Học tất cả thẻ trong khóa học
  bookmarked, // Chỉ học thẻ đã bookmark
  unlearned, // Chỉ học thẻ chưa thuộc
}

class DetailFlashCardNotifier extends ChangeNotifier {
  CourseData? _courseData;
  Course? _course;
  List<Flashcard> _originalCards = [];
  List<Flashcard> _learnedCards = [];
  List<Flashcard> _unlearnedCards = [];
  Set<String> _learnedCardIds = {};
  Set<String> _bookmarkedCardIds = {};
  List<Flashcard> _bookmarkedCards = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _courseId;
  int _currentCardIndex = 0; // Track thẻ hiện tại đang hiển thị
  LearningMode _learningMode = LearningMode.fullCourse; // Chế độ học tập

  CourseData? get courseData => _courseData;

  Course? get course => _course;

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

  bool get hasExistingLearningData {
    if (_courseData == null) {
      print('🔍 hasExistingLearningData: courseData is null');
      return false;
    }

    final learnedCardsKey = 'learned_cards_${_courseData!.id}';
    final learnedData = LocalStorageHelper.getValue(learnedCardsKey);

    print(
      '🔍 hasExistingLearningData: courseId=${_courseData!.id}, key=$learnedCardsKey, data=$learnedData',
    );

    return learnedData != null;
  }

  int get totalCards {
    // Tổng số thẻ cố định = số thẻ trong list A
    return _originalCards.length;
  }

  int get learnedCount => _learnedCards.length;

  int get unlearnedCount => _unlearnedCards.length;

  int get remainingCount => _originalCards.length;

  int get currentCardIndex => _currentCardIndex;

  LearningMode get learningMode => _learningMode;

  Future<void> initializeData({
    String? courseId,
    bool resetLearningData = false,
    LearningMode learningMode = LearningMode.fullCourse,
  }) async {
    _courseId = courseId;
    _learningMode = learningMode;
    _isLoading = true;
    notifyListeners();
    try {
      if (courseId != null) {
        _resetAllData();
        await _loadCourseFromHive(courseId);
        await _filterCardsByLearningMode(courseId);

        // B và C luôn bắt đầu rỗng, không load từ Hive
        // Chỉ load khi hoàn thành khóa học
        print('🔄 Initialized with learning mode: ${_learningMode.name}');
        print('🔄 Cards after filtering: ${_originalCards.length}');

        await Future.delayed(const Duration(milliseconds: 100));
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
    _currentCardIndex = 0; // Reset về thẻ đầu tiên
  }

  // Xóa method _clearLearningData vì không cần thiết nữa
  // B và C luôn bắt đầu rỗng

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

  // Xóa các method _saveLearnedCards và _saveUnlearnedCards
  // Vì B và C chỉ lưu khi hoàn thành khóa học

  // Xóa method _loadExistingLearningData vì không cần load từ Hive nữa
  // B và C luôn bắt đầu rỗng

  Future<void> _filterCardsByLearningMode(String courseId) async {
    try {
      switch (_learningMode) {
        case LearningMode.fullCourse:
          // Giữ nguyên tất cả thẻ
          print(
            '📚 Learning mode: Full course - ${_originalCards.length} cards',
          );
          break;

        case LearningMode.bookmarked:
          // Chỉ giữ thẻ đã bookmark
          final bookmarkedCards = await getBookmarkedCards();
          final bookmarkedIds =
              bookmarkedCards.map((card) => card['id'] as String).toSet();
          _originalCards =
              _originalCards
                  .where((card) => bookmarkedIds.contains(card.id))
                  .toList();
          print(
            '📚 Learning mode: Bookmarked - ${_originalCards.length} cards',
          );
          break;

        case LearningMode.unlearned:
          // Chỉ giữ thẻ chưa thuộc
          final unlearnedCards = await getUnlearnedCards(courseId);
          final unlearnedIds =
              unlearnedCards.map((card) => card['id'] as String).toSet();
          _originalCards =
              _originalCards
                  .where((card) => unlearnedIds.contains(card.id))
                  .toList();
          print('📚 Learning mode: Unlearned - ${_originalCards.length} cards');
          break;
      }
    } catch (e) {
      print('❌ Error filtering cards by learning mode: $e');
    }
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

    print('🔄 Converted ${_courseData!.terms.length} terms to flashcards');
    print('🔄 All cards created:');
    for (int i = 0; i < _originalCards.length; i++) {
      print(
        '  ${i + 1}. ${_originalCards[i].frontText} (ID: ${_originalCards[i].id})',
      );
    }
    print('🔄 Starting at index: $_currentCardIndex');

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

  void onSwipeRight(Flashcard card) {
    // Thêm vào list B (learned) - tạm thời, không lưu Hive
    if (!_learnedCardIds.contains(card.id)) {
      _learnedCards.add(card);
      _learnedCardIds.add(card.id);
    }

    // Chuyển sang thẻ tiếp theo
    _currentCardIndex++;

    print('📚 Swiped RIGHT - Learned: ${card.frontText}');
    print('📊 Current index: $_currentCardIndex/${_originalCards.length}');
    print(
      '📊 List A: ${_originalCards.length}, List B (Learned): ${_learnedCards.length}, List C (Unlearned): ${_unlearnedCards.length}',
    );

    notifyListeners();
  }

  void onSwipeLeft(Flashcard card) {
    // Thêm vào list C (unlearned) - tạm thời, không lưu Hive
    if (!_unlearnedCards.any((c) => c.id == card.id)) {
      _unlearnedCards.add(card);
    }

    // Chuyển sang thẻ tiếp theo
    _currentCardIndex++;

    print('❌ Swiped LEFT - Unlearned: ${card.frontText}');
    print('📊 Current index: $_currentCardIndex/${_originalCards.length}');
    print(
      '📊 List A: ${_originalCards.length}, List B (Learned): ${_learnedCards.length}, List C (Unlearned): ${_unlearnedCards.length}',
    );

    notifyListeners();
  }

  bool get hasCardsToStudy {
    // Kết thúc khi đã học hết tất cả thẻ (index >= length)
    return _currentCardIndex < _originalCards.length;
  }

  Flashcard? get currentCard {
    // Hiển thị thẻ tại index hiện tại
    if (_currentCardIndex < _originalCards.length) {
      return _originalCards[_currentCardIndex];
    }
    return null;
  }

  void revertLastCard() {
    // Hoàn tác thẻ learned cuối cùng (không lưu Hive)
    if (_learnedCards.isNotEmpty) {
      final lastLearnedCard = _learnedCards.removeLast();
      _learnedCardIds.remove(lastLearnedCard.id);
      _currentCardIndex--; // Giảm index
      print('↩️ Reverted learned card: ${lastLearnedCard.frontText}');
    }
    // Hoặc hoàn tác thẻ unlearned cuối cùng (không lưu Hive)
    else if (_unlearnedCards.isNotEmpty) {
      final lastUnlearnedCard = _unlearnedCards.removeLast();
      _currentCardIndex--; // Giảm index
      print('↩️ Reverted unlearned card: ${lastUnlearnedCard.frontText}');
    }

    print(
      '📊 Current index after revert: $_currentCardIndex/${_originalCards.length}',
    );
    print(
      '📊 After revert - List A: ${_originalCards.length}, List B (Learned): ${_learnedCards.length}, List C (Unlearned): ${_unlearnedCards.length}',
    );

    notifyListeners();
  }

  Future<void> saveLearningResult() async {
    if (_courseData == null) return;

    try {
      final now = DateTime.now();
      print(
        '💾 Saving learning result - List B: ${_learnedCards.length}, List C: ${_unlearnedCards.length}',
      );

      // Lưu kết quả học tập
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
      LocalStorageHelper.setValue(resultKey, result);

      // Lưu list B (learned cards) vào Hive
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

      // Lưu list C (unlearned cards) vào Hive
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

      // Cập nhật danh sách kết quả
      final allResults =
          LocalStorageHelper.getValue('all_learning_results')
              as List<dynamic>? ??
          [];
      allResults.add(resultKey);
      LocalStorageHelper.setValue('all_learning_results', allResults);

      final coursesWithResults =
          LocalStorageHelper.getValue('courses_with_results')
              as List<dynamic>? ??
          [];
      if (!coursesWithResults.contains(_courseData!.id)) {
        coursesWithResults.add(_courseData!.id);
        LocalStorageHelper.setValue('courses_with_results', coursesWithResults);
      }

      print('✅ Successfully saved learning result to Hive');
    } catch (e) {
      print('❌ Error saving learning result: $e');
    }
  }

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

  static Future<Map<String, dynamic>?> getBookmarkedCourseInfo() async {
    try {
      final data = LocalStorageHelper.getValue('bookmarked_cards');
      if (data != null) {
        final Map<String, dynamic> bookmarkedData = Map<String, dynamic>.from(
          data as Map<dynamic, dynamic>,
        );
        return {
          'courseId': bookmarkedData['courseId'] ?? '',
          'courseTitle': bookmarkedData['courseTitle'] ?? 'Không có tiêu đề',
          'courseTopic': bookmarkedData['courseTopic'] ?? '',
          'courseDescription': bookmarkedData['courseDescription'] ?? '',
          'lastUpdated':
              bookmarkedData['lastUpdated'] ?? DateTime.now().toIso8601String(),
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
      // Không lưu Hive, chỉ lưu khi hoàn thành
      notifyListeners();
    }
  }

  void unmarkCardAsLearned(String cardId) {
    if (_learnedCardIds.contains(cardId)) {
      _learnedCardIds.remove(cardId);
      // Không lưu Hive, chỉ lưu khi hoàn thành
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
