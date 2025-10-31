import 'package:card_mind/core/widgets/app_gap.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:card_mind/core/widgets/switch_botton_widget.dart';
import 'package:card_mind/core/widgets/switch_Lang.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/locale_cubit.dart';
import 'package:card_mind/core/services/data_management_service.dart';
import 'package:card_mind/core/services/notification_service.dart';
import 'package:card_mind/core/services/data_sync_service.dart';
import 'package:card_mind/modules/settings/screen/spaced_repetition_settings_screen.dart';
import 'package:card_mind/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    if (confirmed != true || !mounted) return;

    // Đóng drawer trước
    Navigator.pop(context);

    // Perform logout
    await _performLogout(context, authProvider);
  }

  /// Thực hiện logout (tách riêng để tránh BuildContext issues)
  Future<void> _performLogout(BuildContext context, AuthProvider authProvider) async {
    try {
      // Đồng bộ dữ liệu lên Firestore TRƯỚC KHI đăng xuất (chạy im lặng)
      print('🔄 [Drawer] Syncing data before logout...');
      await DataSyncService().syncAllData();
      print('✅ [Drawer] Data synced successfully');

      // Đăng xuất khỏi Google/Firebase (cũng clear local và load sample)
      await authProvider.signOut();
      print('✅ [Drawer] Signed out successfully');

      print('✅ [Drawer] Logout completed - UI will auto-refresh via auth listeners');
    } catch (e) {
      print('❌ [Drawer] Logout error: $e');

      // Chỉ hiển thị lỗi nếu có vấn đề
      if (mounted && context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext errorContext) {
            return AlertDialog(
              backgroundColor: context.colors.surface,
              title: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    'Lỗi',
                    style: TextStyle(color: context.colors.onSurface),
                  ),
                ],
              ),
              content: Text(
                'Lỗi khi đăng xuất: $e',
                style: TextStyle(color: context.colors.onSurface),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(errorContext).pop(),
                  child: Text('Đóng'),
                ),
              ],
            );
          },
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
                      color: context
                          .colors.onPrimary,
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
            // Language switcher
            Row(
              children: [
                Expanded(
                  child: _buildDrawerItem(
                    context,
                    icon: Icon(
                      Icons.language,
                      color: context.colors.onPrimary,
                    ),
                    title: 'common.language'.tr(),
                    onTap: () {
                      // Toggle ngôn ngữ khi tap vào item
                      final localeCubit = context.read<LocaleCubit>();
                      localeCubit.toggleLocale(context);
                    },
                  ),
                ),
                Padding(
                  padding: AppPad.h10,
                  child: BlocBuilder<LocaleCubit, Locale>(
                    builder: (context, locale) {
                      final isEnglish = locale.languageCode == 'en';
                      return SwitchLang(
                        onTap: () {
                          final localeCubit = context.read<LocaleCubit>();
                          localeCubit.toggleLocale(context);
                        },
                        isEnglish: isEnglish,
                        colorText: context.colors.onPrimary,
                        colorBackground: context.colors.onPrimary.withOpacity(0.1),
                      );
                    },
                  ),
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
              title: 'Cài đặt',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  SpacedRepetitionSettingsScreen.routeName,
                );
              },
            ),
            // _buildDrawerItem(
            //   context,
            //   icon: Icon(Icons.delete_forever, color: Colors.red),
            //   title: 'Xóa dữ liệu'.tr(),
            //   iconColor: Colors.red,
            //   textStyle: AppTextStyles.textContent2.copyWith(color: Colors.red),
            //   onTap: () async {
            //     await DataManagementService.handleDeleteData(context);
            //   },
            // ),
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
