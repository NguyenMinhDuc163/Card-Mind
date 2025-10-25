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
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.white70),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tìm kiếm',
                                style: AppTextStyles.text.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person),
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
                    style: AppTextStyles.text.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Hãy thử các học phần này',
                          style: AppTextStyles.textHeader3.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const Icon(Icons.more_vert, color: Colors.white70),
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
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              final topPicks =
                  notifier.homeData.courses.reversed.take(5).toList();

              if (topPicks.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Chưa có khóa học nào',
                      style: TextStyle(color: Colors.white70),
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
                              color: context.colors.secondary.withOpacity(0.8),
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
                                    color: context.colors.secondary.withOpacity(
                                      0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.style,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  course.title,
                                  style: AppTextStyles.textContent2.copyWith(
                                    color: AppColors.white,
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
                                            .copyWith(color: Colors.white70),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.more_vert,
                                      color: Colors.white70,
                                      size: 18,
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
                          color: context.colors.secondary.withOpacity(0.9),
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
                                    color: context.colors.secondary.withOpacity(
                                      0.25,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.class_,
                                    color: Colors.white70,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.more_vert,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              classItem.className,
                              style: AppTextStyles.textHeader3.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              classItem.description,
                              style: AppTextStyles.textContent3.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${classItem.totalStudents} học sinh • ${classItem.instructor}',
                                    style: AppTextStyles.textContent4.copyWith(
                                      color: Colors.white60,
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
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    classItem.status == 'active'
                                        ? 'Hoạt động'
                                        : 'Tạm dừng',
                                    style: AppTextStyles.textContent4.copyWith(
                                      color:
                                          classItem.status == 'active'
                                              ? Colors.green
                                              : Colors.orange,
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
}
