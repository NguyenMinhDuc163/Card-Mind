import 'package:equatable/equatable.dart';
import 'package:card_mind/core/services/spaced_repetition_service.dart';

/// Model lưu trữ thông tin ôn tập theo phương pháp Spaced Repetition
/// Sử dụng thuật toán đơn giản hóa của SM-2
class CardReviewData extends Equatable {
  /// ID của flashcard
  final String cardId;

  /// ID của khóa học
  final String courseId;

  /// Ngày ôn tập lần cuối
  final DateTime lastReviewDate;

  /// Ngày cần ôn tập tiếp theo
  final DateTime nextReviewDate;

  /// Khoảng thời gian giữa các lần ôn tập (tính bằng ngày)
  /// Ví dụ: 1, 3, 7, 14, 30 ngày
  final int intervalDays;

  /// Hệ số độ dễ (ease factor) - mặc định 2.5
  /// Tăng lên khi người dùng đánh dấu "đã học"
  /// Giảm xuống khi người dùng đánh dấu "chưa học"
  final double easeFactor;

  /// Số lần ôn tập thành công liên tiếp
  final int repetitions;

  /// Chất lượng của lần ôn tập gần nhất (0-5)
  /// 5: Hoàn hảo, nhớ rất rõ
  /// 4: Đúng sau khi ngần ngại
  /// 3: Đúng nhưng khó nhớ
  /// 2: Sai nhưng nhớ lại được
  /// 1: Sai, không nhớ gì
  /// 0: Hoàn toàn quên
  final int quality;

  const CardReviewData({
    required this.cardId,
    required this.courseId,
    required this.lastReviewDate,
    required this.nextReviewDate,
    required this.intervalDays,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    this.quality = 3,
  });

  /// Tạo CardReviewData mới cho lần đầu tiên
  factory CardReviewData.initial({
    required String cardId,
    required String courseId,
    required bool isLearned,
  }) {
    final now = DateTime.now();
    final service = SpacedRepetitionService();

    final intervalDays = isLearned ? service.interval1 : 0;
    final nextReviewDate = isLearned
        ? now.add(service.getDuration(intervalDays))
        : now;

    return CardReviewData(
      cardId: cardId,
      courseId: courseId,
      lastReviewDate: now,
      nextReviewDate: nextReviewDate,
      intervalDays: intervalDays,
      easeFactor: service.initialEaseFactor,
      repetitions: isLearned ? 1 : 0,
      quality: isLearned ? 4 : 1,
    );
  }

  /// Kiểm tra xem thẻ có cần ôn tập không
  bool needsReview() {
    final now = DateTime.now();
    final service = SpacedRepetitionService();

    // Nếu đang dùng minutes (test mode) -> so sánh chính xác đến phút/giây
    if (service.timeUnit == 'minutes') {
      return nextReviewDate.isBefore(now) ||
             nextReviewDate.isAtSameMomentAs(now);
    }

    // Nếu đang dùng days (production) -> so sánh theo ngày (bỏ qua giờ)
    return nextReviewDate.isBefore(now) ||
           nextReviewDate.isAtSameMomentAs(now) ||
           _isSameDay(nextReviewDate, now);
  }

  /// So sánh 2 ngày có cùng ngày không (bỏ qua giờ)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Tạo CardReviewData mới sau khi ôn tập
  /// [isCorrect] - true nếu người dùng đánh dấu "đã học", false nếu "chưa học"
  CardReviewData nextReview({required bool isCorrect}) {
    final now = DateTime.now();
    final service = SpacedRepetitionService();

    if (!isCorrect) {
      // Nếu trả lời sai hoặc không nhớ -> reset về đầu
      final newEaseFactor = (easeFactor - service.easeFactorDecrement)
          .clamp(service.minEaseFactor, service.maxEaseFactor);

      return CardReviewData(
        cardId: cardId,
        courseId: courseId,
        lastReviewDate: now,
        nextReviewDate: now, // Ôn lại ngay
        intervalDays: 0,
        easeFactor: newEaseFactor,
        repetitions: 0,
        quality: 1,
      );
    }

    // Nếu trả lời đúng -> tính interval tiếp theo theo thuật toán SM-2
    int newInterval;
    final newRepetitions = repetitions + 1;

    if (newRepetitions == 1) {
      newInterval = service.interval1;
    } else if (newRepetitions == 2) {
      newInterval = service.interval2;
    } else {
      // Từ lần 3 trở đi: interval = interval_trước × ease_factor
      newInterval = (intervalDays * easeFactor).round();
    }

    // Giới hạn interval trong khoảng cho phép
    newInterval = newInterval.clamp(1, service.maxInterval);

    final newEaseFactor = (easeFactor + service.easeFactorIncrement)
        .clamp(service.minEaseFactor, service.maxEaseFactor);

    return CardReviewData(
      cardId: cardId,
      courseId: courseId,
      lastReviewDate: now,
      nextReviewDate: now.add(service.getDuration(newInterval)),
      intervalDays: newInterval,
      easeFactor: newEaseFactor,
      repetitions: newRepetitions,
      quality: 4,
    );
  }

  @override
  List<Object?> get props => [
        cardId,
        courseId,
        lastReviewDate,
        nextReviewDate,
        intervalDays,
        easeFactor,
        repetitions,
        quality,
      ];

  CardReviewData copyWith({
    String? cardId,
    String? courseId,
    DateTime? lastReviewDate,
    DateTime? nextReviewDate,
    int? intervalDays,
    double? easeFactor,
    int? repetitions,
    int? quality,
  }) {
    return CardReviewData(
      cardId: cardId ?? this.cardId,
      courseId: courseId ?? this.courseId,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      quality: quality ?? this.quality,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'courseId': courseId,
      'lastReviewDate': lastReviewDate.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'intervalDays': intervalDays,
      'easeFactor': easeFactor,
      'repetitions': repetitions,
      'quality': quality,
    };
  }

  factory CardReviewData.fromJson(Map<String, dynamic> json) {
    return CardReviewData(
      cardId: json['cardId'] as String,
      courseId: json['courseId'] as String,
      lastReviewDate: DateTime.parse(json['lastReviewDate'] as String),
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
      intervalDays: json['intervalDays'] as int,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      repetitions: json['repetitions'] as int? ?? 0,
      quality: json['quality'] as int? ?? 3,
    );
  }
}
