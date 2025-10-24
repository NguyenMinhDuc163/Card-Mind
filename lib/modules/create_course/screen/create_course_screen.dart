import 'package:card_mind/init.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_pad.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
import 'package:card_mind/modules/create_course/provider/create_course_notifier.dart';
import 'package:card_mind/modules/create_course/model/create_course_data.dart';
import 'package:card_mind/modules/create_course/services/course_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateCourseScreen extends StatefulWidget {
  static const String routeName = '/create-course';

  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CourseService _courseService = CourseService();

  bool _showDescription = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final notifier = Provider.of<CreateCourseNotifier>(context, listen: false);
    await notifier.initializeData();

    if (mounted) {
      setState(() {
        _isInitialized = true;
        _loadDataToControllers(notifier.courseData);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.notifyListeners();
      });
    }
  }

  void _loadDataToControllers(CreateCourseData courseData) {
    _topicController.text = courseData.topic;
    _titleController.text = courseData.title;
    _descriptionController.text = courseData.description ?? '';
    _showDescription = courseData.description != null && courseData.description!.isNotEmpty;
  }

  @override
  void dispose() {
    _topicController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateCourseNotifier>(
      builder: (context, notifier, child) {
        if (!_isInitialized || notifier.isLoading) {
          return FunctionScreenTemplate(
            isShowAppBar: false,
            backgroundColor: context.colors.primary,
            screen: const Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (notifier.hasError) {
          return FunctionScreenTemplate(
            isShowAppBar: false,
            backgroundColor: context.colors.primary,
            screen: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: context.colors.onPrimary, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    notifier.errorMessage ?? 'Có lỗi xảy ra',
                    style: AppTextStyles.textContent2.copyWith(color: context.colors.onPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => _initializeData(), child: const Text('Thử lại')),
                ],
              ),
            ),
          );
        }

        return FunctionScreenTemplate(
          isShowAppBar: false,
          backgroundColor: context.colors.primary,
          screen: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: AppPad.h16v20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(notifier),
                      const SizedBox(height: 24),
                      _buildCourseInfo(notifier),
                      const SizedBox(height: 24),
                      _buildAdditionalFeatures(notifier),
                      const SizedBox(height: 24),
                      _buildTermsList(notifier),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              Container(
                padding: AppPad.h16v12,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FloatingActionButton(
                    onPressed: () => _addNewTerm(notifier),
                    backgroundColor: Colors.blue,
                    shape: const CircleBorder(),
                    child: Icon(Icons.add, color: context.colors.onPrimary, size: 28),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addNewTerm(CreateCourseNotifier notifier) {
    notifier.addTerm();
  }

  void _updateCourseInfo(CreateCourseNotifier notifier) {
    notifier.updateCourseInfo(
      topic: _topicController.text,
      title: _titleController.text,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
    );
    notifier.saveData();
  }

  void _completeCourse(CreateCourseNotifier notifier) async {
    _updateCourseInfo(notifier);

    await notifier.completeCourse();

    _topicController.clear();
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _showDescription = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu khóa học!')));
  }

  Widget _buildHeader(CreateCourseNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: context.colors.onPrimary, size: 24),
        ),
        Text(
          '2/2',
          style: AppTextStyles.textContent1.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: Icon(Icons.settings, color: context.colors.onPrimary, size: 24),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => _completeCourse(notifier),
              child: Icon(
                Icons.check,
                color:
                    notifier.isDataValid
                        ? context.colors.onPrimary
                        : context.colors.onPrimary.withOpacity(0.5),
                size: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseInfo(CreateCourseNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _topicController,
          onChanged: (value) => _updateCourseInfo(notifier),
          style: AppTextStyles.textContent2.copyWith(color: context.colors.onPrimary),
          decoration: InputDecoration(
            hintText: 'Chủ đề, chương, đơn vị',
            hintStyle: AppTextStyles.textContent2.copyWith(
              color: context.colors.onPrimary.withOpacity(0.6),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.colors.onPrimary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'TIÊU ĐỀ',
          style: AppTextStyles.textContent3.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          onChanged: (value) => _updateCourseInfo(notifier),
          style: AppTextStyles.textContent1.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.colors.onPrimary, width: 2),
            ),
          ),
        ),
        if (_showDescription) ...[
          const SizedBox(height: 24),
          Text(
            'MÔ TẢ',
            style: AppTextStyles.textContent3.copyWith(
              color: context.colors.onPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            onChanged: (value) => _updateCourseInfo(notifier),
            style: AppTextStyles.textContent2.copyWith(color: context.colors.onPrimary),
            decoration: InputDecoration(
              hintText: 'Nhập mô tả cho khóa học...',
              hintStyle: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary.withOpacity(0.6),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.colors.onPrimary, width: 2),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalFeatures(CreateCourseNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Icon(Icons.document_scanner, color: context.colors.onPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Quét tài liệu',
                  style: AppTextStyles.textContent2.copyWith(color: context.colors.onPrimary),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: AppPad.h12v8,
          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(6)),
          child: Icon(Icons.lock, color: context.colors.onPrimary, size: 16),
        ),
        const SizedBox(width: 16),
        if (!_showDescription)
          GestureDetector(
            onTap: () {
              setState(() {
                _showDescription = true;
              });
            },
            child: Text(
              '+ Mô tả',
              style: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTermsList(CreateCourseNotifier notifier) {
    return Column(
      children:
          notifier.courseData.terms.asMap().entries.map((entry) {
            int index = entry.key;
            TermData term = entry.value;
            return _buildTermItem(term, index, notifier);
          }).toList(),
    );
  }

  Widget _buildTermItem(TermData term, int index, CreateCourseNotifier notifier) {
    final termController = TextEditingController(text: term.term);
    final definitionController = TextEditingController(text: term.definition);

    return Dismissible(
      key: Key('term_${term.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: AppPad.h16,
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.delete, color: context.colors.onPrimary, size: 24),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: AppPad.h16,
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.delete, color: context.colors.onPrimary, size: 24),
      ),
      onDismissed: (direction) {
        notifier.removeTerm(index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: AppPad.h16v20,
        decoration: BoxDecoration(
          color: context.colors.primary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.onPrimary.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THUẬT NGỮ',
              style: AppTextStyles.textContent3.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: termController,
              onChanged: (value) {
                final updatedTerm = term.copyWith(term: value);
                notifier.updateTerm(index, updatedTerm);
                notifier.saveData();
              },
              style: AppTextStyles.textContent2.copyWith(color: context.colors.onPrimary),
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.colors.onPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'ĐỊNH NGHĨA',
              style: AppTextStyles.textContent3.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: definitionController,
              onChanged: (value) {
                final updatedTerm = term.copyWith(definition: value);
                notifier.updateTerm(index, updatedTerm);
                notifier.saveData();
              },
              style: AppTextStyles.textContent2.copyWith(color: context.colors.onPrimary),
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.colors.onPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'CHỌN NGÔN NGỮ',
              style: AppTextStyles.textContent3.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _showLanguagePicker(term, index, notifier);
              },
              child: Container(
                padding: AppPad.v12,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.blue, width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      term.language,
                      style: AppTextStyles.textContent2.copyWith(color: Colors.blue),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.blue, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(TermData term, int index, CreateCourseNotifier notifier) {
    final languages = ['Tiếng Việt', 'English', '日本語', '한국어', '中文'];

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  languages.map((language) {
                    return ListTile(
                      title: Text(language),
                      onTap: () {
                        final updatedTerm = term.copyWith(language: language);
                        notifier.updateTerm(index, updatedTerm);
                        notifier.saveData();
                        Navigator.pop(context);
                      },
                      trailing: term.language == language ? const Icon(Icons.check) : null,
                    );
                  }).toList(),
            ),
          ),
    );
  }
}
