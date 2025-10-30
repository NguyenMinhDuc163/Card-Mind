import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/data/models/card_review_data.dart';

/// Service quản lý Spaced Repetition
/// Lưu trữ và tính toán lịch ôn tập cho các flashcards
/// Bao gồm cả config để tùy chỉnh tham số
class SpacedRepetitionService {
  SpacedRepetitionService._internal();
  static final SpacedRepetitionService _instance =
      SpacedRepetitionService._internal();
  factory SpacedRepetitionService() => _instance;

  static const String _reviewDataPrefix = 'review_data_';
  static const String _courseReviewsPrefix = 'course_reviews_';
  static const String _configKey = 'spaced_repetition_config';

  // ============ CẤU HÌNH MẶC ĐỊNH ============
  static const String _defaultTimeUnit = 'days'; // 'days' hoặc 'minutes'
  static const int _defaultInterval1 = 1;
  static const int _defaultInterval2 = 3;
  static const int _defaultMaxInterval = 180;
  static const double _defaultInitialEaseFactor = 2.5;
  static const double _defaultEaseFactorIncrement = 0.1;
  static const double _defaultEaseFactorDecrement = 0.2;
  static const double _defaultMinEaseFactor = 1.3;
  static const double _defaultMaxEaseFactor = 2.5;

  Map<String, dynamic>? _cachedConfig;

  // ============ CONFIG GETTERS ============

  Map<String, dynamic> _loadConfig() {
    if (_cachedConfig != null) return _cachedConfig!;
    final data = LocalStorageHelper.getValue(_configKey);
    if (data != null) {
      _cachedConfig = Map<String, dynamic>.from(data as Map<dynamic, dynamic>);
      return _cachedConfig!;
    }
    return _getDefaultConfig();
  }

  Map<String, dynamic> _getDefaultConfig() {
    return {
      'timeUnit': _defaultTimeUnit,
      'interval1': _defaultInterval1,
      'interval2': _defaultInterval2,
      'maxInterval': _defaultMaxInterval,
      'initialEaseFactor': _defaultInitialEaseFactor,
      'easeFactorIncrement': _defaultEaseFactorIncrement,
      'easeFactorDecrement': _defaultEaseFactorDecrement,
      'minEaseFactor': _defaultMinEaseFactor,
      'maxEaseFactor': _defaultMaxEaseFactor,
    };
  }

  String get timeUnit => _loadConfig()['timeUnit'] as String? ?? _defaultTimeUnit;
  int get interval1 => _loadConfig()['interval1'] as int? ?? _defaultInterval1;
  int get interval2 => _loadConfig()['interval2'] as int? ?? _defaultInterval2;
  int get maxInterval => _loadConfig()['maxInterval'] as int? ?? _defaultMaxInterval;
  double get initialEaseFactor => (_loadConfig()['initialEaseFactor'] as num?)?.toDouble() ?? _defaultInitialEaseFactor;
  double get easeFactorIncrement => (_loadConfig()['easeFactorIncrement'] as num?)?.toDouble() ?? _defaultEaseFactorIncrement;
  double get easeFactorDecrement => (_loadConfig()['easeFactorDecrement'] as num?)?.toDouble() ?? _defaultEaseFactorDecrement;
  double get minEaseFactor => (_loadConfig()['minEaseFactor'] as num?)?.toDouble() ?? _defaultMinEaseFactor;
  double get maxEaseFactor => (_loadConfig()['maxEaseFactor'] as num?)?.toDouble() ?? _defaultMaxEaseFactor;

  Duration getDuration(int interval) {
    return timeUnit == 'minutes' ? Duration(minutes: interval) : Duration(days: interval);
  }

  String get timeUnitVi => timeUnit == 'minutes' ? 'phút' : 'ngày';

  // ============ CONFIG SETTERS ============

  Future<void> updateConfig({
    String? timeUnit,
    int? interval1,
    int? interval2,
    int? maxInterval,
    double? initialEaseFactor,
    double? easeFactorIncrement,
    double? easeFactorDecrement,
    double? minEaseFactor,
    double? maxEaseFactor,
  }) async {
    final config = _loadConfig();
    if (timeUnit != null) config['timeUnit'] = timeUnit;
    if (interval1 != null) config['interval1'] = interval1;
    if (interval2 != null) config['interval2'] = interval2;
    if (maxInterval != null) config['maxInterval'] = maxInterval;
    if (initialEaseFactor != null) config['initialEaseFactor'] = initialEaseFactor;
    if (easeFactorIncrement != null) config['easeFactorIncrement'] = easeFactorIncrement;
    if (easeFactorDecrement != null) config['easeFactorDecrement'] = easeFactorDecrement;
    if (minEaseFactor != null) config['minEaseFactor'] = minEaseFactor;
    if (maxEaseFactor != null) config['maxEaseFactor'] = maxEaseFactor;
    LocalStorageHelper.setValue(_configKey, config);
    _cachedConfig = config;
    print('✅ Đã cập nhật config: $config');
  }

