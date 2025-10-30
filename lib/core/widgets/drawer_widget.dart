import 'package:card_mind/core/widgets/app_gap.dart';
import 'package:card_mind/modules/settings/screen/notification_settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:card_mind/core/widgets/switch_botton_widget.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/services/data_management_service.dart';
import 'package:card_mind/core/services/notification_service.dart';
import 'package:card_mind/modules/settings/screen/spaced_repetition_settings_screen.dart';
import 'package:card_mind/init.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  Future<void> _loadNotificationStatus() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    try {
      // Cập nhật state ngay
      setState(() {
        _notificationsEnabled = value;
      });

      // Bật/tắt notifications
      await NotificationService().setNotificationsEnabled(value);

      // Nếu BẬT, gửi notification test để user biết
      if (value) {
        await NotificationService().showImmediateNotification(
          title: '✅ Thông báo đã bật',
          body: 'Bạn sẽ nhận được nhắc nhở khi đến giờ ôn tập!',
        );
      }
    } catch (e) {
      print('Error toggling notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: context.colors.primary,
        child: ListView(
          padding: AppPad.v40,
          children: <Widget>[
            Padding(
              padding: AppPad.h20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    backgroundColor: context.colors.onPrimary.withOpacity(0.1),
                    child: Icon(Icons.menu, color: context.colors.onPrimary),
                  ),
                ),
              ),
            ),

            Container(
              padding: AppPad.a20,
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: _buildDrawerHeader(context),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDrawerItem(
                    context,
                    icon: Icon(
                      Icons.nightlight,
                      color: context.colors.onPrimary,
                    ),
                    title: 'common.dark_mode'.tr(),
                    onTap: () => Navigator.pop(context),
                    // onTap: () => Navigator.pushNamed(context, NotificationSettingsScreen.routeName),
                  ),
                ),
                Padding(
                  padding: AppPad.h10,
                  child: SwitchBottomWidget(onChanged: (value) {}),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDrawerItem(
                    context,
                    icon: Icon(
                      Icons.notifications_active,
                      color: context.colors.onPrimary,
                    ),
                    title: 'Nhắc nhở ôn tập',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Padding(
                  padding: AppPad.h10,
                  child: Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
            _buildDrawerItem(
              context,
              icon: Icon(
                Icons.schedule,
                color: context.colors.onPrimary,
              ),
              title: 'Cài đặt Spaced Repetition',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  SpacedRepetitionSettingsScreen.routeName,
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icon(Icons.delete_forever, color: Colors.red),
              title: 'Xóa dữ liệu'.tr(),
              iconColor: Colors.red,
              textStyle: AppTextStyles.textContent2.copyWith(color: Colors.red),
              onTap: () async {
                await DataManagementService.handleDeleteData(context);
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icon(Icons.logout, color: Colors.red),
              title: 'common.logout'.tr(),
              iconColor: Colors.red,
              textStyle: AppTextStyles.textContent2.copyWith(color: Colors.red),
              onTap: () async {
                print("Logout");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Row(
      spacing: width_8,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: context.colors.onPrimary.withOpacity(0.1),
          child: Icon(Icons.person, color: context.colors.onPrimary),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Card mind xin chào!",
              style: AppTextStyles.textHeader3.copyWith(
                color: context.colors.onPrimary,
              ),
            ),
            Row(
              children: [
                Text(
                  "common.verified_profile".tr(),
                  style: AppTextStyles.textContent2.copyWith(
                    color: context.colors.onPrimary.withOpacity(0.7),
                  ),
                ),
                AppGap.w12,
                Icon(
                  Icons.done_outline_outlined,
                  color: context.colors.onPrimary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required Widget icon,
    required String title,
    required VoidCallback onTap,
    TextStyle? textStyle,
    Color? iconColor,
  }) {
    return ListTile(
      leading: icon,
      title: Text(
        title,
        style:
            textStyle ??
            AppTextStyles.textContent2.copyWith(
              color: context.colors.onPrimary,
            ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      dense: true,
    );
  }
}
