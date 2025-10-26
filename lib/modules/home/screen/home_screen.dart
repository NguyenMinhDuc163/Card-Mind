import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/course/screen/course_info_screen.dart';
import 'package:card_mind/modules/home/provider/home_notifier.dart';
import 'package:card_mind/modules/home/screen/global_search_screen.dart';
import 'package:card_mind/modules/library/screen/class_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  static const String routeName = '/HomeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = Provider.of<HomeNotifier>(context, listen: false);
      notifier.initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FunctionScreenTemplate(
      isShowBottomButton: false,
      isShowAppBar: true,
      isShowDrawer: true,
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [context.colors.primary, context.colors.secondary],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      title: 'Card Mind',
      screen: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: AppPad.h16v20,
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          GlobalSearchScreen.routeName,
                        );
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: context.brandColors.searchBarBackground,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: context.brandColors.searchBarIcon,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tìm kiếm',
                                style: AppTextStyles.text.copyWith(
                                  color: context.brandColors.searchBarText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: context.brandColors.avatarBackground,
                    child: Icon(
                      Icons.person,
                      color: context.brandColors.searchBarIcon,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: AppPad.h16,
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Lựa chọn của đội ngũ',
                    style: AppTextStyles.text.copyWith(
                      color: context.brandColors.searchBarText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Hãy thử các học phần này',
                          style: AppTextStyles.textHeader3.copyWith(
                            color: context.brandColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          Consumer<HomeNotifier>(
            builder: (context, notifier, child) {
              if (notifier.isLoading) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.brandColors.textPrimary,
                    ),
                  ),
                );
              }

              final topPicks =
                  notifier.homeData.courses.reversed.take(5).toList();

              if (topPicks.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Chưa có khóa học nào',
                      style: TextStyle(
                        color: context.brandColors.searchBarText,
                      ),
                    ),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.64),
                    padEnds: false,
                    itemCount: topPicks.length,
                    itemBuilder: (context, index) {
                      final course = topPicks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: InkWell(
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                CourseInfoScreen.routeName,
                                arguments: course.id,
                              ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.brandColors.cardBackground
                                  .withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: context.colors.primary.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: context.brandColors.avatarBackground,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.style,
                                    color: context.brandColors.searchBarIcon,
                                  ),
                                ),
                                Text(
                                  course.title,
                                  style: AppTextStyles.textContent2.copyWith(
                                    color: context.brandColors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${course.totalTerms} thẻ · Tác giả: ${course.author}',
                                        style: AppTextStyles.textContent4
                                            .copyWith(
                                              color:
                                                  context
                                                      .brandColors
                                                      .searchBarText,
                                            ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:
                                          () => _showDeleteCourseDialog(
                                            context,
                                            course.id,
                                            course.title,
                                          ),
                                      child: Icon(
                                        Icons.more_vert,
                                        color:
                                            context.brandColors.searchBarIcon,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: AppPad.h16,
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Các chủ đề học tập',
                      style: AppTextStyles.textHeader3.copyWith(
                        color: context.brandColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          Consumer<HomeNotifier>(
            builder: (context, notifier, child) {
              if (notifier.homeData.classes.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox(height: 20));
              }

              final reversedClasses =
                  notifier.homeData.classes.reversed.toList();

              return SliverPadding(
                padding: AppPad.h16,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    if (i.isOdd) return const SizedBox(height: 16);
                    final int index = i ~/ 2;
                    if (index >= reversedClasses.length) return null;

                    final classItem = reversedClasses[index];
                    return GestureDetector(
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            ClassDetailScreen.routeName,
                            arguments: classItem.id,
                          ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.brandColors.cardBackground.withOpacity(
                            0.9,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.primary.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: context.brandColors.avatarBackground,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.class_,
                                    color: context.brandColors.searchBarIcon,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap:
                                      () => _showDeleteClassDialog(
                                        context,
                                        classItem.id,
                                        classItem.className,
                                      ),
                                  child: Icon(
                                    Icons.more_vert,
                                    color: context.brandColors.searchBarIcon,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              classItem.className,
                              style: AppTextStyles.textHeader3.copyWith(
                                color: context.brandColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              classItem.description,
                              style: AppTextStyles.textContent3.copyWith(
                                color: context.brandColors.searchBarText,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${classItem.totalStudents} học sinh • ${classItem.instructor}',
                                    style: AppTextStyles.textContent4.copyWith(
                                      color: context.brandColors.searchBarText
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        classItem.status == 'active'
                                            ? context.brandColors.statusActive
                                                .withOpacity(0.2)
                                            : context.brandColors.statusInactive
                                                .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    classItem.status == 'active'
                                        ? 'Hoạt động'
                                        : 'Tạm dừng',
                                    style: AppTextStyles.textContent4.copyWith(
                                      color:
                                          classItem.status == 'active'
                                              ? context.brandColors.statusActive
                                              : context
                                                  .brandColors
                                                  .statusInactive,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: reversedClasses.length * 2 - 1),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  void _showDeleteCourseDialog(
    BuildContext context,
    String courseId,
    String courseTitle,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.brandColors.cardBackground,
          title: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: context.brandColors.buttonDestructive,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Xóa học phần',
                style: TextStyle(color: context.brandColors.textPrimary),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa học phần "$courseTitle"?\n\nHành động này không thể hoàn tác và sẽ xóa tất cả dữ liệu liên quan.',
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
                await _deleteCourse(context, courseId, courseTitle);
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

  Future<void> _deleteCourse(
    BuildContext context,
    String courseId,
    String courseTitle,
  ) async {
    final notifier = Provider.of<HomeNotifier>(context, listen: false);

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.brandColors.cardBackground,
          content: Row(
            children: [
              CircularProgressIndicator(
                color: context.brandColors.buttonPrimary,
              ),
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

      // Đóng loading dialog
      Navigator.of(context).pop();

      if (success) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa học phần "$courseTitle" thành công'),
            backgroundColor: context.brandColors.progressValue,
          ),
        );
      } else {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể xóa học phần "$courseTitle"'),
            backgroundColor: context.brandColors.buttonDestructive,
          ),
        );
      }
    } catch (e) {
      // Đóng loading dialog
      Navigator.of(context).pop();

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi xóa học phần: $e'),
          backgroundColor: context.brandColors.buttonDestructive,
        ),
      );
    }
  }

  void _showDeleteClassDialog(
    BuildContext context,
    String classId,
    String className,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.brandColors.cardBackground,
          title: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: context.brandColors.buttonDestructive,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Xóa Chủ đề học',
                style: TextStyle(color: context.brandColors.textPrimary),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa Chủ đề học "$className"?\n\nHành động này không thể hoàn tác.',
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
                await _deleteClass(context, classId, className);
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

  Future<void> _deleteClass(
    BuildContext context,
    String classId,
    String className,
  ) async {
    final notifier = Provider.of<HomeNotifier>(context, listen: false);

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.brandColors.cardBackground,
          content: Row(
            children: [
              CircularProgressIndicator(
                color: context.brandColors.buttonPrimary,
              ),
              const SizedBox(width: 16),
              Text(
                'Đang xóa Chủ đề học...',
                style: TextStyle(color: context.brandColors.textPrimary),
              ),
            ],
          ),
        );
      },
    );

    try {
      final success = await notifier.deleteClass(classId);

      // Đóng loading dialog
      Navigator.of(context).pop();

      if (success) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa Chủ đề học "$className" thành công'),
            backgroundColor: context.brandColors.progressValue,
          ),
        );
      } else {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể xóa Chủ đề học "$className"'),
            backgroundColor: context.brandColors.buttonDestructive,
          ),
        );
      }
    } catch (e) {
      // Đóng loading dialog
      Navigator.of(context).pop();

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi xóa Chủ đề học: $e'),
          backgroundColor: context.brandColors.buttonDestructive,
        ),
      );
    }
  }
}
