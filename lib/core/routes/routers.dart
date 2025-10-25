import 'package:card_mind/core/public/global_utils.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
import 'package:card_mind/core/widgets/template/function_screen_template.dart';
import 'package:card_mind/modules/auth/initial/screen/splash_screen.dart';
import 'package:card_mind/modules/course/screen/course_info_screen.dart';
import 'package:card_mind/modules/course/screen/course_result_screen.dart';
import 'package:card_mind/modules/course/screen/detail_flash_card_screen.dart';
import 'package:card_mind/modules/course/screen/test_screen.dart';
import 'package:card_mind/modules/course/screen/test_result_screen.dart';
import 'package:card_mind/modules/course/screen/edit_course_screen.dart';
import 'package:card_mind/modules/create_course/screen/create_course_screen.dart';
import 'package:card_mind/modules/dashboard/screen/dashboard_screen.dart';
import 'package:card_mind/modules/home/screen/global_search_screen.dart';
import 'package:card_mind/modules/library/screen/library_screen.dart';
import 'package:card_mind/modules/library/screen/class_detail_screen.dart';
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
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case DashboardScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DashboardScreen(),
        );
      case CourseInfoScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CourseInfoScreen(),
        );
      case DetailFlashCardScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DetailFlashCardScreen(),
        );
      case TestScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TestScreen(),
        );
      case TestResultScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TestResultScreen(),
        );
      case EditCourseScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const EditCourseScreen(),
        );
      case CourseResultScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CourseResultScreen(),
        );
      case LibraryScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LibraryScreen(),
        );
      case CreateCourseScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CreateCourseScreen(),
        );
      case ClassDetailScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ClassDetailScreen(),
        );
      case GlobalSearchScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const GlobalSearchScreen(),
        );

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
