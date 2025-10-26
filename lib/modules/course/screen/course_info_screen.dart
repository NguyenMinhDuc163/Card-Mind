import 'package:flutter/material.dart';
import 'package:card_mind/init.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
            screen: const Scaffold(
              backgroundColor: Color(0xFF0B1D3B),
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        }

        if (notifier.hasError) {
          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: const Color(0xFF0B1D3B),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.white70, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      notifier.errorMessage ?? 'Có lỗi xảy ra',
                      style: const TextStyle(color: Colors.white70),
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
            screen: const Scaffold(
              backgroundColor: Color(0xFF0B1D3B),
              body: Center(
                child: Text(
                  'Không tìm thấy khóa học',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          );
        }

        return FunctionScreenTemplate(
          screen: Scaffold(
            backgroundColor: const Color(0xFF0B1D3B),
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
          backgroundColor: const Color(0xFF0E2B5C),
          title: const Text(
            'Xóa học phần',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn xóa học phần này không? Hành động này không thể hoàn tác.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteCourse(courseId);
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
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
        return const AlertDialog(
          backgroundColor: Color(0xFF0E2B5C),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 16),
              Text(
                'Đang xóa học phần...',
                style: TextStyle(color: Colors.white),
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
          const SnackBar(
            content: Text('Đã xóa học phần thành công'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboardScreen',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể xóa học phần'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