  Future<void> resetToDefault() async {
    final config = _getDefaultConfig();
    LocalStorageHelper.setValue(_configKey, config);
    _cachedConfig = config;
    print('🔄 Đã reset config về mặc định');
  }

  /// Lưu dữ liệu ôn tập của một flashcard
  Future<void> saveCardReviewData(CardReviewData reviewData) async {
    try {
      final key = _getCardReviewKey(reviewData.courseId, reviewData.cardId);
      LocalStorageHelper.setValue(key, reviewData.toJson());

      // Cập nhật danh sách cards review của course
      await _updateCourseReviewsList(reviewData.courseId, reviewData.cardId);

      print(
        '💾 Saved review data for card ${reviewData.cardId}: '
        'interval=${reviewData.intervalDays} days, '
        'nextReview=${_formatDate(reviewData.nextReviewDate)}',
      );
    } catch (e) {
      print('❌ Error saving card review data: $e');
    }
  }

  /// Lấy dữ liệu ôn tập của một flashcard
  Future<CardReviewData?> getCardReviewData(
    String courseId,
    String cardId,
  ) async {
    try {
      final key = _getCardReviewKey(courseId, cardId);
      final data = LocalStorageHelper.getValue(key);

      if (data != null) {
        final Map<String, dynamic> jsonData =
            Map<String, dynamic>.from(data as Map<dynamic, dynamic>);
        return CardReviewData.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('❌ Error getting card review data: $e');
      return null;
    }
  }

  /// Lấy tất cả cards review của một course
  Future<List<CardReviewData>> getCourseReviewData(String courseId) async {
    try {
      final cardIds = await _getCourseReviewCardIds(courseId);
      final List<CardReviewData> reviewDataList = [];

      for (final cardId in cardIds) {
        final reviewData = await getCardReviewData(courseId, cardId);
        if (reviewData != null) {
          reviewDataList.add(reviewData);
        }
      }

      return reviewDataList;
    } catch (e) {
      print('❌ Error getting course review data: $e');
      return [];
    }
  }

  /// Lấy các cards cần ôn tập của một course
  Future<List<CardReviewData>> getCardsNeedingReview(String courseId) async {
    try {
      final allReviewData = await getCourseReviewData(courseId);
      final cardsNeedingReview =
          allReviewData.where((data) => data.needsReview()).toList();

      print(
        '📅 Course $courseId: ${cardsNeedingReview.length}/${allReviewData.length} cards need review',
      );

      return cardsNeedingReview;
    } catch (e) {
      print('❌ Error getting cards needing review: $e');
      return [];
    }
  }

  /// Lấy danh sách tất cả courses có cards cần ôn tập
  Future<Map<String, int>> getCoursesWithCardsNeedingReview() async {
    try {
      final Map<String, int> result = {};

      // Lấy danh sách tất cả courses
      final courseKeys =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];

      for (final key in courseKeys) {
        final courseData = LocalStorageHelper.getValue(key as String);
        if (courseData != null) {
          final Map<String, dynamic> jsonData =
              Map<String, dynamic>.from(courseData as Map<dynamic, dynamic>);
          final courseId = jsonData['id'] as String;

          final cardsNeedingReview = await getCardsNeedingReview(courseId);
          if (cardsNeedingReview.isNotEmpty) {
            result[courseId] = cardsNeedingReview.length;
          }
        }
      }

      print(
        '🔍 Found ${result.length} courses with cards needing review: $result',
      );

      return result;
    } catch (e) {
      print('❌ Error getting courses with cards needing review: $e');
      return {};
    }
  }

