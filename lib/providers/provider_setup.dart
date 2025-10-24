import 'package:card_mind/modules/create_course/provider/create_course_notifier.dart';
import 'package:card_mind/modules/home/provider/home_notifier.dart';
import 'package:card_mind/modules/course/provider/course_info_notifier.dart';
import 'package:card_mind/modules/course/provider/course_result_notifier.dart';
import 'package:card_mind/modules/course/provider/detail_flash_card_notifier.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ProviderSetup {
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider(create: (_) => CreateCourseNotifier()),
      ChangeNotifierProvider(create: (_) => HomeNotifier()),
      ChangeNotifierProvider(create: (_) => CourseInfoNotifier()),
      ChangeNotifierProvider(create: (_) => CourseResultNotifier()),
      ChangeNotifierProvider(create: (_) => DetailFlashCardNotifier()),
    ];
  }
}
