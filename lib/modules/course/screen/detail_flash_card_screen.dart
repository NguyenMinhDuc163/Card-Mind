import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flip_card/flip_card.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
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
  Set<String> _learnedCardIds = {};
  late int _totalCards;
  late Course _mockCourse;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _initializeMockData();
    _totalCards = _mockCourse.flashcards.length;
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _mockCourse = Course(
      id: '1',
      title: 'Tiếng Anh Cơ Bản',
      description: 'Học từ vựng tiếng Anh cơ bản',
      flashcards: [
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
        Flashcard(
          id: '6',
          frontText: 'Excuse me',
          backText: 'Xin lỗi (để thu hút sự chú ý)',
          category: 'Politeness',
          createdAt: now,
          updatedAt: now,
        ),
        Flashcard(
          id: '7',
          frontText: 'Yes',
          backText: 'Có',
          category: 'Basic',
          createdAt: now,
          updatedAt: now,
        ),
        Flashcard(
          id: '8',
          frontText: 'No',
          backText: 'Không',
          category: 'Basic',
          createdAt: now,
          updatedAt: now,
        ),
        Flashcard(
          id: '9',
          frontText: 'Help',
          backText: 'Giúp đỡ',
          category: 'Basic',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      totalTerms: 9,
      isVerified: true,
      author: 'Card Mind Team',
      createdAt: now,
      updatedAt: now,
      category: 'English',
    );
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

  void _onCardSwiped(DragEndDetails details) {
    HapticFeedback.lightImpact();
    final currentFlashcard = _mockCourse.flashcards[_currentIndex];

    if (details.primaryVelocity! > 0) {
      // Vuốt sang phải - đã đọc xong
      setState(() {
        if (!_learnedCardIds.contains(currentFlashcard.id)) {
          _learnedCardIds.add(currentFlashcard.id);
        }
      });
      _goToNextCard();
    } else if (details.primaryVelocity! < 0) {
      // Vuốt sang trái - chưa đọc/chưa hiểu
      setState(() {
        if (_learnedCardIds.contains(currentFlashcard.id)) {
          _learnedCardIds.remove(currentFlashcard.id);
        }
      });
      _goToPreviousCard();
    }
  }

  void _goToNextCard() {
    if (_currentIndex < _totalCards - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showCompletionDialog();
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

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chúc mừng!'),
            content: Text('Bạn đã hoàn thành tất cả ${_totalCards} thẻ học!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Hoàn thành'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FunctionScreenTemplate(
      screen: Scaffold(
        backgroundColor: context.colors.primary,
        body: Stack(
          children: [
            // App Bar
            _buildAppBar(context),

            // Main Content
            Column(
              children: [
                // Progress Indicators
                Padding(
                  padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
                  child: _buildProgressIndicators(context),
                ),

                // Flashcard
                Expanded(child: _buildFlashcardPageView(context)),

                // Bottom Navigation
                _buildBottomNavigationBar(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),

          // Center progress
          Expanded(
            child: Column(
              children: [
                Text(
                  '${_currentIndex + 1} / $_totalCards',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _totalCards,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 4,
                ),
              ],
            ),
          ),

          // Settings button
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 24),
            onPressed: () {
              // TODO: Handle settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(BuildContext context) {
    final unlearnedCount = _totalCards - _learnedCardIds.length;
    final learnedCount = _learnedCardIds.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProgressChip(context, '$unlearnedCount', Colors.orange),
        _buildProgressChip(context, '$learnedCount', Colors.green),
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
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFlashcardPageView(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: _totalCards,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        final flashcard = _mockCourse.flashcards[index];
        return GestureDetector(
          onHorizontalDragEnd: _onCardSwiped,
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
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isFront ? 'Mặt trước' : 'Mặt sau',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          isFront ? 'Chạm để lật' : 'Chạm để lật lại',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isFront ? Icons.touch_app : Icons.flip,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.star_border, color: Colors.white70),
              onPressed: () {
                // TODO: Handle favorite action
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, top: 10, left: 16, right: 16),
      color: context.colors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white, size: 32),
            onPressed: _goToPreviousCard,
          ),

          // Next button
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
            onPressed: _goToNextCard,
          ),
        ],
      ),
    );
  }
}
