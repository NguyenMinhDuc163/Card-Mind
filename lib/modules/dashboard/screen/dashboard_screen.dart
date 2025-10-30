import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/modules/create_course/screen/create_course_screen.dart';
import 'package:card_mind/modules/home/screen/home_screen.dart';
import 'package:card_mind/modules/home/provider/home_notifier.dart';
import 'package:card_mind/modules/library/screen/library_screen.dart';
import 'package:card_mind/modules/library/provider/content_notifier.dart';
import 'package:card_mind/modules/message/screen/chat_bot_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:card_mind/core/widgets/drawer_widget.dart';
import 'package:card_mind/modules/dashboard/model/tab_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const String routeName = '/dashboardScreen';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

final List<TabItem> _tabs = [
  TabItem(widget: HomeScreen(), route: HomeScreen.routeName),
  TabItem(widget: CreateCourseScreen(), route: CreateCourseScreen.routeName),
  TabItem(widget: ChatBotScreen(), route: ChatBotScreen.routeName),
  TabItem(widget: LibraryScreen(), route: LibraryScreen.routeName),
];

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Public method để switch tab từ các screen khác
  void switchToTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      setState(() {
        _currentIndex = index;
      });
      _refreshCurrentTab();
    }
  }

  void _refreshCurrentTab() {
    // Refresh data khi switch tab
    if (_currentIndex == 0) {
      // Home tab - refresh HomeNotifier
      try {
        final homeNotifier = Provider.of<HomeNotifier>(context, listen: false);
        homeNotifier.initializeData();
      } catch (e) {
        print('Error refreshing HomeNotifier: $e');
      }
    } else if (_currentIndex == 3) {
      // Library tab - refresh ContentNotifier
      try {
        final contentNotifier = Provider.of<ContentNotifier>(context, listen: false);
        contentNotifier.initializeData();
      } catch (e) {
        print('Error refreshing ContentNotifier: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: context.colors.primary,
          systemNavigationBarContrastEnforced: false,
        ),
        child: Scaffold(
          backgroundColor: context.colors.primary,
          drawer: DrawerWidget(),
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs.map((tab) => tab.widget).toList(),
          ),
          bottomNavigationBar: SalomonBottomBar(
            currentIndex: _currentIndex,
            selectedColorOpacity: 0.0,
            backgroundColor: Colors.transparent,
            duration: Duration.zero,
            unselectedItemColor: context.colors.onPrimary.withOpacity(0.6),
            selectedItemColor: context.colors.onPrimary,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              print('====>: ${_tabs[index].route}');
              // Refresh data khi switch về Home hoặc Library
              _refreshCurrentTab();
            },
            items: [
              SalomonBottomBarItem(
                icon: Icon(Icons.home),
                title: Text("Trang chủ".tr()),
                // activeIcon: SizedBox.shrink(),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.add),
                title: Text("Tạo".tr()),
                // activeIcon: SizedBox.shrink(),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.chat),
                title: Text("Chat".tr()),
                // activeIcon: SizedBox.shrink(),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.folder_copy_rounded),
                title: Text("Thư viện".tr()),
                // activeIcon: SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
