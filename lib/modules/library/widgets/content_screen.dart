import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/library/widgets/content_item_widget.dart';
import 'package:card_mind/modules/library/widgets/data_group_widget.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key, required this.tabType});
  final String tabType;
  @override
  Widget build(BuildContext context) {
    return FunctionScreenTemplate(
      backgroundColor: context.colors.primary,
      screen: SingleChildScrollView(
        padding: AppPad.h16v8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DataGroupWidget(date: 'Tuần này', items: [
              ContentItemWidget(
                title: 'Thông tin cơ bản về Card Mind',
                details: '9 thuật ngữ • Tác giả: Card Mind',
                tabType: tabType,
              ),

            ]),
            const SizedBox(height: 24),
            DataGroupWidget(date: 'Tuần này', items: [
              ContentItemWidget(
                title: 'Thông tin cơ bản về Card Mind',
                details: '9 thuật ngữ • Tác giả: Card Mind',
                tabType: tabType,
              ),

            ]),
            const SizedBox(height: 24),
            DataGroupWidget(date: 'Tuần này', items: [
              ContentItemWidget(
                title: 'Thông tin cơ bản về Card Mind',
                details: '9 thuật ngữ • Tác giả: Card Mind',
                tabType: tabType,
              ),

            ]),
            const SizedBox(height: 40),
          ],
        ),
      ) ,
    );
  }
}
