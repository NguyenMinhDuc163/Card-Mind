import 'package:card_mind/core/widgets/theme_demo_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:card_mind/init.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen();
  static const String routeName = '/HomeScreen';
  @override
  Widget build(BuildContext context) {
    return FunctionScreenTemplate(
      isShowBottomButton: false,
      isShowAppBar: true,
      isShowDrawer: true,
      actionsWidget: [GestureDetector(onTap: () => {}, child: SvgPicture.asset(IconPath.iconBag))],
      screen: Container(),
    );
  }
}
