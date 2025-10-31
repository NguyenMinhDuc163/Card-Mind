import 'package:card_mind/modules/course/screen/course_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flip_card/flip_card.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:card_mind/data/models/flashcard.dart';
import 'package:easy_localization/easy_localization.dart';
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

  Future<void> _initializeData({bool resetLearningData = false}) async {
    final notifier = Provider.of<DetailFlashCardNotifier>(
      context,
      listen: false,
    );

    // Lấy arguments - có thể là String (courseId) hoặc Map (courseId + learningMode)
    final arguments = ModalRoute.of(context)?.settings.arguments;
    String? courseId;
    LearningMode learningMode = LearningMode.fullCourse;

    if (arguments is String) {
      courseId = arguments;
    } else if (arguments is Map<String, dynamic>) {
      courseId = arguments['courseId'] as String?;

      // Parse learningMode từ string
      final learningModeStr = arguments['learningMode'] as String?;
      if (learningModeStr != null) {
        switch (learningModeStr) {
          case 'review':
            learningMode = LearningMode.review;
            break;
          case 'bookmarked':
            learningMode = LearningMode.bookmarked;
            break;
          case 'unlearned':
            learningMode = LearningMode.unlearned;
            break;
          default:
            learningMode = LearningMode.fullCourse;
        }
      }
    }

    await notifier.initializeData(
      courseId: courseId,
      resetLearningData: resetLearningData,
      learningMode: learningMode,
    );
  }

  bool _onSwipe(
    DetailFlashCardNotifier notifier,
    int? previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    HapticFeedback.lightImpact();

    if (previousIndex != null &&
        previousIndex < notifier.currentCards.length &&
        notifier.currentCards.isNotEmpty) {
      final card = notifier.currentCards[previousIndex];

      if (direction == CardSwiperDirection.right) {
        notifier.onSwipeRight(card);
      } else if (direction == CardSwiperDirection.left) {
        notifier.onSwipeLeft(card);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!notifier.hasCardsToStudy) {
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
                      notifier.errorMessage ??
                          'course_info.error_occurred'.tr(),
                      style: TextStyle(
                        color: context.brandColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _initializeData(),
                      child: Text('course_info.retry'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (notifier.currentCards.isEmpty && !notifier.isLoading) {
          // Debug: Kiểm tra các điều kiện
          print('=== DEBUG DETAIL FLASHCARD ===');
          print('Current cards: ${notifier.currentCards.length}');
          print('Is loading: ${notifier.isLoading}');
          print(
            'Has existing learning data: ${notifier.hasExistingLearningData}',
          );
          print('Total cards: ${notifier.totalCards}');
          print('Course ID: ${notifier.courseId}');
          print('==============================');

          // Check nếu đang ở bookmark mode và hết cards → auto navigate back
          if (notifier.learningMode == LearningMode.bookmarked &&
              notifier.totalCards == 0 &&
              !notifier.isLoading) {
            print('🔖 Bookmark mode with 0 cards - navigating back');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
            return FunctionScreenTemplate(
              screen: Scaffold(
                backgroundColor: context.colors.primary,
                body: const Center(child: SizedBox.shrink()),
              ),
            );
          }

          if (notifier.hasExistingLearningData && notifier.totalCards > 0) {
            print('🚨 TRIGGERING NAVIGATION TO RESULT SCREEN');
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
          } else {
            print('✅ NOT triggering navigation - showing welcome screen');
          }

          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: context.colors.primary,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (notifier.hasExistingLearningData &&
                        notifier.totalCards > 0) ...[
                      CircularProgressIndicator(
                        color: context.brandColors.textPrimary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'course_detail.navigating_to_result'.tr(),
                        style: TextStyle(
                          color: context.brandColors.textSecondary,
                        ),
                      ),
                    ] else if (notifier.totalCards == 0) ...[
                      CircularProgressIndicator(
                        color: context.brandColors.textPrimary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'course_detail.loading_data'.tr(),
                        style: TextStyle(
                          color: context.brandColors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.school,
                        color: context.brandColors.textSecondary,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'course_detail.welcome_title'.tr(),
                        style: TextStyle(
                          color: context.brandColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'course_detail.welcome_subtitle'.tr(),
                        style: TextStyle(
                          color: context.brandColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          _initializeData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.brandColors.buttonPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'course_detail.start_learning'.tr(),
                          style: TextStyle(
                            color: context.brandColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        return FunctionScreenTemplate(
          actionsWidget: [
            GestureDetector(
              onTap: () => _showResetDialog(notifier),
              child: Icon(
                Icons.refresh,
                color: context.colors.onPrimary,
                size: 24,
              ),
            ),
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
                  '${notifier.currentCardIndex} / ${notifier.totalCards}',
                  style: TextStyle(
                    color: context.brandColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value:
                      notifier.totalCards > 0
                          ? (notifier.currentCardIndex + 1) /
                              notifier.totalCards
                          : 0.0,
                  backgroundColor: context.brandColors.progressBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.brandColors.progressValue,
                  ),
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
        _buildProgressChip(
          context,
          '${notifier.unlearnedCount}',
          context.brandColors.buttonDestructive,
        ),
        _buildProgressChip(
          context,
          '${notifier.learnedCount}',
          context.brandColors.progressValue,
        ),
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
    if (notifier.currentCards.isEmpty || notifier.currentCards.length < 1) {
      return const SizedBox.shrink();
    }

    return CardSwiper(
      cardsCount: notifier.currentCards.length,
      numberOfCardsDisplayed: 1,

      threshold: 50,

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
        color: context.brandColors.cardBackground,
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
                      color: context.brandColors.avatarBackground,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: context.brandColors.textSecondary,
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
                    style: TextStyle(
                      color: context.brandColors.textPrimary,
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
                color:
                    isBookmarked
                        ? context.brandColors.progressValue
                        : context.brandColors.textSecondary,
              ),
              onPressed: () {
                notifier.toggleBookmark(flashcard);
                HapticFeedback.mediumImpact();

                // Nếu xóa card cuối trong bookmark mode, hiện thông báo
                if (notifier.learningMode == LearningMode.bookmarked &&
                    notifier.totalCards == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('course_detail.bookmarks_cleared'.tr()),
                      backgroundColor: context.brandColors.progressValue,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
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
        SnackBar(
          content: Text('course_detail.no_cards_to_undo'.tr()),
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

  void _showResetDialog(DetailFlashCardNotifier notifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.brandColors.cardBackground,
          title: Row(
            children: [
              Icon(
                Icons.refresh,
                color: context.brandColors.buttonPrimary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'course_detail.reset_title'.tr(),
                style: TextStyle(color: context.brandColors.textPrimary),
              ),
            ],
          ),
          content: Text(
            'course_detail.reset_message'.tr(),
            style: TextStyle(color: context.brandColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'common.cancel'.tr(),
                style: TextStyle(color: context.brandColors.buttonPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetLearningData(notifier);
              },
              child: Text(
                'course_detail.reset_action'.tr(),
                style: TextStyle(color: context.brandColors.buttonDestructive),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetLearningData(DetailFlashCardNotifier notifier) async {
    if (notifier.courseId != null) {
      await _initializeData(resetLearningData: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('course_detail.reset_success'.tr()),
            backgroundColor: context.brandColors.progressValue,
          ),
        );
      }
    }
  }
}
