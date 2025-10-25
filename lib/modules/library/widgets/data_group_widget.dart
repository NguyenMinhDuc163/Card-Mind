import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';

class DataGroupWidget extends StatelessWidget {
  const DataGroupWidget({super.key, required this.date, required this.items});
  final String date;
  final List<Widget> items;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: AppTextStyles.textContent1.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );;
  }
}
