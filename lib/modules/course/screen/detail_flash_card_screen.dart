import 'package:card_mind/modules/course/screen/course_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flip_card/flip_card.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:provider/provider.dart';
import '../provider/detail_flash_card_notifier.dart';
import '../../../data/models/flashcard.dart';
import '../../../data/models/course.dart';

class DetailFlashCardScreen extends StatefulWidget {
  const DetailFlashCardScreen({super.key});

  static const String routeName = '/DetailFlashCardScreen';

  @override
  State<DetailFlashCardScreen> createState() => _DetailFlashCardScreenState();
}

class _DetailFlashCardScreenState extends State<DetailFlashCardScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final notifier = Provider.of<DetailFlashCardNotifier>(context, listen: false);
    final courseId = ModalRoute.of(context)?.settings.arguments as String?;
    await notifier.initializeData(courseId: courseId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onCardSwiped(DragEndDetails details, DetailFlashCardNotifier notifier) {
    HapticFeedback.lightImpact();
    final currentFlashcard = notifier.flashcards[_currentIndex];

    if (details.primaryVelocity! > 0) {
      notifier.unmarkCardAsLearned(currentFlashcard.id);
      _goToPreviousCard();
    } else if (details.primaryVelocity! < 0) {
      notifier.markCardAsLearned(currentFlashcard.id);
      _goToNextCard(notifier);
    }
  }

  void _goToNextCard(DetailFlashCardNotifier notifier) {
    final currentFlashcard = notifier.flashcards[_currentIndex];
    notifier.markCardAsLearned(currentFlashcard.id);

    if (_currentIndex < notifier.totalCards - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushNamed(context, CourseResultScreen.routeName, arguments: notifier.courseId);
    }
  }

  void _goToPreviousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailFlashCardNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading) {
          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: context.colors.primary,
              body: const Center(child: CircularProgressIndicator(color: Colors.white)),
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

        if (notifier.flashcards.isEmpty) {
          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: context.colors.primary,
              body: const Center(
                child: Text('Không có thẻ học nào', style: TextStyle(color: Colors.white70)),
              ),
            ),
          );
        }

        return FunctionScreenTemplate(
          screen: Scaffold(
            backgroundColor: context.colors.primary,
            body: Stack(
              children: [
                _buildAppBar(context, notifier),

                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
                      child: _buildProgressIndicators(context, notifier),
                    ),

                    Expanded(child: _buildFlashcardPageView(context, notifier)),

                    _buildBottomNavigationBar(context, notifier),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, DetailFlashCardNotifier notifier) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      color: context.colors.primary,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),

          Expanded(
            child: Column(
              children: [
                Text(
                  '${_currentIndex + 1} / ${notifier.totalCards}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / notifier.totalCards,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 4,
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(BuildContext context, DetailFlashCardNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProgressChip(context, '${notifier.unlearnedCount}', Colors.orange),
        _buildProgressChip(context, '${notifier.learnedCount}', Colors.green),
      ],
    );
  }

  Widget _buildProgressChip(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFlashcardPageView(BuildContext context, DetailFlashCardNotifier notifier) {
    return PageView.builder(
      controller: _pageController,
      itemCount: notifier.totalCards,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        final flashcard = notifier.flashcards[index];
        return GestureDetector(
          onHorizontalDragEnd: (details) => _onCardSwiped(details, notifier),
          child: FlipCard(
            key: ValueKey(flashcard.id),
            direction: FlipDirection.HORIZONTAL,
            speed: 400,
            flipOnTouch: true,
            front: _buildCardSide(
              context,
              text: flashcard.frontText,
              imageUrl: flashcard.frontImage,
              isFront: true,
            ),
            back: _buildCardSide(
              context,
              text: flashcard.backText,
              imageUrl: flashcard.backImage,
              isFront: false,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardSide(
    BuildContext context, {
    required String text,
    String? imageUrl,
    required bool isFront,
  }) {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty) ...[
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            color: Colors.white70,
                            size: 48,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.star_border, color: Colors.white70),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, DetailFlashCardNotifier notifier) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, top: 10, left: 16, right: 16),
      color: context.colors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white, size: 32),
            onPressed: _goToPreviousCard,
          ),

          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
            onPressed: () => _goToNextCard(notifier),
          ),
        ],
      ),
    );
  }
}
