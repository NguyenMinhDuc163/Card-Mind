import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/library/model/class_data.dart';
import 'package:card_mind/modules/library/provider/class_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateClassBottomSheet extends StatefulWidget {
  const CreateClassBottomSheet({super.key});

  @override
  State<CreateClassBottomSheet> createState() => _CreateClassBottomSheetState();
}

class _CreateClassBottomSheetState extends State<CreateClassBottomSheet> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Set<String> _selectedContentIds = {};

  @override
  void dispose() {
    _classNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createClass() {
    if (_classNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên lớp học')));
      return;
    }

    final classData = ClassData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      className: _classNameController.text.trim(),
      description: _descriptionController.text.trim(),
      instructor: 'User',
      totalStudents: _selectedContentIds.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'active',
      students: _selectedContentIds.toList(),
    );

    final notifier = Provider.of<ClassNotifier>(context, listen: false);
    notifier.saveClass(classData);

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã tạo lớp học thành công!')));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassNotifier>(
      builder: (context, notifier, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.onPrimary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Tạo lớp học mới',
                style: AppTextStyles.textHeader3.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Tên lớp học',
                style: AppTextStyles.textContent2.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _classNameController,
                style: AppTextStyles.textContent2.copyWith(color: context.colors.onPrimary),
                decoration: InputDecoration(
                  hintText: 'Nhập tên lớp học...',
                  hintStyle: AppTextStyles.textContent2.copyWith(
                    color: context.colors.onPrimary.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: context.colors.onPrimary.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: AppPad.h16v12,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Mô tả (tùy chọn)',
                style: AppTextStyles.textContent2.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                style: AppTextStyles.textContent2.copyWith(color: context.colors.onPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập mô tả cho lớp học...',
                  hintStyle: AppTextStyles.textContent2.copyWith(
                    color: context.colors.onPrimary.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: context.colors.onPrimary.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: AppPad.h16v12,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Chọn học phần',
                style: AppTextStyles.textContent2.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              if (notifier.availableContents.isEmpty)
                Container(
                  padding: AppPad.h16v20,
                  decoration: BoxDecoration(
                    color: context.colors.onPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: context.colors.onPrimary.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Chưa có học phần nào. Hãy tạo học phần trước.',
                          style: AppTextStyles.textContent3.copyWith(
                            color: context.colors.onPrimary.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: context.colors.onPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.onPrimary.withOpacity(0.2)),
                  ),
                  child: ListView.builder(
                    padding: AppPad.h12v8,
                    itemCount: notifier.availableContents.length,
                    itemBuilder: (context, index) {
                      final content = notifier.availableContents[index];
                      final isSelected = _selectedContentIds.contains(content.id);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedContentIds.remove(content.id);
                            } else {
                              _selectedContentIds.add(content.id);
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: AppPad.h12v8,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? context.colors.onPrimary.withOpacity(0.2)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? context.colors.onPrimary
                                      : context.colors.onPrimary.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                color:
                                    isSelected
                                        ? context.colors.onPrimary
                                        : context.colors.onPrimary.withOpacity(0.5),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      content.title,
                                      style: AppTextStyles.textContent3.copyWith(
                                        color: context.colors.onPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${content.totalTerms} thuật ngữ',
                                      style: AppTextStyles.textContent4.copyWith(
                                        color: context.colors.onPrimary.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: AppPad.h16v12,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Hủy',
                        style: AppTextStyles.textContent2.copyWith(
                          color: context.colors.onPrimary.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _createClass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.onPrimary,
                        foregroundColor: context.colors.primary,
                        padding: AppPad.h16v12,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Tạo lớp học',
                        style: AppTextStyles.textContent2.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
