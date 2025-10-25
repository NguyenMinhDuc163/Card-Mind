import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/library/provider/class_notifier.dart';
import 'package:card_mind/modules/library/widgets/class_item_widget.dart';
import 'package:card_mind/modules/library/widgets/create_class_bottom_sheet.dart';
import 'package:card_mind/modules/library/widgets/data_group_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key, this.searchQuery = ''});
  final String searchQuery;

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void didUpdateWidget(ClassScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      Future.microtask(() {
        if (mounted) {
          _performSearch();
        }
      });
    }
  }

  Future<void> _initializeData() async {
    final notifier = Provider.of<ClassNotifier>(context, listen: false);
    await notifier.initializeData();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _performSearch() {
    final notifier = Provider.of<ClassNotifier>(context, listen: false);
    notifier.searchClasses(widget.searchQuery);
  }

  void _showCreateClassBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateClassBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassNotifier>(
      builder: (context, notifier, child) {
        if (!_isInitialized || notifier.isLoading) {
          return FunctionScreenTemplate(
            backgroundColor: context.colors.primary,
            screen: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (notifier.hasError) {
          return FunctionScreenTemplate(
            backgroundColor: context.colors.primary,
            screen: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: context.colors.onPrimary, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    notifier.errorMessage ?? 'Có lỗi xảy ra',
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: context.colors.primary,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: AppPad.h16v8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notifier.classes.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school,
                              color: context.colors.onPrimary.withOpacity(0.5),
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có lớp học nào',
                              style: AppTextStyles.textContent2.copyWith(
                                color: context.colors.onPrimary.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tạo lớp học đầu tiên của bạn',
                              style: AppTextStyles.textContent3.copyWith(
                                color: context.colors.onPrimary.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      DataGroupWidget(
                        date: 'Lớp học của tôi',
                        items:
                            notifier.classes.reversed.map((classData) {
                              return ClassItemWidget(
                                classData: classData,
                                onTap:
                                    null, // Default navigation handled in ClassItemWidget
                                onDelete: () {
                                  _showDeleteDialog(classData.id);
                                },
                              );
                            }).toList(),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  heroTag: "class_screen_fab",
                  onPressed: _showCreateClassBottomSheet,
                  backgroundColor: context.colors.onPrimary,
                  foregroundColor: context.colors.primary,
                  child: const Icon(Icons.add, size: 28),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(String classId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: context.colors.primary,
            title: Text(
              'Xóa lớp học',
              style: AppTextStyles.textContent1.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Bạn có chắc chắn muốn xóa lớp học này?',
              style: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary.withOpacity(0.8),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Hủy',
                  style: AppTextStyles.textContent2.copyWith(
                    color: context.colors.onPrimary.withOpacity(0.7),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final notifier = Provider.of<ClassNotifier>(
                    context,
                    listen: false,
                  );
                  notifier.deleteClass(classId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa lớp học')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }
}
