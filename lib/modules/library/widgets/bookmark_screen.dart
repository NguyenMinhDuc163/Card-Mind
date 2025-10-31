import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/library/provider/book_mark_notifier.dart';
import 'package:card_mind/modules/library/widgets/bookmark_item_widget.dart';
import 'package:card_mind/modules/library/widgets/data_group_widget.dart';
import 'package:card_mind/modules/course/screen/detail_flash_card_screen.dart';
import 'package:card_mind/modules/course/provider/detail_flash_card_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key, this.searchQuery = ''});

  final String searchQuery;

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => false; // Không cache state, luôn refresh

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh mỗi khi dependencies thay đổi (screen hiển thị lại)
    if (_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshData();
      });
    }
  }

  @override
  void didUpdateWidget(BookmarkScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      Future.microtask(() {
        if (mounted) {
          _performSearch();
        }
      });
    }
  }

  Future<void> _refreshData() async {
    if (mounted) {
      final notifier = Provider.of<BookMarkNotifier>(context, listen: false);
      await notifier.initializeData();
      print('📚 BookmarkScreen refreshed');
    }
  }

  Future<void> _initializeData() async {
    final notifier = Provider.of<BookMarkNotifier>(context, listen: false);
    await notifier.initializeData();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _performSearch() {
    final notifier = Provider.of<BookMarkNotifier>(context, listen: false);
    notifier.searchBookmarks(widget.searchQuery);
  }

  Future<void> _navigateToCourse(
    String courseId, {
    LearningMode? learningMode,
  }) async {
    if (learningMode != null) {
      // Convert enum to string
      String learningModeStr;
      switch (learningMode) {
        case LearningMode.review:
          learningModeStr = 'review';
          break;
        case LearningMode.bookmarked:
          learningModeStr = 'bookmarked';
          break;
        case LearningMode.unlearned:
          learningModeStr = 'unlearned';
          break;
        case LearningMode.fullCourse:
          learningModeStr = 'fullCourse';
          break;
      }

      await Navigator.pushNamed(
        context,
        DetailFlashCardScreen.routeName,
        arguments: {'courseId': courseId, 'learningMode': learningModeStr},
      );
    } else {
      await Navigator.pushNamed(
        context,
        DetailFlashCardScreen.routeName,
        arguments: courseId,
      );
    }

    // Refresh data khi quay về (đặc biệt cho bookmark mode)
    if (mounted) {
      final notifier = Provider.of<BookMarkNotifier>(context, listen: false);
      await notifier.initializeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Consumer<BookMarkNotifier>(
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
                    notifier.errorMessage ??
                        'library.common.error_generic'.tr(),
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    child: Text('common.retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: context.colors.primary,
          body: SingleChildScrollView(
            padding: AppPad.h16v8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(notifier),
                const SizedBox(height: 20),

                if (notifier.coursesNeedingReview.isNotEmpty) ...[
                  DataGroupWidget(
                    date: 'library.bookmark.section.review_today'.tr(),
                    items:
                        notifier.coursesNeedingReview.map((courseData) {
                          return BookmarkItemWidget(
                            courseData: courseData,
                            onTap:
                                () => _navigateToCourse(
                                  courseData['courseId'] as String,
                                  learningMode: LearningMode.review,
                                ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                if (notifier.bookmarkedCoursesByCourse.isNotEmpty) ...[
                  DataGroupWidget(
                    date: 'library.bookmark.section.bookmarked'.tr(),
                    items:
                        notifier.bookmarkedCoursesByCourse.map((courseData) {
                          return BookmarkItemWidget(
                            courseData: courseData,
                            onTap:
                                () => _navigateToCourse(
                                  courseData['courseId'] as String,
                                  learningMode: LearningMode.bookmarked,
                                ),
                            isBookmarked: true,
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                if (notifier.unlearnedCardsByCourse.isEmpty &&
                    notifier.bookmarkedCoursesByCourse.isEmpty &&
                    notifier.coursesNeedingReview.isEmpty)
                  _buildEmptyState(context)
                else if (notifier.unlearnedCardsByCourse.isNotEmpty)
                  DataGroupWidget(
                    date: 'library.bookmark.section.unlearned_by_course'.tr(),
                    items:
                        notifier.unlearnedCardsByCourse.map((courseData) {
                          return BookmarkItemWidget(
                            courseData: courseData,
                            onTap:
                                () => _navigateToCourse(
                                  courseData['courseId'] as String,
                                  learningMode: LearningMode.unlearned,
                                ),
                          );
                        }).toList(),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BookMarkNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bookmark_border,
                color: context.colors.onPrimary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'library.bookmark.header.title'.tr(),
                style: AppTextStyles.textContent1.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'library.bookmark.stats.review'.tr(),
                  notifier.totalReviewCards.toString(),
                  Icons.schedule,
                  context.brandColors.progressValue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'library.bookmark.stats.unlearned'.tr(),
                  notifier.totalUnlearnedCards.toString(),
                  Icons.credit_card,
                  context.colors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.textContent1.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.textContent3.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: context.colors.onPrimary.withOpacity(0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'library.bookmark.empty_title'.tr(),
            style: AppTextStyles.textContent2.copyWith(
              color: context.colors.onPrimary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'library.bookmark.empty_subtitle'.tr(),
            style: AppTextStyles.textContent3.copyWith(
              color: context.colors.onPrimary.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
