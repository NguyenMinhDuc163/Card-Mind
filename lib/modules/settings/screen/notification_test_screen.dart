import 'package:card_mind/init.dart';
import 'package:card_mind/core/services/notification_service.dart';
import 'package:card_mind/core/services/spaced_repetition_service.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';

/// Màn hình test notification - CHỈ DÙNG ĐỂ TEST
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  static const String routeName = '/notification-test';

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  String _status = 'Sẵn sàng test';
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _updatePendingCount();
  }

  Future<void> _updatePendingCount() async {
    final pending = await NotificationService().getPendingNotifications();
    setState(() {
      _pendingCount = pending.length;
    });
  }

  // Test 1: Gửi notification ngay lập tức
  Future<void> _testImmediateNotification() async {
    setState(() => _status = 'Đang gửi notification...');

    try {
      await NotificationService().showImmediateNotification(
        title: '⏰ Test Notification',
        body: 'Đây là thông báo test! Nếu bạn thấy được thì đã thành công 🎉',
      );

      setState(() => _status = '✅ Đã gửi! Check thanh notification');
    } catch (e) {
      setState(() => _status = '❌ Lỗi: $e');
    }
  }

  // Test 2: Schedule notification sau 10 giây
  Future<void> _testScheduleNotification() async {
    setState(() => _status = 'Đang schedule notification...');

    try {
      final nextReviewDate = DateTime.now().add(const Duration(seconds: 10));

      await NotificationService().scheduleReviewNotification(
        courseId: 'test_course_123',
        cardId: 'test_card_456',
        nextReviewDate: nextReviewDate,
        courseTitle: 'Test Course',
        cardCount: 5,
      );

      await _updatePendingCount();

      setState(() => _status = '✅ Đã schedule! Đợi 10 giây...');
    } catch (e) {
      setState(() => _status = '❌ Lỗi: $e');
    }
  }

  // Test 3: Request permissions
  Future<void> _testRequestPermissions() async {
    setState(() => _status = 'Đang request permissions...');

    try {
      final granted = await NotificationService().requestPermissions();

      setState(() => _status = granted
          ? '✅ Permissions granted!'
          : '❌ Permissions denied');
    } catch (e) {
      setState(() => _status = '❌ Lỗi: $e');
    }
  }

  // Test 4: Check if notifications enabled
  Future<void> _testCheckEnabled() async {
    setState(() => _status = 'Đang check...');

    try {
      final enabled = await NotificationService().areNotificationsEnabled();

      setState(() => _status = enabled
          ? '✅ Notifications đang BẬT'
          : '❌ Notifications đang TẮT');
    } catch (e) {
      setState(() => _status = '❌ Lỗi: $e');
    }
  }

  // Test 5: Toggle notifications on/off
  Future<void> _testToggleNotifications() async {
    setState(() => _status = 'Đang toggle...');

    try {
      final currentlyEnabled = await NotificationService().areNotificationsEnabled();
      await NotificationService().setNotificationsEnabled(!currentlyEnabled);

      setState(() => _status = !currentlyEnabled
          ? '✅ Đã BẬT notifications'
          : '⚠️ Đã TẮT notifications');
    } catch (e) {
      setState(() => _status = '❌ Lỗi: $e');
    }
  }

  // Test 6: Cancel all notifications
  Future<void> _testCancelAll() async {
    setState(() => _status = 'Đang cancel...');

    try {
      await NotificationService().cancelAllNotifications();
      await _updatePendingCount();

      setState(() => _status = '✅ Đã cancel tất cả notifications');
    } catch (e) {
      setState(() => _status = '❌ Lỗi: $e');
    }
  }

  // Test 7: Schedule notification cho ngày mai
  Future<void> _testScheduleTomorrow() async {
    setState(() => _status = 'Đang schedule cho ngày mai...');

    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final scheduledTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        9, // 9:00 sáng
        0,
      );

      await NotificationService().scheduleReviewNotification(
        courseId: 'test_course_tomorrow',
        cardId: 'test_card_tomorrow',
        nextReviewDate: scheduledTime,
        courseTitle: 'Khóa học Test',
        cardCount: 3,
      );

      await _updatePendingCount();

      setState(() => _status = '✅ Đã schedule cho 9:00 sáng ngày mai!');
    } catch (e) {
      setState(() => _status = '❌ Lỗi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.primary,
      appBar: AppBar(
        title: const Text('Test Notifications'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Status',
                    style: AppTextStyles.textContent1.copyWith(
                      color: context.colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pending notifications: $_pendingCount',
                    style: AppTextStyles.textContent3.copyWith(
                      color: context.colors.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Test buttons
            _buildTestButton(
              icon: Icons.notifications_active,
              title: '1. Test Notification Ngay',
              description: 'Gửi notification ngay lập tức',
              onPressed: _testImmediateNotification,
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            _buildTestButton(
              icon: Icons.schedule,
              title: '2. Schedule Sau 10 Giây',
              description: 'Schedule notification sau 10 giây',
              onPressed: _testScheduleNotification,
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            _buildTestButton(
              icon: Icons.calendar_today,
              title: '3. Schedule Ngày Mai 9:00',
              description: 'Schedule notification cho ngày mai lúc 9:00 sáng',
              onPressed: _testScheduleTomorrow,
              color: Colors.orange,
            ),

            const SizedBox(height: 12),

            _buildTestButton(
              icon: Icons.security,
              title: '4. Request Permissions',
              description: 'Yêu cầu quyền gửi notification',
              onPressed: _testRequestPermissions,
              color: Colors.purple,
            ),

            const SizedBox(height: 12),

            _buildTestButton(
              icon: Icons.info,
              title: '5. Check Enabled',
              description: 'Kiểm tra notifications có bật không',
              onPressed: _testCheckEnabled,
              color: Colors.teal,
            ),

            const SizedBox(height: 12),

            _buildTestButton(
              icon: Icons.toggle_on,
              title: '6. Toggle On/Off',
              description: 'Bật/tắt notifications',
              onPressed: _testToggleNotifications,
              color: Colors.indigo,
            ),

            const SizedBox(height: 12),

            _buildTestButton(
              icon: Icons.delete_sweep,
              title: '7. Cancel All',
              description: 'Hủy tất cả pending notifications',
              onPressed: _testCancelAll,
              color: Colors.red,
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.secondary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.yellow[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hướng dẫn test',
                        style: AppTextStyles.textContent2.copyWith(
                          color: context.colors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Bước 1: Nhấn "Request Permissions" để xin quyền\n'
                    '• Bước 2: Nhấn "Test Notification Ngay" để test\n'
                    '• Bước 3: Check thanh notification của điện thoại\n'
                    '• Bước 4: Test schedule bằng nút 2 hoặc 3\n'
                    '• Lưu ý: App phải đang chạy hoặc background',
                    style: AppTextStyles.textContent3.copyWith(
                      color: context.colors.onPrimary.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.textContent1.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.textContent3.copyWith(
                        color: context.colors.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
