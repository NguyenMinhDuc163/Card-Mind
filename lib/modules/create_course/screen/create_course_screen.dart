import 'package:card_mind/init.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_pad.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

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

  List<TermItem> _terms = [
    TermItem(term: '', definition: '', language: 'Tiếng Việt'),
  ];

  bool _showDescription = false;

  @override
  void dispose() {
    _topicController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildCourseInfo(),
                  const SizedBox(height: 24),
                  _buildAdditionalFeatures(),
                  const SizedBox(height: 24),
                  _buildTermsList(),
                  const SizedBox(height: 80), // Space for floating button
                ],
              ),
            ),
          ),
          Container(
            padding: AppPad.h16v12,
            child: Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _terms.add(
                      TermItem(
                        term: '',
                        definition: '',
                        language: 'Tiếng Việt',
                      ),
                    );
                  });
                },
                backgroundColor: Colors.blue,
                shape: const CircleBorder(),
                child: Icon(
                  Icons.add,
                  color: context.colors.onPrimary,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: context.colors.onPrimary,
            size: 24,
          ),
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
              onTap: () {
                // TODO: Implement settings
              },
              child: Icon(
                Icons.settings,
                color: context.colors.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                // TODO: Implement complete course creation
              },
              child: Icon(
                Icons.check,
                color: context.colors.onPrimary,
                size: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Topic field
        TextField(
          controller: _topicController,
          style: AppTextStyles.textContent2.copyWith(
            color: context.colors.onPrimary,
          ),
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
        // Title field
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
            style: AppTextStyles.textContent2.copyWith(
              color: context.colors.onPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập mô tả cho khóa học...',
              hintStyle: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary.withOpacity(0.6),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: context.colors.onPrimary,
                  width: 1,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: context.colors.onPrimary,
                  width: 1,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: context.colors.onPrimary,
                  width: 2,
                ),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalFeatures() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: Implement scan document
            },
            child: Row(
              children: [
                Icon(
                  Icons.document_scanner,
                  color: context.colors.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quét tài liệu',
                  style: AppTextStyles.textContent2.copyWith(
                    color: context.colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: AppPad.h12v8,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(6),
          ),
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

  Widget _buildTermsList() {
    return Column(
      children:
          _terms.asMap().entries.map((entry) {
            int index = entry.key;
            TermItem term = entry.value;
            return _buildTermItem(term, index);
          }).toList(),
    );
  }

  Widget _buildTermItem(TermItem term, int index) {
    return Dismissible(
      key: Key('term_$index'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: AppPad.h16,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: context.colors.onPrimary, size: 24),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: AppPad.h16,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: context.colors.onPrimary, size: 24),
      ),
      onDismissed: (direction) {
        setState(() {
          _terms.removeAt(index);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: AppPad.h16v20,
        decoration: BoxDecoration(
          color: context.colors.primary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.onPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Term field
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
              controller: term.termController,
              style: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary,
              ),
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.onPrimary,
                    width: 1,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.onPrimary,
                    width: 1,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.onPrimary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Definition field
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
              controller: term.definitionController,
              style: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary,
              ),
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.onPrimary,
                    width: 1,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.onPrimary,
                    width: 1,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.onPrimary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Language selection
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
                // TODO: Show language picker
              },
              child: Container(
                padding: AppPad.v12,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.blue, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      term.language,
                      style: AppTextStyles.textContent2.copyWith(
                        color: Colors.blue,
                      ),
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
}

class TermItem {
  final TextEditingController termController = TextEditingController();
  final TextEditingController definitionController = TextEditingController();
  String language;

  TermItem({
    required String term,
    required String definition,
    required this.language,
  }) {
    termController.text = term;
    definitionController.text = definition;
  }
}
