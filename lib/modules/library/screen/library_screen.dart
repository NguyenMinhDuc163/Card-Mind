import 'package:card_mind/core/widgets/template/function_screen_template.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_pad.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
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

  final List<String> _tabs = ['Học phần', 'Lớp học', 'Thư viện'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            'Thư viện',
            style: AppTextStyles.textHeader1.copyWith(
              color: context.colors.onPrimary,
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Implement add new content
            },
            child: Container(
              padding: AppPad.a8,
              decoration: BoxDecoration(
                color: context.colors.onSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: context.colors.primary, size: 24),
            ),
          ),
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
              String tab = entry.value;
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
                      tab,
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
            child: Text(
              'Tìm kiếm',
              style: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary.withOpacity(0.6),
              ),
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
        _buildContentList('Học phần'),
        _buildContentList('Lớp học'),
        _buildContentList('Thư viện'),
      ],
    );
  }

  Widget _buildContentList(String tabType) {
    return SingleChildScrollView(
      padding: AppPad.h16v8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateGroup('Tuần này', [
            _buildContentItem(
              'Thông tin cơ bản về Card Mind',
              '9 thuật ngữ • Tác giả: Card Mind',
              tabType,
            ),
            _buildContentItem(
              'Cơ sở an toàn thông tin - chương 1 - chương 2...',
              '39 thuật ngữ • Tác giả: huynhuy...',
              tabType,
            ),
          ]),
          const SizedBox(height: 24),
          _buildDateGroup('Tháng 4 2024', [
            _buildContentItem(
              '(C2W4): Start the UX Design Process: Empathi...',
              '29 thuật ngữ • Tác giả: SBMRGD',
              tabType,
            ),
          ]),
          const SizedBox(height: 24),
          _buildDateGroup('Tháng 2 2024', [
            _buildContentItem(
              'Sample Content Item',
              '15 thuật ngữ • Tác giả: Sample Author',
              tabType,
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDateGroup(String date, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: AppTextStyles.textContent1.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildContentItem(String title, String details, String tabType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppPad.h16v12,
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.onPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.onPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.credit_card,
              color: context.colors.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.textContent2.copyWith(
                    color: context.colors.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: AppTextStyles.textContent3.copyWith(
                    color: context.colors.onPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
