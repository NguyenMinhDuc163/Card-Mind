import 'package:card_mind/core/widgets/app_gap.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:card_mind/core/widgets/switch_botton_widget.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/services/data_management_service.dart';
import 'package:card_mind/init.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

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
                  ),
                ),
                Padding(
                  padding: AppPad.h10,
                  child: SwitchBottomWidget(onChanged: (value) {}),
                ),
              ],
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
              "Xin chào",
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
