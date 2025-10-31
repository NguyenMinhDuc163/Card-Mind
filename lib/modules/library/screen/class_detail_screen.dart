import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/library/model/class_data.dart';
import 'package:card_mind/modules/library/model/content_data.dart';
import 'package:card_mind/modules/library/provider/class_notifier.dart';
import 'package:card_mind/modules/library/widgets/edit_class_bottom_sheet.dart';
import 'package:card_mind/modules/library/widgets/class_content_item_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassDetailScreen extends StatefulWidget {
  const ClassDetailScreen({super.key});

  static const String routeName = '/ClassDetailScreen';

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  ClassData? _classData;
  List<ContentData> _classContents = [];
  List<ContentData> _pendingRemovals = [];
  List<ContentData> _pendingAdditions = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final classId = ModalRoute.of(context)?.settings.arguments as String?;
      if (classId != null) {
        await _loadClassData(classId);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = tr(
        'library.class_detail.error_loading',
        args: [e.toString()],
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadClassData(String classId) async {
    final notifier = Provider.of<ClassNotifier>(context, listen: false);
    await notifier.initializeData();

    print('DEBUG: Looking for class with ID: $classId');
    print('DEBUG: Available classes: ${notifier.classes.length}');

    try {
      final classData = notifier.classes.firstWhere(
        (c) => c.id == classId,
        orElse: () => throw Exception('library.class_detail.not_found'.tr()),
      );

      _classData = classData;

      _classContents =
          notifier.availableContents
              .where((content) => classData.students.contains(content.id))
              .toList();

      print('DEBUG: Found class: ${classData.className}');
      print('DEBUG: Class contents: ${_classContents.length}');
    } catch (e) {
      print('DEBUG: Error finding class: $e');
      rethrow;
    }
  }

  void _showEditClassBottomSheet() {
    if (_classData != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => EditClassBottomSheet(classData: _classData!),
      );
    }
  }

  void _showAddContentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _AddContentBottomSheet(
            availableContents: _getAvailableContents(),
            onContentsSelected: (selectedContents) {
              _addContentsToClass(selectedContents);
            },
          ),
    );
  }

  List<ContentData> _getAvailableContents() {
    final notifier = Provider.of<ClassNotifier>(context, listen: false);
    final currentContentIds = _classContents.map((c) => c.id).toList();
    return notifier.availableContents
        .where((content) => !currentContentIds.contains(content.id))
        .toList();
  }

  void _addContentsToClass(List<ContentData> contents) {
    setState(() {
      _pendingAdditions.addAll(contents);
      _hasChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'library.class_detail.snackbar_added'.tr(
            args: [contents.length.toString()],
          ),
        ),
      ),
    );
  }

  void _showDeleteClassDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: context.colors.primary,
            title: Text(
              'library.class_detail.delete_title'.tr(),
              style: AppTextStyles.textContent1.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'library.class_detail.delete_confirm'.tr(
                args: [_classData?.className ?? ''],
              ),
              style: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary.withOpacity(0.8),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'common.cancel'.tr(),
                  style: AppTextStyles.textContent2.copyWith(
                    color: context.colors.onPrimary.withOpacity(0.7),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_classData != null) {
                    final notifier = Provider.of<ClassNotifier>(
                      context,
                      listen: false,
                    );
                    notifier.deleteClass(_classData!.id);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'library.class_detail.snackbar_deleted'.tr(),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('common.delete'.tr()),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return FunctionScreenTemplate(
        backgroundColor: context.colors.primary,
        screen: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_errorMessage != null) {
      return FunctionScreenTemplate(
        backgroundColor: context.colors.primary,
        screen: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: context.colors.onPrimary, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
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

    if (_classData == null) {
      return FunctionScreenTemplate(
        backgroundColor: context.colors.primary,
        screen: Center(
          child: Text(
            'library.class_detail.not_found'.tr(),
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return FunctionScreenTemplate(
      backgroundColor: context.colors.primary,
      titleWidget: Text(
        _classData!.className,
        style: AppTextStyles.textContent1.copyWith(
          color: context.colors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actionsWidget: [
        IconButton(
          onPressed: _showEditClassBottomSheet,
          icon: const Icon(Icons.edit),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteClassDialog();
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text('library.class_detail.delete_action'.tr()),
                    ],
                  ),
                ),
              ],
        ),
      ],
      screen: Scaffold(
        backgroundColor: context.colors.primary,
        floatingActionButton:
            _hasChanges
                ? null
                : FloatingActionButton(
                  heroTag: "class_detail_add_fab",
                  onPressed: _showAddContentBottomSheet,
                  backgroundColor: context.colors.onPrimary,
                  foregroundColor: context.colors.primary,
                  child: const Icon(Icons.add, size: 28),
                ),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppPad.h16v20,
                    child: Container(
                      padding: AppPad.h16v20,
                      decoration: BoxDecoration(
                        color: context.colors.onPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.colors.onPrimary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.school,
                                color: context.colors.onPrimary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _classData!.className,
                                  style: AppTextStyles.textContent1.copyWith(
                                    color: context.colors.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_classData!.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              _classData!.description,
                              style: AppTextStyles.textContent2.copyWith(
                                color: context.colors.onPrimary.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildInfoChip(
                                context,
                                Icons.people,
                                'library.class_detail.info_students'.tr(
                                  args: [_classData!.totalStudents.toString()],
                                ),
                              ),
                              const SizedBox(width: 16),
                              _buildInfoChip(
                                context,
                                Icons.library_books,
                                'library.class_detail.info_courses'.tr(
                                  args: [
                                    _classData!.students.length.toString(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppPad.h16v8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'library.class_detail.section_title'.tr(),
                          style: AppTextStyles.textContent1.copyWith(
                            color: context.colors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_hasChanges) ...[
                          Text(
                            'library.class_detail.pending_changes'.tr(
                              args: [
                                _pendingAdditions.length.toString(),
                                _pendingRemovals.length.toString(),
                              ],
                            ),
                            style: AppTextStyles.textContent3.copyWith(
                              color: context.colors.onPrimary.withOpacity(0.7),
                            ),
                          ),
                        ] else
                          TextButton.icon(
                            onPressed: _showEditClassBottomSheet,
                            icon: const Icon(Icons.edit, size: 16),
                            label: Text('library.class_detail.edit'.tr()),
                            style: TextButton.styleFrom(
                              foregroundColor: context.colors.onPrimary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                if (_classContents.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: AppPad.h16v20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 40,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.onPrimary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colors.onPrimary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.library_books_outlined,
                              color: context.colors.onPrimary.withOpacity(0.5),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'library.class_detail.empty_contents_title'.tr(),
                              style: AppTextStyles.textContent2.copyWith(
                                color: context.colors.onPrimary.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'library.class_detail.empty_contents_subtitle'
                                  .tr(),
                              style: AppTextStyles.textContent3.copyWith(
                                color: context.colors.onPrimary.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final content = _classContents[index];
                      final isPendingRemoval = _pendingRemovals.contains(
                        content,
                      );
                      return Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: index == _classContents.length - 1 ? 100 : 12,
                        ),
                        child: ClassContentItemWidget(
                          content: content,
                          isPendingRemoval: isPendingRemoval,
                          onToggleRemoval:
                              isPendingRemoval
                                  ? () => _unmarkContentForRemoval(content)
                                  : () => _markContentForRemoval(content),
                        ),
                      );
                    }, childCount: _classContents.length),
                  ),
              ],
            ),

            if (_hasChanges)
              Positioned(
                bottom: 20,
                right: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: "class_detail_cancel_fab",
                      onPressed: _cancelChanges,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.close, size: 24),
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton(
                      heroTag: "class_detail_save_fab",
                      onPressed: _saveChanges,
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.save, size: 24),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.onPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: context.colors.onPrimary, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.textContent3.copyWith(
              color: context.colors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _markContentForRemoval(ContentData content) {
    setState(() {
      _pendingRemovals.add(content);
      _hasChanges = true;
    });
  }

  void _unmarkContentForRemoval(ContentData content) {
    setState(() {
      _pendingRemovals.remove(content);
      _hasChanges = _pendingRemovals.isNotEmpty || _pendingAdditions.isNotEmpty;
    });
  }

  void _saveChanges() {
    if (_classData != null &&
        (_pendingRemovals.isNotEmpty || _pendingAdditions.isNotEmpty)) {
      final updatedStudents = List<String>.from(_classData!.students);

      for (final content in _pendingRemovals) {
        updatedStudents.remove(content.id);
      }

      for (final content in _pendingAdditions) {
        if (!updatedStudents.contains(content.id)) {
          updatedStudents.add(content.id);
        }
      }

      final updatedClassData = _classData!.copyWith(
        students: updatedStudents,
        totalStudents: updatedStudents.length,
      );

      final notifier = Provider.of<ClassNotifier>(context, listen: false);
      notifier.saveClass(updatedClassData);

      setState(() {
        _classData = updatedClassData;

        _classContents.removeWhere(
          (content) =>
              _pendingRemovals.any((removed) => removed.id == content.id),
        );
        _classContents.addAll(_pendingAdditions);

        _pendingRemovals.clear();
        _pendingAdditions.clear();
        _hasChanges = false;
      });

      final totalChanges = _pendingRemovals.length + _pendingAdditions.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'library.class_detail.snackbar_saved_changes'.tr(
              args: [totalChanges.toString()],
            ),
          ),
        ),
      );
    }
  }

  void _cancelChanges() {
    setState(() {
      _pendingRemovals.clear();
      _pendingAdditions.clear();
      _hasChanges = false;
    });
  }
}

class _AddContentBottomSheet extends StatefulWidget {
  const _AddContentBottomSheet({
    required this.availableContents,
    required this.onContentsSelected,
  });

  final List<ContentData> availableContents;
  final Function(List<ContentData>) onContentsSelected;

  @override
  State<_AddContentBottomSheet> createState() => _AddContentBottomSheetState();
}

class _AddContentBottomSheetState extends State<_AddContentBottomSheet> {
  final Set<String> _selectedContentIds = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'library.class_detail.add_modal.title'.tr(),
            style: AppTextStyles.textHeader3.copyWith(
              color: context.colors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          if (widget.availableContents.isEmpty)
            Container(
              padding: AppPad.h16v20,
              decoration: BoxDecoration(
                color: context.colors.onPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: context.colors.onPrimary.withOpacity(0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'library.class_detail.add_modal.empty'.tr(),
                      style: AppTextStyles.textContent3.copyWith(
                        color: context.colors.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: context.colors.onPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.onPrimary.withOpacity(0.2),
                ),
              ),
              child: ListView.builder(
                padding: AppPad.h12v8,
                itemCount: widget.availableContents.length,
                itemBuilder: (context, index) {
                  final content = widget.availableContents[index];
                  final isSelected = _selectedContentIds.contains(content.id);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedContentIds.remove(content.id);
                        } else {
                          _selectedContentIds.add(content.id);
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: AppPad.h12v8,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? context.colors.onPrimary.withOpacity(0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected
                                  ? context.colors.onPrimary
                                  : context.colors.onPrimary.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color:
                                isSelected
                                    ? context.colors.onPrimary
                                    : context.colors.onPrimary.withOpacity(0.5),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content.title,
                                  style: AppTextStyles.textContent3.copyWith(
                                    color: context.colors.onPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'library.class_detail.add_modal.term_count'
                                      .tr(
                                        args: [content.totalTerms.toString()],
                                      ),
                                  style: AppTextStyles.textContent4.copyWith(
                                    color: context.colors.onPrimary.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: AppPad.h16v12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'common.cancel'.tr(),
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed:
                      _selectedContentIds.isEmpty
                          ? null
                          : () {
                            final selectedContents =
                                widget.availableContents
                                    .where(
                                      (content) => _selectedContentIds.contains(
                                        content.id,
                                      ),
                                    )
                                    .toList();
                            widget.onContentsSelected(selectedContents);
                            Navigator.pop(context);
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.onPrimary,
                    foregroundColor: context.colors.primary,
                    padding: AppPad.h16v12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'library.class_detail.add_modal.confirm'.tr(
                      args: [_selectedContentIds.length.toString()],
                    ),
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
