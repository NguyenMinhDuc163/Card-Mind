import 'package:flutter/material.dart';
import 'package:card_mind/init.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import '../provider/course_info_notifier.dart';
import '../widgets/flashcard_carousel_widget.dart';
import '../widgets/course_info_widget.dart';
import '../widgets/learning_options_widget.dart';
import 'detail_flash_card_screen.dart';
import 'test_screen.dart';
import 'edit_course_screen.dart';

class CourseInfoScreen extends StatefulWidget {
  const CourseInfoScreen({super.key});

  static const String routeName = '/CourseInfoScreen';

  @override
  State<CourseInfoScreen> createState() => _CourseInfoScreenState();
}

class _CourseInfoScreenState extends State<CourseInfoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final notifier = Provider.of<CourseInfoNotifier>(context, listen: false);
    final courseId = ModalRoute.of(context)?.settings.arguments as String?;
    await notifier.initializeData(courseId: courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseInfoNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading) {
          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: context.colors.primary,
              body: Center(
                child: CircularProgressIndicator(
                  color: context.brandColors.textPrimary,
                ),
              ),
            ),
          );
        }

        if (notifier.hasError) {
          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: context.colors.primary,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      color: context.brandColors.textSecondary,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      notifier.errorMessage ?? 'Có lỗi xảy ra',
                      style: TextStyle(
                        color: context.brandColors.textSecondary,
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
            ),
          );
        }

        if (notifier.course == null || notifier.flashcards.isEmpty) {
          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: context.colors.primary,
              body: Center(
                child: Text(
                  'Không tìm thấy khóa học',
                  style: TextStyle(color: context.brandColors.textSecondary),
                ),
              ),
            ),
          );
        }

        return FunctionScreenTemplate(
          screen: Scaffold(
            backgroundColor: context.colors.primary,
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: FlashcardCarouselWidget(
                      flashcards: notifier.flashcards,
                      onPageChanged: (index) {},
                      onCardTap: (flashcard) {},
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: CourseInfoWidget(course: notifier.course!),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: LearningOptionsWidget(
                      onOptionTap: (mode) {
                        _handleLearningModeTap(mode);
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLearningModeTap(LearningMode mode) {
    final notifier = Provider.of<CourseInfoNotifier>(context, listen: false);
    if (notifier.course != null) {
      if (mode == LearningMode.delete) {
        _showDeleteConfirmationDialog(notifier.course!.id);
      } else if (mode == LearningMode.test) {
        Navigator.pushNamed(
          context,
          TestScreen.routeName,
          arguments: notifier.course!.id,
        );
      } else if (mode == LearningMode.learn) {
        Navigator.pushNamed(
          context,
          EditCourseScreen.routeName,
          arguments: notifier.course!.id,
        );
      } else {
        Navigator.pushNamed(
          context,
          DetailFlashCardScreen.routeName,
          arguments: notifier.course!.id,
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(String courseId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.brandColors.cardBackground,
          title: Text(
            'Xóa học phần',
            style: TextStyle(color: context.brandColors.textPrimary),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa học phần này không? Hành động này không thể hoàn tác.',
            style: TextStyle(color: context.brandColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: TextStyle(color: context.brandColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteCourse(courseId);
              },
              child: Text(
                'Xóa',
                style: TextStyle(color: context.brandColors.buttonDestructive),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCourse(String courseId) async {
    final notifier = Provider.of<CourseInfoNotifier>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.brandColors.cardBackground,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: context.brandColors.textPrimary),
              const SizedBox(width: 16),
              Text(
                'Đang xóa học phần...',
                style: TextStyle(color: context.brandColors.textPrimary),
              ),
            ],
          ),
        );
      },
    );

    try {
      final success = await notifier.deleteCourse(courseId);

      Navigator.of(context).pop();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã xóa học phần thành công'),
            backgroundColor: context.brandColors.progressValue,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboardScreen',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không thể xóa học phần'),
            backgroundColor: context.brandColors.buttonDestructive,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: context.brandColors.buttonDestructive,
        ),
      );
    }
  }
}
