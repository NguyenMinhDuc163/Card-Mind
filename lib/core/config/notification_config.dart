import 'package:card_mind/core/services/spaced_repetition_service.dart';

/// Cấu hình cho Local Push Notifications
/// File này chứa tất cả các tham số có thể điều chỉnh cho thông báo
class NotificationConfig {
  NotificationConfig._();

  // ============ ANDROID NOTIFICATION CHANNEL ============
  static const String androidChannelId = 'card_mind_review_channel';
  static const String androidChannelName = 'Nhắc nhở ôn tập';
  static const String androidChannelDescription =
      'Thông báo nhắc nhở ôn tập flashcard theo lịch';

  // ============ NOTIFICATION CONTENT ============

  /// Tiêu đề mặc định cho notification
  static const String defaultTitle = '⏰ Đến giờ ôn tập rồi!';

  /// Body templates - có thể dùng {courseTitle}, {cardCount}
  static const String singleCardBody = 'Bạn có 1 thẻ cần ôn tập';
  static const String multipleCardsBody = 'Bạn có {cardCount} thẻ cần ôn tập';
  static const String courseSpecificBody =
      'Khóa học "{courseTitle}" có {cardCount} thẻ cần ôn tập';

  // ============ NOTIFICATION TIMING ============

  /// Thời gian gửi notification trong ngày (giờ)
  /// Mặc định: 9:00 sáng
  static const int defaultNotificationHour = 9;

  /// Phút của giờ gửi notification
  /// Mặc định: 0 phút (9:00)
  static const int defaultNotificationMinute = 0;

  // ============ DAILY REMINDER TIMING ============

  /// Có bật daily reminder không?
  static const String dailyReminderEnabledKey = 'daily_reminder_enabled';

  /// Thời gian gửi reminder buổi sáng (giờ)
  static const int morningReminderHour = 8;
  static const int morningReminderMinute = 0;

  /// Thời gian gửi reminder buổi trưa (giờ)
  static const int afternoonReminderHour = 13;
  static const int afternoonReminderMinute = 0;

  /// Thời gian gửi reminder buổi tối (giờ)
  static const int eveningReminderHour = 20;
  static const int eveningReminderMinute = 0;

  // ============ DAILY REMINDER MESSAGES ============

  /// Danh sách tin nhắn vui nhộn cho buổi sáng
  static const List<String> morningMessages = [
    'Chào buổi sáng! ☀️ Bắt đầu ngày mới với vài thẻ học nào!',
    'Sáng nay học một chút, tối đi chơi thoải mái! 😎',
    'Cà phê đã uống, giờ đến lượt thẻ học rồi! ☕',
    'Sáng sớm tinh thần minh mẫn, học ngay thôi! 🌅',
    'Một ngày mới, một cơ hội mới để học hỏi! 🎯',
  ];

  /// Danh sách tin nhắn vui nhộn cho buổi trưa
  static const List<String> afternoonMessages = [
    'Giờ nghỉ trưa học chút cho máu não lưu thông! 🧠',
    'Ăn trưa xong rồi, học 5 phút cho tỉnh ngủ nào! 😴',
    'Trưa nay bạn đã học gì chưa nhỉ? 🤔',
    'Nghỉ trưa mà không học thì phí cả buổi! ⏰',
    'Hôm nay là một ngày tốt lành để học! 🌤️',
  ];

  /// Danh sách tin nhắn vui nhộn cho buổi tối
  static const List<String> eveningMessages = [
    'Tối rồi! Ôn lại kiến thức trước khi ngủ nhé! 🌙',
    'Học trước khi ngủ giúp não ghi nhớ tốt hơn đấy! 💡',
    'Hôm nay bạn chưa học gì phải không? 🙃',
    'Tối nay chill một chút với mấy thẻ học nào! 😌',
    'Ngày sắp hết rồi, dành 5 phút cho bộ não thôi! 🎓',
  ];

  /// Có gửi notification ngay lập tức cho thẻ cần ôn ngay không?
  /// true: gửi ngay khi thẻ cần ôn (sau vài giờ)
  /// false: chờ đến thời gian mặc định ngày hôm sau
  static const bool sendImmediateNotifications = false;

  /// Số giờ delay trước khi gửi notification ngay lập tức
  /// Chỉ áp dụng khi sendImmediateNotifications = true
  static const int immediateNotificationDelayHours = 2;

  // ============ NOTIFICATION BEHAVIOR ============

  /// Có gộp nhiều thẻ cùng course thành 1 notification không?
  static const bool groupByCourse = true;

  /// Số lượng thẻ tối đa để show chi tiết
  /// Nếu vượt quá sẽ chỉ hiển thị số lượng
  static const int maxCardsToShowDetail = 5;

  /// Có phát âm thanh không?
  static const bool playSound = true;

  /// Có rung không?
  static const bool enableVibration = true;

  /// Có hiển thị badge (số đếm) trên app icon không?
  static const bool showBadge = true;

  // ============ NOTIFICATION PRIORITY ============