  /// Cập nhật review data sau khi người dùng ôn tập
  Future<void> updateAfterReview({
    required String courseId,
    required String cardId,
    required bool isCorrect,
  }) async {
    try {
      // Lấy review data hiện tại
      CardReviewData? currentReviewData =
          await getCardReviewData(courseId, cardId);

      // Nếu chưa có review data, tạo mới
      currentReviewData ??= CardReviewData.initial(
        cardId: cardId,
        courseId: courseId,
        isLearned: isCorrect,
      );

      // Tính toán review data tiếp theo
      final nextReviewData = currentReviewData.nextReview(isCorrect: isCorrect);

      // Lưu review data mới
      await saveCardReviewData(nextReviewData);

      print(
        '✅ Updated review for card $cardId: '
        'isCorrect=$isCorrect, '
        'nextInterval=${nextReviewData.intervalDays} days',
      );
    } catch (e) {
      print('❌ Error updating review: $e');
    }
  }

  /// Xóa tất cả review data của một course
  Future<void> deleteCourseReviewData(String courseId) async {
    try {
      final cardIds = await _getCourseReviewCardIds(courseId);

      // Xóa từng card review data
      for (final cardId in cardIds) {
        final key = _getCardReviewKey(courseId, cardId);
        LocalStorageHelper.deleteValue(key);
      }

      // Xóa danh sách course reviews
      final courseReviewsKey = _getCourseReviewsKey(courseId);
      LocalStorageHelper.deleteValue(courseReviewsKey);

      print('🗑️ Deleted all review data for course $courseId');
    } catch (e) {
      print('❌ Error deleting course review data: $e');
    }
  }

  /// Xóa review data của một card cụ thể
  Future<void> deleteCardReviewData(String courseId, String cardId) async {
    try {
      final key = _getCardReviewKey(courseId, cardId);
      LocalStorageHelper.deleteValue(key);

      // Xóa khỏi danh sách course reviews
      await _removeFromCourseReviewsList(courseId, cardId);

      print('🗑️ Deleted review data for card $cardId');
    } catch (e) {
      print('❌ Error deleting card review data: $e');
    }
  }

  /// Lấy thống kê ôn tập của một course
  Future<Map<String, dynamic>> getCourseReviewStats(String courseId) async {
    try {
      final allReviewData = await getCourseReviewData(courseId);
      final cardsNeedingReview =
          allReviewData.where((data) => data.needsReview()).toList();

      final totalCards = allReviewData.length;
      final needReviewCount = cardsNeedingReview.length;
      final masteredCount = allReviewData
          .where((data) => data.repetitions >= 3 && !data.needsReview())
          .length;

      return {
        'totalCards': totalCards,
        'needReviewCount': needReviewCount,
        'masteredCount': masteredCount,
        'inProgressCount': totalCards - needReviewCount - masteredCount,
      };
    } catch (e) {
      print('❌ Error getting course review stats: $e');
      return {
        'totalCards': 0,
        'needReviewCount': 0,
        'masteredCount': 0,
        'inProgressCount': 0,
      };
    }
  }

  // ============= Private Methods =============

  String _getCardReviewKey(String courseId, String cardId) {
    return '$_reviewDataPrefix${courseId}_$cardId';
  }

  String _getCourseReviewsKey(String courseId) {
    return '$_courseReviewsPrefix$courseId';
  }

  Future<void> _updateCourseReviewsList(String courseId, String cardId) async {
    try {
      final key = _getCourseReviewsKey(courseId);
      final data = LocalStorageHelper.getValue(key) as List<dynamic>? ?? [];
      final cardIds = data.cast<String>();

      if (!cardIds.contains(cardId)) {
        cardIds.add(cardId);
        LocalStorageHelper.setValue(key, cardIds);
      }
    } catch (e) {
      print('❌ Error updating course reviews list: $e');
    }
  }

  Future<void> _removeFromCourseReviewsList(
    String courseId,
    String cardId,
  ) async {
    try {
      final key = _getCourseReviewsKey(courseId);
      final data = LocalStorageHelper.getValue(key) as List<dynamic>? ?? [];
      final cardIds = data.cast<String>();

      cardIds.remove(cardId);
      LocalStorageHelper.setValue(key, cardIds);
    } catch (e) {
      print('❌ Error removing from course reviews list: $e');
    }
  }

  Future<List<String>> _getCourseReviewCardIds(String courseId) async {
    try {
      final key = _getCourseReviewsKey(courseId);
      final data = LocalStorageHelper.getValue(key) as List<dynamic>? ?? [];
      return data.cast<String>();
    } catch (e) {
      print('❌ Error getting course review card ids: $e');
      return [];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
