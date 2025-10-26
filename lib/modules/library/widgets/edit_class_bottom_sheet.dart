import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/library/model/class_data.dart';
import 'package:card_mind/modules/library/provider/class_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditClassBottomSheet extends StatefulWidget {
  const EditClassBottomSheet({super.key, required this.classData});

  final ClassData classData;

  @override
  State<EditClassBottomSheet> createState() => _EditClassBottomSheetState();
}

class _EditClassBottomSheetState extends State<EditClassBottomSheet> {
  late TextEditingController _classNameController;
  late TextEditingController _descriptionController;
  late Set<String> _selectedContentIds;

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController(text: widget.classData.className);
    _descriptionController = TextEditingController(text: widget.classData.description);
    _selectedContentIds = Set<String>.from(widget.classData.students);
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateClass() {
    if (_classNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên Chủ đề')));
      return;
    }

    final updatedClassData = widget.classData.copyWith(
      className: _classNameController.text.trim(),
      description: _descriptionController.text.trim(),
      students: _selectedContentIds.toList(),
      totalStudents: _selectedContentIds.length,
      updatedAt: DateTime.now(),
    );

    final notifier = Provider.of<ClassNotifier>(context, listen: false);
    notifier.saveClass(updatedClassData);

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã cập nhật Chủ đề!')));
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
                'Chỉnh sửa Chủ đề',
                style: AppTextStyles.textHeader3.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Tên Chủ đề',
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
                  hintText: 'Nhập tên Chủ đề...',
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
                  hintText: 'Nhập mô tả cho Chủ đề...',
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
                'Học phần trong Chủ đề',
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
                      onPressed: _updateClass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.onPrimary,
                        foregroundColor: context.colors.primary,
                        padding: AppPad.h16v12,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cập nhật',
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