  /// Priority cho Android
  /// 0 = Min, 1 = Low, 2 = Default, 3 = High, 4 = Max
  static const int androidPriority = 3; // High

  /// Importance cho Android
  /// 0 = None, 1 = Min, 2 = Low, 3 = Default, 4 = High, 5 = Max
  static const int androidImportance = 4; // High

  // ============ ADVANCED SETTINGS ============

  /// Có cho phép user tắt notification không?
  /// Nếu true, sẽ lưu preference trong LocalStorage
  static const bool allowUserDisable = true;

  /// Key để lưu preference bật/tắt notification
  static const String notificationEnabledKey = 'notifications_enabled';

  /// Số ngày tối đa để schedule notification trước
  /// Tránh schedule quá nhiều notification làm đầy hàng đợi
  static const int maxDaysToScheduleAhead = 30;

  /// Có tự động cancel notification cũ khi reschedule không?
  static const bool autoCancelOldNotifications = true;

  // ============ HELPER METHODS ============

  /// Format body message với các placeholder
  static String formatBody({
    required String template,
    String? courseTitle,
    int? cardCount,
  }) {
    String result = template;
    if (courseTitle != null) {
      result = result.replaceAll('{courseTitle}', courseTitle);
    }
    if (cardCount != null) {
      result = result.replaceAll('{cardCount}', cardCount.toString());
    }
    return result;
  }

  /// Lấy body message dựa trên số lượng thẻ
  static String getBodyForCardCount({
    required int cardCount,
    String? courseTitle,
  }) {
    if (cardCount == 1) {
      return singleCardBody;
    } else if (courseTitle != null && groupByCourse) {
      return formatBody(
        template: courseSpecificBody,
        courseTitle: courseTitle,
        cardCount: cardCount,
      );
    } else {
      return formatBody(
        template: multipleCardsBody,
        cardCount: cardCount,
      );
    }
  }

  /// Tính thời gian gửi notification dựa trên nextReviewDate
  static DateTime calculateNotificationTime(DateTime nextReviewDate) {
    final now = DateTime.now();

    // Kiểm tra timeUnit từ SpacedRepetitionService
    final service = SpacedRepetitionService();
    final isMinutesMode = service.timeUnit == 'minutes';

    // Nếu đang dùng minutes mode, GỬI ĐÚNG THỜI GIAN nextReviewDate
    if (isMinutesMode) {
      // Nếu nextReviewDate là quá khứ, gửi sau 1 phút
      if (nextReviewDate.isBefore(now)) {
        return now.add(const Duration(minutes: 1));
      }
      // Nếu nextReviewDate là tương lai, gửi đúng thời gian đó
      return nextReviewDate;
    }

    // ===== DAYS MODE =====
    // Nếu nextReviewDate là quá khứ hoặc hiện tại
    if (nextReviewDate.isBefore(now) || nextReviewDate.isAtSameMomentAs(now)) {
      if (sendImmediateNotifications) {
        // Gửi sau vài giờ
        return now.add(
          Duration(hours: immediateNotificationDelayHours),
        );
      } else {
        // Gửi vào thời gian mặc định ngày mai
        final tomorrow = now.add(const Duration(days: 1));
        return DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          defaultNotificationHour,
          defaultNotificationMinute,
        );
      }
    }

    // Nếu nextReviewDate là cùng ngày (chỉ áp dụng cho days mode)
    if (_isSameDay(nextReviewDate, now)) {
      if (sendImmediateNotifications) {
        // Gửi sau vài giờ
        return now.add(
          Duration(hours: immediateNotificationDelayHours),
        );
      } else {
        // Gửi vào thời gian mặc định hôm nay
        final today = DateTime(
          now.year,
          now.month,
          now.day,
          defaultNotificationHour,
          defaultNotificationMinute,
        );

        // Nếu thời gian đó đã qua, gửi ngày mai
        if (today.isBefore(now)) {
          final tomorrow = now.add(const Duration(days: 1));
          return DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            defaultNotificationHour,
            defaultNotificationMinute,
          );
        }
        return today;
      }
    }

    // Nếu nextReviewDate là tương lai
    // Gửi notification vào thời gian mặc định của ngày đó
    return DateTime(
      nextReviewDate.year,
      nextReviewDate.month,
      nextReviewDate.day,
      defaultNotificationHour,
      defaultNotificationMinute,
    );
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Lấy random message cho daily reminder dựa vào thời gian trong ngày
  static String getRandomDailyReminderMessage(DateTime time) {
    final hour = time.hour;

    // Sáng: 6h - 11h
    if (hour >= 6 && hour < 12) {
      final index = time.day % morningMessages.length;
      return morningMessages[index];
    }
    // Trưa: 12h - 17h
    else if (hour >= 12 && hour < 18) {
      final index = time.day % afternoonMessages.length;
      return afternoonMessages[index];
    }
    // Tối: 18h - 23h
    else {
      final index = time.day % eveningMessages.length;
      return eveningMessages[index];
    }
  }
}
