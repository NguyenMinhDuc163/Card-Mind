import 'package:card_mind/core/services/spaced_repetition_service.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SpacedRepetitionSettingsScreen extends StatefulWidget {
  const SpacedRepetitionSettingsScreen({super.key});

  static const String routeName = '/SpacedRepetitionSettingsScreen';

  @override
  State<SpacedRepetitionSettingsScreen> createState() =>
      _SpacedRepetitionSettingsScreenState();
}

class _SpacedRepetitionSettingsScreenState
    extends State<SpacedRepetitionSettingsScreen> {
  final _service = SpacedRepetitionService();

  late String _timeUnit;
  late int _interval1;
  late int _interval2;
  late int _maxInterval;
  late int _autoRefreshInterval;

  @override
  void initState() {
    super.initState();
    _loadConfig();
    // Đảm bảo các giá trị interval phù hợp với timeUnit hiện tại
    _adjustIntervalsForTimeUnit();
  }

  void _loadConfig() {
    _timeUnit = _service.timeUnit;
    _interval1 = _service.interval1;
    _interval2 = _service.interval2;
    _maxInterval = _service.maxInterval;
    _autoRefreshInterval = _service.autoRefreshInterval;
  }

  void _adjustIntervalsForTimeUnit() {
    if (_timeUnit == 'minutes') {
      // Điều chỉnh về giá trị phù hợp cho phút
      _interval1 = _interval1.clamp(1, 10);
      _interval2 = _interval2.clamp(1, 20);
      _maxInterval = _maxInterval.clamp(20, 60);
    } else {
      // Điều chỉnh về giá trị phù hợp cho ngày
      _interval1 = _interval1.clamp(1, 7);
      _interval2 = _interval2.clamp(1, 14);
      _maxInterval = _maxInterval.clamp(30, 365);
    }
  }

  Future<void> _saveConfig() async {
    await _service.updateConfig(
      timeUnit: _timeUnit,
      interval1: _interval1,
      interval2: _interval2,
      maxInterval: _maxInterval,
      autoRefreshInterval: _autoRefreshInterval,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('spaced_repetition_settings.snackbar_saved'.tr()),
          backgroundColor: context.brandColors.progressValue,
        ),
      );
    }
  }

  Future<void> _resetToDefault() async {
    await _service.resetToDefault();
    setState(() {
      _loadConfig();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('spaced_repetition_settings.snackbar_reset'.tr()),
          backgroundColor: context.brandColors.progressValue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstUnitLabel = _timeUnitLabel(_interval1);
    final secondUnitLabel = _timeUnitLabel(_interval2);
    final maxUnitLabel = _timeUnitLabel(_maxInterval);
    final approxInterval = (_interval2 * 2.5).round();
    final approxUnitLabel = _timeUnitLabel(approxInterval);
    final autoRefreshUnitLabel = _secondsLabel(_autoRefreshInterval);

    return Scaffold(
      backgroundColor: context.colors.primary,
      appBar: AppBar(
        backgroundColor: context.colors.primary,
        title: Text(
          'spaced_repetition_settings.title'.tr(),
          style: TextStyle(color: context.colors.onPrimary),
        ),
        iconTheme: IconThemeData(color: context.colors.onPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetToDefault,
            tooltip: 'spaced_repetition_settings.tooltip_reset'.tr(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPad.a16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: context.brandColors.cardBackground,
              child: Padding(
                padding: AppPad.a16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: context.brandColors.progressValue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'spaced_repetition_settings.info.title'.tr(),
                          style: AppTextStyles.textHeader3.copyWith(
                            color: context.brandColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'spaced_repetition_settings.info.description'.tr(),
                      style: AppTextStyles.textContent3.copyWith(
                        color: context.brandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Đơn vị thời gian
            _buildSectionTitle(
              'spaced_repetition_settings.sections.time_unit.title'.tr(),
            ),
            Card(
              color: context.brandColors.cardBackground,
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(
                      'spaced_repetition_settings.sections.time_unit.days_title'
                          .tr(),
                      style: TextStyle(color: context.brandColors.textPrimary),
                    ),
                    subtitle: Text(
                      'spaced_repetition_settings.sections.time_unit.days_subtitle'
                          .tr(),
                      style: TextStyle(
                        color: context.brandColors.textSecondary,
                      ),
                    ),
                    value: 'days',
                    groupValue: _timeUnit,
                    onChanged: (value) {
                      setState(() {
                        _timeUnit = value!;
                        _adjustIntervalsForTimeUnit();
                      });
                    },
                    activeColor: context.brandColors.progressValue,
                  ),
                  Divider(height: 1),
                  RadioListTile<String>(
                    title: Text(
                      'spaced_repetition_settings.sections.time_unit.minutes_title'
                          .tr(),
                      style: TextStyle(color: context.brandColors.textPrimary),
                    ),
                    subtitle: Text(
                      'spaced_repetition_settings.sections.time_unit.minutes_subtitle'
                          .tr(),
                      style: TextStyle(
                        color: context.brandColors.textSecondary,
                      ),
                    ),
                    value: 'minutes',
                    groupValue: _timeUnit,
                    onChanged: (value) {
                      setState(() {
                        _timeUnit = value!;
                        _adjustIntervalsForTimeUnit();
                      });
                    },
                    activeColor: context.brandColors.progressValue,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Intervals
            _buildSectionTitle(
              'spaced_repetition_settings.sections.intervals.title'.tr(),
            ),

            _buildSliderSetting(
              title:
                  'spaced_repetition_settings.sections.intervals.first_title'
                      .tr(),
              subtitle:
                  'spaced_repetition_settings.sections.intervals.first_subtitle'
                      .tr(args: [_interval1.toString(), firstUnitLabel]),
              value: _interval1.toDouble(),
              min: 1,
              max: _timeUnit == 'days' ? 7 : 10,
              divisions: (_timeUnit == 'days' ? 6 : 9),
              onChanged: (value) {
                setState(() => _interval1 = value.round());
              },
            ),

            _buildSliderSetting(
              title:
                  'spaced_repetition_settings.sections.intervals.second_title'
                      .tr(),
              subtitle:
                  'spaced_repetition_settings.sections.intervals.second_subtitle'
                      .tr(args: [_interval2.toString(), secondUnitLabel]),
              value: _interval2.toDouble(),
              min: 1,
              max: _timeUnit == 'days' ? 14 : 20,
              divisions: (_timeUnit == 'days' ? 13 : 19),
              onChanged: (value) {
                setState(() => _interval2 = value.round());
              },
            ),

            _buildSliderSetting(
              title:
                  'spaced_repetition_settings.sections.intervals.max_title'
                      .tr(),
              subtitle:
                  'spaced_repetition_settings.sections.intervals.max_subtitle'
                      .tr(args: [_maxInterval.toString(), maxUnitLabel]),
              value: _maxInterval.toDouble(),
              min: _timeUnit == 'days' ? 30 : 20,
              max: _timeUnit == 'days' ? 365 : 60,
              divisions: _timeUnit == 'days' ? 67 : 40,
              onChanged: (value) {
                setState(() => _maxInterval = value.round());
              },
            ),

            SizedBox(height: 24),

            // Auto Refresh Interval
            _buildSectionTitle(
              'spaced_repetition_settings.sections.auto_refresh.title'.tr(),
            ),
            _buildSliderSetting(
              title:
                  'spaced_repetition_settings.sections.auto_refresh.interval_title'
                      .tr(),
              subtitle:
                  'spaced_repetition_settings.sections.auto_refresh.interval_subtitle'
                      .tr(
                        args: [
                          _autoRefreshInterval.toString(),
                          autoRefreshUnitLabel,
                        ],
                      ),
              value: _autoRefreshInterval.toDouble(),
              min: 10,
              max: 300,
              divisions: 29,
              onChanged: (value) {
                setState(() => _autoRefreshInterval = value.round());
              },
            ),

            SizedBox(height: 24),

            // Timeline preview
            _buildSectionTitle(
              'spaced_repetition_settings.sections.timeline.title'.tr(),
            ),
            Card(
              color: context.brandColors.cardBackground,
              child: Padding(
                padding: AppPad.a16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimelineItem(
                      'spaced_repetition_settings.sections.timeline.first_label'
                          .tr(),
                      'spaced_repetition_settings.sections.timeline.first_value'
                          .tr(args: [_interval1.toString(), firstUnitLabel]),
                    ),
                    _buildTimelineItem(
                      'spaced_repetition_settings.sections.timeline.second_label'
                          .tr(),
                      'spaced_repetition_settings.sections.timeline.second_value'
                          .tr(args: [_interval2.toString(), secondUnitLabel]),
                    ),
                    _buildTimelineItem(
                      'spaced_repetition_settings.sections.timeline.third_label'
                          .tr(),
                      'spaced_repetition_settings.sections.timeline.third_value'
                          .tr(
                            args: [
                              approxInterval.toString(),
                              approxUnitLabel,
                              _interval2.toString(),
                            ],
                          ),
                    ),
                    _buildTimelineItem(
                      'spaced_repetition_settings.sections.timeline.max_label'
                          .tr(),
                      'spaced_repetition_settings.sections.timeline.max_value'
                          .tr(args: [_maxInterval.toString(), maxUnitLabel]),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),

            // Nút lưu
            ElevatedButton(
              onPressed: _saveConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.brandColors.buttonPrimary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'spaced_repetition_settings.button_save'.tr(),
                style: AppTextStyles.textHeader3.copyWith(
                  color: context.brandColors.textPrimary,
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _timeUnitLabel(int value) {
    final isDays = _timeUnit == 'days';
    final key =
        value == 1
            ? (isDays
                ? 'spaced_repetition_settings.units.day'
                : 'spaced_repetition_settings.units.minute')
            : (isDays
                ? 'spaced_repetition_settings.units.days'
                : 'spaced_repetition_settings.units.minutes');
    return key.tr();
  }

  String _secondsLabel(int value) {
    final key =
        value == 1
            ? 'spaced_repetition_settings.units.second'
            : 'spaced_repetition_settings.units.seconds';
    return key.tr();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: AppTextStyles.textHeader3.copyWith(
          color: context.brandColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      color: context.brandColors.cardBackground,
      child: Padding(
        padding: AppPad.a16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.textContent2.copyWith(
                color: context.brandColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.textContent3.copyWith(
                color: context.brandColors.textSecondary,
              ),
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: value.round().toString(),
              activeColor: context.brandColors.progressValue,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.textContent3.copyWith(
              color: context.brandColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.textContent3.copyWith(
              color: context.brandColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
