import 'package:card_mind/core/widgets/template/function_screen_template.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_pad.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
import 'package:card_mind/modules/library/widgets/bookmark_screen.dart';
import 'package:card_mind/modules/library/widgets/class_screen.dart';
import 'package:card_mind/modules/library/widgets/content_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LibraryScreen extends StatefulWidget {
  static const String routeName = '/library';

  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  late TextEditingController _searchController;

  final List<String> _tabs = [
    'library.tabs.courses',
    'library.tabs.classes',
    'library.tabs.bookmarks',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController = TextEditingController();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy tab index từ arguments (nếu có)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is int) {
      if (args >= 0 && args < _tabs.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _tabController.index != args) {
            _tabController.animateTo(args);
            setState(() {
              _selectedTabIndex = args;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FunctionScreenTemplate(
      isShowAppBar: false,
      backgroundColor: context.colors.primary,
      screen: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          _buildSearchBar(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: AppPad.h16v20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'library.title'.tr(),
            style: AppTextStyles.textHeader1.copyWith(
              color: context.colors.onPrimary,
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     // TODO: Implement add new content
          //   },
          //   child: Container(
          //     padding: AppPad.a8,
          //     decoration: BoxDecoration(
          //       color: context.colors.onSecondary,
          //       shape: BoxShape.circle,
          //     ),
          //     child: Icon(Icons.add, color: context.colors.primary, size: 24),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: AppPad.h16v12,
      child: Row(
        children:
            _tabs.asMap().entries.map((entry) {
              int index = entry.key;
              String tabKey = entry.value;
              bool isSelected = index == _selectedTabIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    _tabController.animateTo(index);
                  },
                  child: Container(
                    margin: AppPad.h4,
                    padding: AppPad.h16v12,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? context.colors.onPrimary
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.colors.onPrimary,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tabKey.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.textContent2.copyWith(
                        color:
                            isSelected
                                ? context.colors.primary
                                : context.colors.onPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: AppPad.h16v12,
      padding: AppPad.h16v12,
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.onPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: context.colors.onPrimary.withOpacity(0.6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary,
              ),
              decoration: InputDecoration(
                hintText: _getSearchHint(),
                hintStyle: AppTextStyles.textContent2.copyWith(
                  color: context.colors.onPrimary.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                _onSearchChanged(value);
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              child: Icon(
                Icons.clear,
                color: context.colors.onPrimary.withOpacity(0.6),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        ContentScreen(
          tabType: 'library.tabs.courses'.tr(),
          searchQuery: _searchQuery,
        ),
        ClassScreen(searchQuery: _searchQuery),
        BookmarkScreen(searchQuery: _searchQuery),
      ],
    );
  }

  String _getSearchHint() {
    switch (_selectedTabIndex) {
      case 0:
        return 'library.search_hint.courses'.tr();
      case 1:
        return 'library.search_hint.classes'.tr();
      case 2:
        return 'library.search_hint.bookmarks'.tr();
      default:
        return 'library.search_hint.general'.tr();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }
}
