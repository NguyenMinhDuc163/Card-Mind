import 'package:flutter/material.dart';
import 'package:card_mind/init.dart';
import 'package:flutter/services.dart';
import '../widgets/flashcard_carousel_widget.dart';
import '../widgets/course_info_widget.dart';
import '../widgets/learning_options_widget.dart';
import 'detail_flash_card_screen.dart';
import '../../../data/models/course.dart';
import '../../../data/models/flashcard.dart';

class CourseInfoScreen extends StatefulWidget {
  const CourseInfoScreen({super.key});
  static const String routeName = '/CourseInfoScreen';
  @override
  State<CourseInfoScreen> createState() => _CourseInfoScreenState();
}

class _CourseInfoScreenState extends State<CourseInfoScreen> {
  late Course _course;
  late List<Flashcard> _flashcards;

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Tạo dữ liệu mẫu cho demo
    final now = DateTime.now();
    _flashcards = [
      Flashcard(
        id: '1',
        frontText: 'Hello',
        backText: 'Xin chào',
        category: 'Greetings',
        createdAt: now,
        updatedAt: now,
      ),
      Flashcard(
        id: '2',
        frontText: 'Goodbye',
        backText: 'Tạm biệt',
        category: 'Greetings',
        createdAt: now,
        updatedAt: now,
      ),
      Flashcard(
        id: '3',
        frontText: 'Thank you',
        backText: 'Cảm ơn',
        category: 'Politeness',
        createdAt: now,
        updatedAt: now,
      ),
      Flashcard(
        id: '4',
        frontText: 'Please',
        backText: 'Làm ơn',
        category: 'Politeness',
        createdAt: now,
        updatedAt: now,
      ),
      Flashcard(
        id: '5',
        frontText: 'Sorry',
        backText: 'Xin lỗi',
        category: 'Politeness',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    _course = Course(
      id: '1',
      title: 'Card Mind',
      description: 'Tìm hiểu thêm về Card Mind với học phần này.',
      flashcards: _flashcards,
      totalTerms: _flashcards.length,
      isVerified: true,
      author: 'Card Mind Team',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: 'English',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FunctionScreenTemplate(
      screen: Scaffold(
        backgroundColor: const Color(0xFF0B1D3B),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: FlashcardCarouselWidget(
                  flashcards: _flashcards,
                  onPageChanged: (index) {

                  },
                  onCardTap: (flashcard) {
                    // TODO: Handle card tap
                  },
                ),
              ),
            ),

            // Course Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: CourseInfoWidget(course: _course),
              ),
            ),

            // Learning Options
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

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _handleLearningModeTap(LearningMode mode) {
    Navigator.pushNamed(context, DetailFlashCardScreen.routeName);
  }
}
