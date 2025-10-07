import 'package:card_mind/modules/home/screen/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:card_mind/core/constants/icon_path.dart';
import 'package:card_mind/core/theme/app_colors.dart';
import 'package:card_mind/core/widgets/drawer_widget.dart';
import 'package:card_mind/modules/dashboard/model/tab_item.dart';
import 'package:card_mind/modules/home/screen/home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const String routeName = '/dashboardScreen';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

final List<TabItem> _tabs = [
  TabItem(widget: HomeScreen(), route: HomeScreen.routeName),
  TabItem(widget: HomeScreen(), route: HomeScreen.routeName),
  TabItem(widget: HomeScreen(), route: HomeScreen.routeName),
  TabItem(widget: HomeScreen(), route: HomeScreen.routeName),
];

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: AppColors.white,
          systemNavigationBarContrastEnforced:false,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          drawer: DrawerWidget() ,
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs.map((tab) => tab.widget).toList(),
          ),
          bottomNavigationBar: SalomonBottomBar(
            currentIndex: _currentIndex,
            selectedColorOpacity: 0.0,
            backgroundColor: Colors.transparent,
            duration: Duration.zero,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              print('====>: ${_tabs[index].route}');
            },
            items: [
              SalomonBottomBarItem(
                icon: Icon(Icons.home),
                title: Text("home_screen.home".tr()),
                activeIcon: SizedBox.shrink(),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.wallet_giftcard),
                title: Text("home_screen.wishlist".tr()),
                activeIcon: SizedBox.shrink(),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.shopping_cart),
                title: Text("home_screen.cart".tr()),
                activeIcon: SizedBox.shrink(),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.wallet),
                title: Text("home_screen.wallet".tr()),
                activeIcon: SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
