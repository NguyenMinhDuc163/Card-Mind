import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/library/model/content_data.dart';
import 'package:card_mind/modules/course/screen/course_info_screen.dart';
import 'package:flutter/material.dart';

class ContentItemWidget extends StatelessWidget {
  const ContentItemWidget({
    super.key,
    required this.title,
    required this.details,
    required this.tabType,
    this.contentData,
  });
  final String title;
  final String details;
  final String tabType;
  final ContentData? contentData;

  void _navigateToCourseInfo(BuildContext context) {
    if (contentData != null) {
      Navigator.pushNamed(
        context,
        CourseInfoScreen.routeName,
        arguments: contentData!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToCourseInfo(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: AppPad.h16v12,
        decoration: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.onPrimary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.onPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.credit_card,
                color: context.colors.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details,
                    style: AppTextStyles.textContent3.copyWith(
                      color: context.colors.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.colors.onPrimary.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
