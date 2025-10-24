import 'package:flutter/material.dart';
import 'package:card_mind/init.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../provider/course_info_notifier.dart';
import '../widgets/flashcard_carousel_widget.dart';
import '../widgets/course_info_widget.dart';
import '../widgets/learning_options_widget.dart';
import 'detail_flash_card_screen.dart';

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
              body: Center(child: CircularProgressIndicator(color: Colors.white)),
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
                child: Text('Không tìm thấy khóa học', style: TextStyle(color: Colors.white70)),
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
      Navigator.pushNamed(context, DetailFlashCardScreen.routeName, arguments: notifier.course!.id);
    }
  }
}
