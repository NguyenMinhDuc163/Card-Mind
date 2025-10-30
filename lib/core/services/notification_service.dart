import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:card_mind/core/config/notification_config.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';

/// Service quản lý Local Push Notifications
/// Sử dụng để nhắc nhở người dùng ôn tập flashcards
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notification service
  /// Phải gọi method này trước khi sử dụng service
  Future<void> initialize() async {
    if (_isInitialized) {
      print('📱 NotificationService already initialized');
      return;
    }

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      // Set local timezone (mặc định UTC+7 cho Việt Nam)
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create Android notification channel
      await _createAndroidNotificationChannel();

      _isInitialized = true;
      print('✅ NotificationService initialized successfully');
    } catch (e) {
      print('❌ Error initializing NotificationService: $e');
      _isInitialized = false;
    }
  }

  /// Tạo Android notification channel
  Future<void> _createAndroidNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      NotificationConfig.androidChannelId,
      NotificationConfig.androidChannelName,
      description: NotificationConfig.androidChannelDescription,
      importance: Importance.max,
      playSound: NotificationConfig.playSound,
      enableVibration: NotificationConfig.enableVibration,
      showBadge: NotificationConfig.showBadge,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Xử lý khi user tap vào notification
  void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
    // TODO: Navigate to review screen với course ID từ payload
    // Có thể emit event hoặc sử dụng navigation service
  }

  /// Request notification permissions (chủ yếu cho iOS)
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // iOS permissions
      final iosPermissions = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      // Android 13+ permissions
      final androidPermissions = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      final granted = (iosPermissions ?? true) && (androidPermissions ?? true);
      print('📱 Notification permissions: ${granted ? "granted" : "denied"}');
      return granted;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      return false;
    }
  }

  /// Kiểm tra xem notifications có được bật không
  Future<bool> areNotificationsEnabled() async {
    // Check user preference
    final userEnabled = LocalStorageHelper.getValue(
          NotificationConfig.notificationEnabledKey,
        ) as bool? ??
        true;

    if (!userEnabled) {
      return false;
    }

    // Check system permissions (chỉ check được trên Android)
    try {
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        final enabled = await androidImpl.areNotificationsEnabled();
        return enabled ?? true;
      }
    } catch (e) {
      print('❌ Error checking notification status: $e');
    }

    return userEnabled;
  }

  /// Bật/tắt notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    LocalStorageHelper.setValue(
      NotificationConfig.notificationEnabledKey,
      enabled,
    );
    print('📱 Notifications ${enabled ? "enabled" : "disabled"}');

    if (!enabled) {
      // Cancel tất cả notifications nếu tắt
      await cancelAllNotifications();
    }
  }

  /// Schedule một notification cho card cần ôn tập
  Future<void> scheduleReviewNotification({
    required String courseId,
    required String cardId,
    required DateTime nextReviewDate,
    String? courseTitle,
    int cardCount = 1,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check nếu notifications bị tắt
    if (!await areNotificationsEnabled()) {
      print('📱 Notifications disabled, skipping schedule');
      return;
    }

    try {
      // Tính thời gian gửi notification
      final scheduledTime =
          NotificationConfig.calculateNotificationTime(nextReviewDate);

      // Không schedule notification quá xa trong tương lai
      final daysUntil = scheduledTime.difference(DateTime.now()).inDays;
      if (daysUntil > NotificationConfig.maxDaysToScheduleAhead) {
        print(
          '📱 Skipping notification: too far in future ($daysUntil days)',
        );
        return;
      }

      // Không schedule notification trong quá khứ
      if (scheduledTime.isBefore(DateTime.now())) {
        print('📱 Skipping notification: scheduled time is in the past');
        return;
      }

      // Generate unique notification ID
      final notificationId = _generateNotificationId(courseId, cardId);

      // Tạo notification body
      final body = NotificationConfig.getBodyForCardCount(
        cardCount: cardCount,
        courseTitle: courseTitle,
      );

      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        NotificationConfig.androidChannelId,
        NotificationConfig.androidChannelName,
        channelDescription: NotificationConfig.androidChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: NotificationConfig.playSound,
        enableVibration: NotificationConfig.enableVibration,
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Notification details
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule notification
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        NotificationConfig.defaultTitle,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
        payload: courseId, // Có thể dùng để navigate
      );

      print('\n📱 ============================================');
      print('📱 [Notification] SCHEDULED SUCCESSFULLY');
      print('📱 ============================================');
      print('📱 Notification ID: #$notificationId');
      print('📱 Course: $courseId');
      print('📱 Card: $cardId');
      print('📱 Next Review Date: $nextReviewDate');
      print('📱 Scheduled Time: $scheduledTime');
      print('📱 Time until notification: ${scheduledTime.difference(DateTime.now())}');
      print('📱 Title: ${NotificationConfig.defaultTitle}');
      print('📱 Body: $body');
      print('📱 ============================================\n');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  /// Cancel notification cho một card cụ thể
  Future<void> cancelReviewNotification({
    required String courseId,
    required String cardId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final notificationId = _generateNotificationId(courseId, cardId);
      await _notificationsPlugin.cancel(notificationId);
      print('📱 Cancelled notification #$notificationId');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  /// Cancel tất cả notifications của một course
  Future<void> cancelCourseNotifications(String courseId) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Note: flutter_local_notifications không hỗ trợ cancel by group
      // Cần track notification IDs riêng hoặc cancel all
      // Để đơn giản, ta sẽ implement sau nếu cần thiết
      print('📱 Cancel course notifications: $courseId (not fully implemented)');
    } catch (e) {
      print('❌ Error cancelling course notifications: $e');
    }
  }

  /// Cancel tất cả notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _notificationsPlugin.cancelAll();
      print('📱 Cancelled all notifications');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  /// Show notification ngay lập tức (dùng cho testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        NotificationConfig.androidChannelId,
        NotificationConfig.androidChannelName,
        channelDescription: NotificationConfig.androidChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      print('📱 Showed immediate notification: $title');
    } catch (e) {
      print('❌ Error showing immediate notification: $e');
    }
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      print('📱 Pending notifications: ${pending.length}');
      return pending;
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  /// Generate unique notification ID từ courseId và cardId
  /// Sử dụng hash để tạo ID duy nhất nhưng reproducible
  int _generateNotificationId(String courseId, String cardId) {
    final combined = '$courseId-$cardId';
    // Simple hash function
    int hash = 0;
    for (int i = 0; i < combined.length; i++) {
      hash = ((hash << 5) - hash) + combined.codeUnitAt(i);
      hash = hash & hash; // Convert to 32bit integer
    }
    // Ensure positive and within int32 range
    return hash.abs() % 2147483647;
  }
}
