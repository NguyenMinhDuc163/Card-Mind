import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/library/model/class_data.dart';
import 'package:card_mind/modules/library/screen/class_detail_screen.dart';
import 'package:flutter/material.dart';

class ClassItemWidget extends StatelessWidget {
  const ClassItemWidget({
    super.key,
    required this.classData,
    this.onTap,
    this.onDelete,
  });

  final ClassData classData;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  void _navigateToClassDetail(BuildContext context) {
    Navigator.pushNamed(
      context,
      ClassDetailScreen.routeName,
      arguments: classData.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _navigateToClassDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: AppPad.h16v20,
        decoration: BoxDecoration(
          color: context.colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.onPrimary.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.onPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school,
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
                        classData.className,
                        style: AppTextStyles.textContent1.copyWith(
                          color: context.colors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        classData.description,
                        style: AppTextStyles.textContent3.copyWith(
                          color: context.colors.onPrimary.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: context.colors.onPrimary.withOpacity(0.6),
                    size: 20,
                  ),
                  onSelected: (value) {
                    if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text('Xóa Chủ đề'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: context.colors.onPrimary.withOpacity(0.6),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${classData.totalStudents} học sinh',
                  style: AppTextStyles.textContent3.copyWith(
                    color: context.colors.onPrimary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 24),
                Icon(
                  Icons.library_books,
                  color: context.colors.onPrimary.withOpacity(0.6),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${classData.students.length} học phần',
                  style: AppTextStyles.textContent3.copyWith(
                    color: context.colors.onPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            if (classData.students.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    classData.students.take(3).map((studentId) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.onPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Học phần ${studentId.substring(0, 6)}...',
                          style: AppTextStyles.textContent4.copyWith(
                            color: context.colors.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              if (classData.students.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${classData.students.length - 3} học phần khác',
                    style: AppTextStyles.textContent4.copyWith(
                      color: context.colors.onPrimary.withOpacity(0.6),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
