import 'package:card_mind/core/widgets/app_gap.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:card_mind/core/widgets/switch_botton_widget.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/services/data_management_service.dart';
import 'package:card_mind/core/services/notification_service.dart';
import 'package:card_mind/core/services/sample_data_service.dart';
import 'package:card_mind/modules/settings/screen/spaced_repetition_settings_screen.dart';
import 'package:card_mind/providers/auth_provider.dart';
import 'package:provider/provider.dart';
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

  /// Xử lý đăng xuất - Sign out và reset về dữ liệu mặc định
  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    // Hiển thị dialog xác nhận
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Xác nhận đăng xuất',
                style: TextStyle(color: context.colors.onSurface),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất?',
            style: TextStyle(color: context.colors.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Hủy',
                style: TextStyle(color: context.colors.onSurface.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    // Nếu user hủy, không làm gì
    if (confirmed != true) return;

    // Đóng drawer trước
    if (mounted) {
      Navigator.pop(context);
    }

    // Hiển thị loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: context.colors.surface,
            content: Row(
              children: [
                CircularProgressIndicator(
                  color: context.colors.primary,
                ),
                const SizedBox(width: 16),
                Text(
                  'Đang đăng xuất và reset dữ liệu...',
                  style: TextStyle(color: context.colors.onSurface),
                ),
              ],
            ),
          );
        },
      );
    }

    try {
      // 1. Đăng xuất khỏi Google/Firebase
      await authProvider.signOut();

      // 2. Tạo lại dữ liệu mẫu (xóa dữ liệu cũ và tạo mới)
      await SampleDataService.recreateSampleData();

      // Đóng loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã đăng xuất và reset về dữ liệu mặc định'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Restart app để load lại dữ liệu mới
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        await DataManagementService.restartApp(context);
      }
    } catch (e) {
      // Đóng loading dialog nếu có lỗi
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Hiển thị lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng xuất: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                // Chỉ hiển thị nút đăng xuất khi đã đăng nhập
                if (!authProvider.isSignedIn) {
                  return const SizedBox.shrink();
                }

                return _buildDrawerItem(
                  context,
                  icon: Icon(Icons.logout, color: Colors.red),
                  title: 'common.logout'.tr(),
                  iconColor: Colors.red,
                  textStyle: AppTextStyles.textContent2.copyWith(color: Colors.red),
                  onTap: () => _handleLogout(context, authProvider),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isSignedIn = authProvider.isSignedIn;
        final displayName = authProvider.displayName;
        final email = authProvider.email;
        final photoURL = authProvider.photoURL;

        return Row(
          spacing: width_8,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: context.colors.onPrimary.withOpacity(0.1),
              backgroundImage: isSignedIn && photoURL != null
                  ? NetworkImage(photoURL)
                  : null,
              child: !isSignedIn || photoURL == null
                  ? Icon(Icons.person, color: context.colors.onPrimary)
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSignedIn
                        ? "Xin chào, ${displayName ?? 'Người dùng'}!"
                        : "Card mind xin chào!",
                    style: AppTextStyles.textHeader3.copyWith(
                      color: context.colors.onPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isSignedIn
                              ? (email ?? "common.verified_profile".tr())
                              : "common.verified_profile".tr(),
                          style: AppTextStyles.textContent2.copyWith(
                            color: context.colors.onPrimary.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSignedIn) ...[
                        AppGap.w12,
                        Icon(
                          Icons.done_outline_outlined,
                          color: context.colors.onPrimary,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
