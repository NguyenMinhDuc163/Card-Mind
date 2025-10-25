import 'package:card_mind/modules/course/screen/course_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flip_card/flip_card.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:card_mind/data/models/flashcard.dart';
import '../provider/detail_flash_card_notifier.dart';

class DetailFlashCardScreen extends StatefulWidget {
  const DetailFlashCardScreen({super.key});

  static const String routeName = '/DetailFlashCardScreen';

  @override
  State<DetailFlashCardScreen> createState() => _DetailFlashCardScreenState();
}

class _DetailFlashCardScreenState extends State<DetailFlashCardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final notifier = Provider.of<DetailFlashCardNotifier>(
      context,
      listen: false,
    );
    final courseId = ModalRoute.of(context)?.settings.arguments as String?;
    await notifier.initializeData(courseId: courseId);
  }

  bool _onSwipe(
    DetailFlashCardNotifier notifier,
    int? previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    HapticFeedback.lightImpact();

    // Kiểm tra xem có thẻ nào để swipe không
    if (previousIndex != null &&
        previousIndex < notifier.currentCards.length &&
        notifier.currentCards.isNotEmpty) {
      final card = notifier.currentCards[previousIndex];

      if (direction == CardSwiperDirection.right) {
        notifier.onSwipeRight(card);
      } else if (direction == CardSwiperDirection.left) {
        notifier.onSwipeLeft(card);
      }

      // Kiểm tra xem còn thẻ nào để học không
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!notifier.hasCardsToStudy) {
          // Tự động chuyển đến màn hình kết quả
          _navigateToResult(notifier);
        }
      });
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailFlashCardNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading) {
          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: context.colors.primary,
              body: const Center(
                child: CircularProgressIndicator(color: Colors.white),
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

        if (notifier.currentCards.isEmpty && !notifier.isLoading) {
          // Chỉ navigate một lần duy nhất
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (mounted) {
              await notifier.saveLearningResult();
              Navigator.pushReplacementNamed(
                context,
                CourseResultScreen.routeName,
                arguments: notifier.courseId,
              );
            }
          });

          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: context.colors.primary,
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Đang chuyển đến kết quả...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return FunctionScreenTemplate(
          actionsWidget: [
            GestureDetector(
              onTap: () async {
                await notifier.saveLearningResult();
                if (mounted) {
                  Navigator.pushReplacementNamed(
                    context,
                    CourseResultScreen.routeName,
                    arguments: notifier.courseId,
                  );
                }
              },
              child: Icon(
                Icons.check,
                color: context.colors.onPrimary,
                size: 24,
              ),
            ),
          ],
          backgroundColor: context.colors.primary,
          screen: Stack(
            children: [
              _buildAppBar(context, notifier),

              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 60,
                      left: 16,
                      right: 16,
                    ),
                    child: _buildProgressIndicators(context, notifier),
                  ),

                  Expanded(child: _buildFlashcardPageView(context, notifier)),

                  _buildBottomNavigationBar(context, notifier),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, DetailFlashCardNotifier notifier) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 40),
      color: context.colors.primary,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${notifier.learnedCount + notifier.unlearnedCount} / ${notifier.totalCards}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value:
                      notifier.totalCards > 0
                          ? (notifier.learnedCount + notifier.unlearnedCount) /
                              notifier.totalCards
                          : 0.0,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(
    BuildContext context,
    DetailFlashCardNotifier notifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProgressChip(context, '${notifier.unlearnedCount}', Colors.red),
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
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFlashcardPageView(
    BuildContext context,
    DetailFlashCardNotifier notifier,
  ) {
    // Kiểm tra an toàn: CardSwiper cần ít nhất 1 thẻ
    if (notifier.currentCards.isEmpty || notifier.currentCards.length < 1) {
      return const SizedBox.shrink();
    }

    return CardSwiper(
      cardsCount: notifier.currentCards.length,
      numberOfCardsDisplayed: 1,
      // Chỉ hiển thị 1 thẻ tại một thời điểm
      threshold: 50,
      // Ngưỡng swipe
      onSwipe: (previousIndex, currentIndex, direction) {
        return _onSwipe(notifier, previousIndex, currentIndex, direction);
      },
      cardBuilder: (context, index, horizontalThreshold, verticalThreshold) {
        if (index >= notifier.currentCards.length) return null;

        final flashcard = notifier.currentCards[index];
        final isBookmarked = notifier.isCardBookmarked(flashcard.id);
        return FlipCard(
          key: ValueKey(flashcard.id),
          direction: FlipDirection.HORIZONTAL,
          speed: 400,
          flipOnTouch: true,
          front: _buildCardSide(
            context,
            notifier: notifier,
            flashcard: flashcard,
            text: flashcard.frontText,
            imageUrl: flashcard.frontImage,
            isFront: true,
            isBookmarked: isBookmarked,
          ),
          back: _buildCardSide(
            context,
            notifier: notifier,
            flashcard: flashcard,
            text: flashcard.backText,
            imageUrl: flashcard.backImage,
            isFront: false,
            isBookmarked: isBookmarked,
          ),
        );
      },
    );
  }

  Widget _buildCardSide(
    BuildContext context, {
    required DetailFlashCardNotifier notifier,
    required Flashcard flashcard,
    required String text,
    String? imageUrl,
    required bool isFront,
    required bool isBookmarked,
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
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? AppColors.highlight : Colors.white70,
              ),
              onPressed: () {
                notifier.toggleBookmark(flashcard);
                HapticFeedback.mediumImpact();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    DetailFlashCardNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, top: 10, left: 16, right: 16),
      color: context.colors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white, size: 32),
            onPressed: () {
              _revertLastCard(notifier);
            },
          ),

          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
            onPressed: () {
              _autoPlayCard(notifier);
            },
          ),
        ],
      ),
    );
  }

  void _revertLastCard(DetailFlashCardNotifier notifier) {
    if (notifier.learnedCards.isNotEmpty ||
        notifier.unlearnedCards.isNotEmpty) {
      notifier.revertLastCard();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có thẻ nào để hoàn tác'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _autoPlayCard(DetailFlashCardNotifier notifier) {
    if (notifier.currentCard != null) {
      notifier.onSwipeRight(notifier.currentCard!);
    }
  }

  void _navigateToResult(DetailFlashCardNotifier notifier) async {
    await notifier.saveLearningResult();
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        CourseResultScreen.routeName,
        arguments: notifier.courseId,
      );
    }
  }
}
