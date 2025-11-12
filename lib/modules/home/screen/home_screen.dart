import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/course/screen/course_info_screen.dart';
import 'package:card_mind/modules/home/provider/home_notifier.dart';
import 'package:card_mind/modules/home/screen/global_search_screen.dart';
import 'package:card_mind/modules/library/screen/class_detail_screen.dart';
import 'package:card_mind/modules/dashboard/screen/dashboard_screen.dart';
import 'package:card_mind/providers/auth_provider.dart';
import 'package:card_mind/core/services/data_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

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
                                'home_screen.search'.tr(),
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
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return GestureDetector(
                        onTap: () => _handleAvatarTap(context, authProvider),
                        onLongPress:
                            authProvider.isSignedIn
                                ? () =>
                                    _showSignOutDialog(context, authProvider)
                                : null,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: context.brandColors.avatarBackground,
                          backgroundImage:
                              authProvider.photoURL != null
                                  ? NetworkImage(authProvider.photoURL!)
                                  : null,
                          child:
                              authProvider.isLoading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : authProvider.photoURL == null
                                  ? Icon(
                                    Icons.person,
                                    color: context.brandColors.searchBarIcon,
                                  )
                                  : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (!authProvider.isSyncing) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverPadding(
                padding: AppPad.h16v8,
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: context.brandColors.cardBackground.withOpacity(
                        0.9,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.colors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'home_screen.syncing_data'.tr(),
                            style: AppTextStyles.textContent2.copyWith(
                              color: context.brandColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          Consumer<HomeNotifier>(
            builder: (context, notifier, child) {
              final coursesNeedingReview = notifier.coursesNeedingReview;

              if (coursesNeedingReview.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverPadding(
                padding: AppPad.h16,
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: context.brandColors.progressValue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'home_screen.review_today'.tr(),
                              style: AppTextStyles.textHeader3.copyWith(
                                color: context.brandColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: coursesNeedingReview.length,
                          itemBuilder: (context, index) {
                            final course = coursesNeedingReview[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: InkWell(
                                onTap:
                                    () => Navigator.pushNamed(
                                      context,
                                      CourseInfoScreen.routeName,
                                      arguments: course.id,
                                    ),
                                child: Container(
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: context.brandColors.cardBackground
                                        .withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: context.brandColors.progressValue
                                          .withOpacity(0.5),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.brandColors.progressValue
                                            .withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  context
                                                      .brandColors
                                                      .progressValue,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${course.reviewCardsCount} ${'home_screen.cards'.tr()}',
                                              style: AppTextStyles.textContent4
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        course.title,
                                        style: AppTextStyles.textContent2
                                            .copyWith(
                                              color:
                                                  context
                                                      .brandColors
                                                      .textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${course.totalTerms} ${'home_screen.cards'.tr()} · ${course.author}',
                                        style: AppTextStyles.textContent4
                                            .copyWith(
                                              color:
                                                  context
                                                      .brandColors
                                                      .searchBarText,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),

          SliverPadding(
            padding: AppPad.h16,
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'home_screen.team_picks'.tr(),
                    style: AppTextStyles.text.copyWith(
                      color: context.brandColors.searchBarText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'home_screen.try_these'.tr(),
                          style: AppTextStyles.textHeader3.copyWith(
                            color: context.brandColors.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          
                          final dashboardState =
                              context
                                  .findAncestorStateOfType<
                                    State<DashboardScreen>
                                  >();
                          if (dashboardState != null) {
                            
                            (dashboardState as dynamic).switchToTab(3);
                          }
                        },
                        child: Text(
                          'home_screen.view_all'.tr(),
                          style: AppTextStyles.textContent3.copyWith(
                            color: context.brandColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: context.brandColors.textPrimary,
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

              final topPicks = notifier.homeData.courses.take(5).toList();

              if (topPicks.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'home_screen.no_courses'.tr(),
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
                                        '${course.totalTerms} ${'home_screen.cards'.tr()} · ${'home_screen.author'.tr()}: ${course.author}',
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
                      'home_screen.study_topics'.tr(),
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
                                    '${classItem.totalStudents} ${'home_screen.students'.tr()} • ${classItem.instructor}',
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
                                        ? 'home_screen.active'.tr()
                                        : 'home_screen.paused'.tr(),
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
                'home_screen.delete_course'.tr(),
                style: TextStyle(color: context.brandColors.textPrimary),
              ),
            ],
          ),
          content: Text(
            'home_screen.delete_course_confirm'.tr(args: [courseTitle]),
            style: TextStyle(color: context.brandColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'common.cancel'.tr(),
                style: TextStyle(color: context.brandColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteCourse(context, courseId, courseTitle);
              },
              child: Text(
                'common.delete'.tr(),
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
                'home_screen.deleting_course'.tr(),
                style: TextStyle(color: context.brandColors.textPrimary),
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
          SnackBar(
            content: Text('home_screen.course_deleted'.tr(args: [courseTitle])),
            backgroundColor: context.brandColors.progressValue,
          ),
        );
      } else {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'home_screen.cannot_delete_course'.tr(args: [courseTitle]),
            ),
            backgroundColor: context.brandColors.buttonDestructive,
          ),
        );
      }
    } catch (e) {
      
      Navigator.of(context).pop();

      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('home_screen.delete_error'.tr(args: [e.toString()])),
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
                'home_screen.delete_topic'.tr(),
                style: TextStyle(color: context.brandColors.textPrimary),
              ),
            ],
          ),
          content: Text(
            'home_screen.delete_topic_confirm'.tr(args: [className]),
            style: TextStyle(color: context.brandColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'common.cancel'.tr(),
                style: TextStyle(color: context.brandColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteClass(context, classId, className);
              },
              child: Text(
                'common.delete'.tr(),
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
                'home_screen.deleting_topic'.tr(),
                style: TextStyle(color: context.brandColors.textPrimary),
              ),
            ],
          ),
        );
      },
    );

    try {
      final success = await notifier.deleteClass(classId);

      
      Navigator.of(context).pop();

      if (success) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('home_screen.topic_deleted'.tr(args: [className])),
            backgroundColor: context.brandColors.progressValue,
          ),
        );
      } else {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'home_screen.cannot_delete_topic'.tr(args: [className]),
            ),
            backgroundColor: context.brandColors.buttonDestructive,
          ),
        );
      }
    } catch (e) {
      
      Navigator.of(context).pop();

      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('home_screen.delete_error'.tr(args: [e.toString()])),
          backgroundColor: context.brandColors.buttonDestructive,
        ),
      );
    }
  }

  
  Future<void> _handleAvatarTap(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    if (authProvider.isSignedIn) {
      
      _showUserInfoDialog(context, authProvider);
    } else {
      
      final success = await authProvider.signInWithGoogle();

      
      

      if (!success && authProvider.errorMessage != null && mounted) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: context.brandColors.buttonDestructive,
          ),
        );
      }
    }
  }

  
  void _showUserInfoDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.brandColors.cardBackground,
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    authProvider.photoURL != null
                        ? NetworkImage(authProvider.photoURL!)
                        : null,
                child:
                    authProvider.photoURL == null
                        ? Icon(
                          Icons.person,
                          color: context.brandColors.searchBarIcon,
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  authProvider.displayName ?? 'common.user'.tr(),
                  style: TextStyle(color: context.brandColors.textPrimary),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'common.email'.tr(),
                style: TextStyle(
                  color: context.brandColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                authProvider.email ?? 'N/A',
                style: TextStyle(color: context.brandColors.textPrimary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'common.close'.tr(),
                style: TextStyle(color: context.brandColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSignOutDialog(context, authProvider);
              },
              child: Text(
                'home_screen.sign_out'.tr(),
                style: TextStyle(color: context.brandColors.buttonDestructive),
              ),
            ),
          ],
        );
      },
    );
  }

  
  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.brandColors.cardBackground,
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: context.brandColors.buttonDestructive,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'home_screen.sign_out'.tr(),
                style: TextStyle(color: context.brandColors.textPrimary),
              ),
            ],
          ),
          content: Text(
            'home_screen.sign_out_confirm'.tr(),
            style: TextStyle(color: context.brandColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'common.cancel'.tr(),
                style: TextStyle(color: context.brandColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                
                print('🔄 [HomeScreen] Syncing data before logout...');
                await DataSyncService().syncAllData();
                print('✅ [HomeScreen] Data synced successfully');

                await authProvider.signOut();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('home_screen.signed_out'.tr()),
                      backgroundColor: context.brandColors.progressValue,
                    ),
                  );
                }
              },
              child: Text(
                'home_screen.sign_out'.tr(),
                style: TextStyle(color: context.brandColors.buttonDestructive),
              ),
            ),
          ],
        );
      },
    );
  }
}
