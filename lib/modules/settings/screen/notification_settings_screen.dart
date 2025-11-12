import 'package:card_mind/core/services/notification_service.dart';
import 'package:card_mind/core/config/notification_config.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  static const String routeName = '/NotificationSettingsScreen';

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _notificationService = NotificationService();

  bool _notificationsEnabled = true;
  bool _dailyRemindersEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final notifEnabled = await _notificationService.areNotificationsEnabled();
      final dailyEnabled = await _notificationService.areDailyRemindersEnabled();

      setState(() {
        _notificationsEnabled = notifEnabled;
        _dailyRemindersEnabled = dailyEnabled;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notification settings: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    await _notificationService.setNotificationsEnabled(enabled);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Đã bật thông báo ôn tập'
                : 'Đã tắt thông báo ôn tập',
          ),
          backgroundColor: context.brandColors.progressValue,
        ),
      );
    }
  }

  Future<void> _toggleDailyReminders(bool enabled) async {
    setState(() => _dailyRemindersEnabled = enabled);
    await _notificationService.setDailyRemindersEnabled(enabled);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Đã bật nhắc nhở hàng ngày (sáng, trưa, tối)'
                : 'Đã tắt nhắc nhở hàng ngày',
          ),
          backgroundColor: context.brandColors.progressValue,
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    await _notificationService.showImmediateNotification(
      title: '📚 Test Notification',
      body: 'Thông báo của bạn đang hoạt động tốt! 🎉',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã gửi thông báo thử nghiệm'),
          backgroundColor: context.brandColors.progressValue,
        ),
      );
    }
  }

  Future<void> _rescheduleAllNotifications() async {
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Đang reschedule...'),
          ],
        ),
      ),
    );

    try {
      
      await _notificationService.rescheduleAllReviewNotifications();
      await _notificationService.scheduleDailyReminders();

      
      if (mounted) Navigator.pop(context);

      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã reschedule tất cả notifications thành công!'),
            backgroundColor: context.brandColors.progressValue,
          ),
        );
      }
    } catch (e) {
      
      if (mounted) Navigator.pop(context);

      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: context.brandColors.buttonDestructive,
          ),
        );
      }
    }
  }

  Future<void> _showPendingNotifications() async {
    final pending = await _notificationService.getPendingNotifications();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thông báo đang chờ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Có ${pending.length} thông báo đang được lên lịch:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              if (pending.isEmpty)
                Text('Không có thông báo nào')
              else
                ...pending.map((notif) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${notif.id}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(notif.title ?? 'No title'),
                          Text(
                            notif.body ?? 'No body',
                            style: TextStyle(fontSize: 12),
                          ),
                          Divider(),
                        ],
                      ),
                    )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt Thông báo'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                
                _buildSectionHeader('Thông báo Ôn tập'),
                SizedBox(height: 8),
                Text(
                  'Nhận thông báo khi có thẻ cần ôn tập theo lịch spaced repetition',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),

                
                _buildSwitchTile(
                  title: 'Thông báo ôn tập',
                  subtitle: 'Nhắc nhở khi có thẻ cần ôn tập',
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  icon: Icons.notifications_active,
                ),

                Divider(height: 32),

                
                _buildSectionHeader('Nhắc nhở Hàng ngày'),
                SizedBox(height: 8),
                Text(
                  'Nhận tin nhắn vui nhộn 3 lần/ngày để khuyến khích học tập',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),

                
                _buildSwitchTile(
                  title: 'Nhắc nhở hàng ngày',
                  subtitle: 'Sáng (${NotificationConfig.morningReminderHour}:00), '
                      'Trưa (${NotificationConfig.afternoonReminderHour}:00), '
                      'Tối (${NotificationConfig.eveningReminderHour}:00)',
                  value: _dailyRemindersEnabled,
                  onChanged: _toggleDailyReminders,
                  icon: Icons.schedule,
                ),

                
                if (_dailyRemindersEnabled) ...[
                  SizedBox(height: 16),
                  _buildMessagesPreview(),
                ],

                Divider(height: 32),

                
                _buildBatteryOptimizationWarning(),

                Divider(height: 32),

                
                _buildSectionHeader('Công cụ Debug'),
                SizedBox(height: 16),

                
                _buildActionButton(
                  title: 'Gửi thông báo thử nghiệm',
                  icon: Icons.send,
                  onPressed: _testNotification,
                ),
                SizedBox(height: 12),

                
                _buildActionButton(
                  title: 'Xem thông báo đang chờ',
                  icon: Icons.list,
                  onPressed: _showPendingNotifications,
                ),
                SizedBox(height: 12),

                
                _buildActionButton(
                  title: 'Reschedule tất cả notifications',
                  icon: Icons.refresh,
                  onPressed: _rescheduleAllNotifications,
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: context.brandColors.textPrimary,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: context.brandColors.buttonPrimary),
      ),
    );
  }

  Widget _buildMessagesPreview() {
    return Card(
      color: context.brandColors.buttonPrimary.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 20),
                SizedBox(width: 8),
                Text(
                  'Ví dụ tin nhắn:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildMessageExample(
              '☀️ Sáng',
              NotificationConfig.morningMessages.first,
            ),
            SizedBox(height: 8),
            _buildMessageExample(
              '🌤️ Trưa',
              NotificationConfig.afternoonMessages.first,
            ),
            SizedBox(height: 8),
            _buildMessageExample(
              '🌙 Tối',
              NotificationConfig.eveningMessages.first,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageExample(String time, String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildBatteryOptimizationWarning() {
    return Card(
      color: context.brandColors.warning.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.battery_alert, color: context.brandColors.warning),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quan trọng: Battery Optimization',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.brandColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Để nhận thông báo khi app ở chế độ nền:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            _buildWarningStep('1', 'Mở Settings → Apps → Card Mind'),
            SizedBox(height: 4),
            _buildWarningStep('2', 'Chọn "Battery" → "Unrestricted"'),
            SizedBox(height: 4),
            _buildWarningStep('3', 'Hoặc tắt "Battery optimization" cho app này'),
            SizedBox(height: 12),
            Text(
              '💡 App sẽ tự động reschedule notifications mỗi khi mở lại.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: context.brandColors.warning,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        backgroundColor: context.brandColors.buttonPrimary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
