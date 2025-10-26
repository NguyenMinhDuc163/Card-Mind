import 'package:card_mind/core/widgets/template/function_screen_template.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_pad.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
import 'package:card_mind/modules/home/provider/global_search_notifier.dart';
import 'package:card_mind/modules/course/screen/course_info_screen.dart';
import 'package:card_mind/modules/course/screen/detail_flash_card_screen.dart';
import 'package:card_mind/modules/library/screen/class_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GlobalSearchScreen extends StatefulWidget {
  static const String routeName = '/global-search';

  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  late TextEditingController _searchController;
  late GlobalSearchNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _notifier = Provider.of<GlobalSearchNotifier>(context, listen: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FunctionScreenTemplate(
      isShowAppBar: true,
      backgroundColor: context.colors.primary,
      title: 'Tìm kiếm',
      screen: Column(
        children: [_buildSearchBar(), Expanded(child: _buildSearchResults())],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: AppPad.h16v12,
      padding: AppPad.h16v12,
      decoration: BoxDecoration(
        color: context.brandColors.searchBarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.brandColors.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: context.brandColors.searchBarIcon,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: AppTextStyles.textContent2.copyWith(
                color: context.brandColors.searchBarText,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm học phần, Chủ đề, thẻ chưa học...',
                hintStyle: AppTextStyles.textContent2.copyWith(
                  color: context.brandColors.searchBarText.withOpacity(0.7),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                _notifier.search(value);
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _notifier.clearSearch();
              },
              child: Icon(
                Icons.clear,
                color: context.brandColors.searchBarIcon,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<GlobalSearchNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (notifier.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  color: context.brandColors.searchBarIcon,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  notifier.errorMessage ?? 'Có lỗi xảy ra',
                  style: AppTextStyles.textContent2.copyWith(
                    color: context.brandColors.searchBarText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (notifier.searchQuery.isEmpty) {
          return _buildEmptyState();
        }

        if (notifier.searchResults.isEmpty) {
          return _buildNoResultsState();
        }

        return _buildResultsList(notifier.searchResults);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            color: context.brandColors.searchBarIcon.withOpacity(0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Tìm kiếm toàn bộ nội dung',
            style: AppTextStyles.textContent1.copyWith(
              color: context.brandColors.searchBarText.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tìm kiếm trong học phần, Chủ đề và thẻ chưa học',
            style: AppTextStyles.textContent3.copyWith(
              color: context.brandColors.searchBarText.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            color: context.brandColors.searchBarIcon.withOpacity(0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả',
            style: AppTextStyles.textContent1.copyWith(
              color: context.brandColors.searchBarText.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử tìm kiếm với từ khóa khác',
            style: AppTextStyles.textContent3.copyWith(
              color: context.brandColors.searchBarText.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<SearchResult> results) {
    return ListView.builder(
      padding: AppPad.h16v8,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildSearchResultItem(result);
      },
    );
  }

  Widget _buildSearchResultItem(SearchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.brandColors.cardBackground.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.brandColors.borderColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: () => _navigateToDetail(result),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTypeColor(result.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(result.icon, color: _getTypeColor(result.type), size: 20),
        ),
        title: Text(
          result.title,
          style: AppTextStyles.textContent1.copyWith(
            color: context.brandColors.searchBarText,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              result.subtitle,
              style: AppTextStyles.textContent3.copyWith(
                color: context.brandColors.searchBarText.withOpacity(0.7),
              ),
            ),
            if (result.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                result.description,
                style: AppTextStyles.textContent3.copyWith(
                  color: context.brandColors.searchBarText.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getTypeColor(result.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getTypeLabel(result.type),
                style: AppTextStyles.textContent4.copyWith(
                  color: _getTypeColor(result.type),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: context.brandColors.searchBarIcon.withOpacity(0.4),
          size: 16,
        ),
      ),
    );
  }

  Color _getTypeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.course:
        return context.colors.primary;
      case SearchResultType.classroom:
        return context.colors.secondary;
      case SearchResultType.bookmark:
        return context.colors.error;
    }
  }

  String _getTypeLabel(SearchResultType type) {
    switch (type) {
      case SearchResultType.course:
        return 'Học phần';
      case SearchResultType.classroom:
        return 'Chủ đề';
      case SearchResultType.bookmark:
        return 'Thẻ chưa học';
    }
  }

  void _navigateToDetail(SearchResult result) {
    switch (result.type) {
      case SearchResultType.course:
        Navigator.pushNamed(
          context,
          CourseInfoScreen.routeName,
          arguments: result.id,
        );
        break;
      case SearchResultType.classroom:
        Navigator.pushNamed(
          context,
          ClassDetailScreen.routeName,
          arguments: result.id,
        );
        break;
      case SearchResultType.bookmark:
        Navigator.pushNamed(
          context,
          DetailFlashCardScreen.routeName,
          arguments: result.id,
        );
        break;
    }
  }
}
