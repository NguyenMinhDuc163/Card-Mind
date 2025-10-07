import 'package:card_mind/core/public/global_utils.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
import 'package:card_mind/core/widgets/template/function_screen_template.dart';
import 'package:card_mind/modules/auth/initial/screen/splash_screen.dart';
import 'package:card_mind/modules/dashboard/screen/dashboard_screen.dart';
import 'package:flutter/material.dart';

//part of in dart
class Routers {
  static Map<String, WidgetBuilder> routes = {
    // router khong cần truyền tham số
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    GlobalUtils.ROUTES = settings.name;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(settings: settings, builder: (_) => const SplashScreen());
      case DashboardScreen.routeName:
        return MaterialPageRoute(settings: settings, builder: (_) => DashboardScreen());

      default:
        return MaterialPageRoute(
          settings: settings,
          builder:
              (_) => FunctionScreenTemplate(
            title: "Chức năng đang trong quá trình phát triển",
            isShowBottomButton: false,
            screen: Center(
              child: Text(
                "Chức năng đang trong quá trình phát triển",
                style: AppTextStyles.text,
              ),
            ),
          ),
        );
    }
  }
}
