import 'package:card_mind/modules/create_course/provider/create_course_notifier.dart';
import 'package:card_mind/modules/home/provider/home_notifier.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ProviderSetup {
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider(create: (_) => CreateCourseNotifier()),
      ChangeNotifierProvider(create: (_) => HomeNotifier()),
    ];
  }
}
