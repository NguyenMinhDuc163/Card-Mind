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
    // Nếu nextReviewDate là hôm nay hoặc quá khứ
    if (nextReviewDate.isBefore(DateTime.now()) ||
        _isSameDay(nextReviewDate, DateTime.now())) {
      if (sendImmediateNotifications) {
        // Gửi sau vài giờ
        return DateTime.now().add(
          Duration(hours: immediateNotificationDelayHours),
        );
      } else {
        // Gửi vào thời gian mặc định ngày mai
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        return DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          defaultNotificationHour,
          defaultNotificationMinute,
        );
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
}
