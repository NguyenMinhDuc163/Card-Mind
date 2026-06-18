import 'dart:async';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
import 'package:card_mind/modules/create_course/screen/create_course_screen.dart';
import 'package:card_mind/modules/home/screen/home_screen.dart';
import 'package:card_mind/modules/home/provider/home_notifier.dart';
import 'package:card_mind/modules/library/screen/library_screen.dart';
import 'package:card_mind/modules/library/provider/content_notifier.dart';
import 'package:card_mind/modules/message/screen/chat_bot_screen.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:card_mind/core/widgets/drawer_widget.dart';
import 'package:card_mind/modules/dashboard/model/tab_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  static const String _aiConsentStorageKey = 'ai_chatbot_data_consent_v1';
  static const int _homeTabIndex = 0;
  static const int _chatTabIndex = 2;

  int _currentIndex = 0;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthStateListener();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _setupAuthStateListener() {
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) {
      print(
        '🔐 [Dashboard] Auth state changed: ${user != null ? "Logged in" : "Logged out"}',
      );

      _refreshAllTabs();
    });
  }

  void _refreshAllTabs() {
    try {
      final homeNotifier = Provider.of<HomeNotifier>(context, listen: false);
      homeNotifier.initializeData();
      print('✅ [Dashboard] Refreshed HomeNotifier');
    } catch (e) {
      print('❌ [Dashboard] Error refreshing HomeNotifier: $e');
    }

    try {
      final contentNotifier = Provider.of<ContentNotifier>(
        context,
        listen: false,
      );
      contentNotifier.initializeData();
      print('✅ [Dashboard] Refreshed ContentNotifier');
    } catch (e) {
      print('❌ [Dashboard] Error refreshing ContentNotifier: $e');
    }
  }

  Future<void> switchToTab(int index) async {
    if (index >= 0 && index < _tabs.length) {
      if (index == _chatTabIndex) {
        final canOpenChat = await _ensureAiConsent();
        if (!canOpenChat) return;
        if (!mounted) return;
      }

      setState(() {
        _currentIndex = index;
      });
      _refreshCurrentTab();
    }
  }

  Future<void> _handleTabTap(int index) async {
    if (index == _chatTabIndex) {
      final canOpenChat = await _ensureAiConsent();
      if (!canOpenChat) {
        if (!mounted) return;
        setState(() {
          _currentIndex = _homeTabIndex;
        });
        _refreshCurrentTab();
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _currentIndex = index;
    });
    print('====>: ${_tabs[index].route}');

    _refreshCurrentTab();
  }

  Future<bool> _ensureAiConsent() async {
    final hasConsent =
        LocalStorageHelper.getValue(_aiConsentStorageKey) as bool? ?? false;
    if (hasConsent) return true;

    final confirmed = await _showAiConsentDialog();
    if (confirmed == true) {
      LocalStorageHelper.setValue(_aiConsentStorageKey, true);
      return true;
    }

    return false;
  }

  Future<bool?> _showAiConsentDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.brandColors.cardBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: context.brandColors.borderColor.withValues(alpha: 0.25),
            ),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: context.brandColors.avatarBackground,
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: context.brandColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'message.chat_bot.consent.title'.tr(),
                  style: AppTextStyles.textHeader3.copyWith(
                    color: context.brandColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'message.chat_bot.consent.description'.tr(),
                style: AppTextStyles.textContent2.copyWith(
                  color: context.brandColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              _AiConsentPoint(text: 'message.chat_bot.consent.data_sent'.tr()),
              const SizedBox(height: 8),
              _AiConsentPoint(text: 'message.chat_bot.consent.sent_to'.tr()),
              const SizedBox(height: 8),
              _AiConsentPoint(text: 'message.chat_bot.consent.permission'.tr()),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'message.chat_bot.consent.cancel'.tr(),
                style: AppTextStyles.textContent2.copyWith(
                  color: context.brandColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.brandColors.buttonPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'message.chat_bot.consent.confirm'.tr(),
                style: AppTextStyles.textContent2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _refreshCurrentTab() {
    if (_currentIndex == 0) {
      try {
        final homeNotifier = Provider.of<HomeNotifier>(context, listen: false);
        homeNotifier.initializeData();
      } catch (e) {
        print('Error refreshing HomeNotifier: $e');
      }
    } else if (_currentIndex == 3) {
      try {
        final contentNotifier = Provider.of<ContentNotifier>(
          context,
          listen: false,
        );
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
            unselectedItemColor: context.colors.onPrimary.withValues(
              alpha: 0.6,
            ),
            selectedItemColor: context.colors.onPrimary,
            onTap: _handleTabTap,
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home),
                title: Text("dashboard.home".tr()),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.add),
                title: Text("dashboard.create".tr()),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.chat),
                title: Text("dashboard.chat".tr()),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.folder_copy_rounded),
                title: Text("dashboard.library".tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiConsentPoint extends StatelessWidget {
  final String text;

  const _AiConsentPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 18,
          color: context.brandColors.buttonPrimary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.textContent3.copyWith(
              color: context.brandColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
