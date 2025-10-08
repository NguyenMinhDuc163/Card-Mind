import 'package:flutter/material.dart';
import 'screen/course_info_screen.dart';

class CourseModule {
  static const String routeName = '/course';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/course':
        return MaterialPageRoute(
          builder: (_) => const CourseInfoScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const CourseInfoScreen(),
          settings: settings,
        );
    }
  }
}
