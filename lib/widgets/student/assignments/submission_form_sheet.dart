import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/assignments/assignment_bloc.dart';
import '../../../../bloc/assignments/assignment_event.dart';
import '../../../../bloc/assignments/assignment_state.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../models/assignments/assignment_model.dart';
import '../../../../models/core/enums/assignment_enums.dart' as api;

enum _SubmissionTab { text, link, file }

class SubmissionFormSheet extends StatefulWidget {
  final AssignmentModel assignment;
  final bool isDark;

  const SubmissionFormSheet({
    super.key,
    required this.assignment,
    required this.isDark,
  });

  static Future<void> show(
    BuildContext context, {
    required AssignmentModel assignment,
    required bool isDark,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SubmissionFormSheet(assignment: assignment, isDark: isDark),
      ),
    );
  }

  @override
  State<SubmissionFormSheet> createState() => _SubmissionFormSheetState();
}

class _SubmissionFormSheetState extends State<SubmissionFormSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late final List<_SubmissionTab> _tabs;
  late final TabController _tabController;

  File? _localFile;
  String? _validationError;
  bool _submitAttempted = false;

  @override
  void initState() {
    super.initState();
    _tabs = _resolveTabs(widget.assignment.submissionType);
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _textController.dispose();
    _linkController.dispose();
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final lateBlocked = _isLateBlocked();
    final lateWarning = _isLateAllowedWithWarning();
    final submissionState = context.watch<AssignmentBloc>().state;

    return BlocListener<AssignmentBloc, AssignmentState>(
      listenWhen: (previous, current) {
        return previous.isSubmitting != current.isSubmitting ||
            previous.submitError != current.submitError;
      },
      listener: (context, state) {
        if (!_submitAttempted || state.isSubmitting) {
          return;
        }

        if (state.submitError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.submitError!),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
          _submitAttempted = false;
          return;
        }

        _submitAttempted = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submission sent successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.of(context).pop();
      },
      child: PopScope(
        canPop: !submissionState.isSubmitting,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(responsive.radius24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(top: responsive.p12),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      responsive.p16,
                      responsive.p12,
                      responsive.p16,
                      responsive.p16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroHeader(context, responsive),
                        if (lateBlocked) ...[
                          SizedBox(height: responsive.p14),
                          _buildLateBlockedBanner(context),
                        ],
                        if (!lateBlocked && lateWarning) ...[
                          SizedBox(height: responsive.p14),
                          _buildLateWarningBanner(context),
                        ],
                        SizedBox(height: responsive.p16),
                        _buildSummaryStrip(context, responsive),
                        SizedBox(height: responsive.p16),
                        if (_tabs.length > 1) ...[
                          _buildModeSelector(context, responsive),
                          SizedBox(height: responsive.p16),
                        ],
                        _buildCurrentTabSurface(context, responsive),
                      ],
                    ),
                  ),
                ),
                _buildBottomActionBar(
                  context,
                  responsive,
                  submissionState,
                  lateBlocked,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, ResponsiveUtil responsive) {
    final gradeLabel =
        '${widget.assignment.maxGrade.toStringAsFixed(widget.assignment.maxGrade % 1 == 0 ? 0 : 1)} pts';
    final deadlineLabel = widget.assignment.dueDate.isBefore(DateTime.now())
        ? 'Past due'
        : 'Due soon';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF2563EB),
            Color(0xFF3B82F6),
            Color(0xFF60A5FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(responsive.radius24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(responsive.radius24),
        child: Stack(
          children: [
            Positioned(
              top: -28,
              right: -10,
              child: Container(
                width: 126,
                height: 126,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -48,
              left: -18,
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsive.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in_rounded,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: responsive.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submit Assignment',
                              style: TextStyle(
                                fontSize: responsive.fontSize20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: responsive.p4),
                            Text(
                              'Upload your work, add context, and send a polished submission in one flow.',
                              style: TextStyle(
                                fontSize: responsive.fontSize13,
                                height: 1.35,
                                color: Colors.white.withValues(alpha: 0.86),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: context.watch<AssignmentBloc>().state.isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.p14),
                  Wrap(
                    spacing: responsive.p8,
                    runSpacing: responsive.p8,
                    children: [
                      _buildHeroChip(
                        icon: Icons.menu_book_rounded,
                        label: widget.assignment.courseCode,
                      ),
                      _buildHeroChip(
                        icon: Icons.stars_rounded,
                        label: gradeLabel,
                      ),
                      _buildHeroChip(
                        icon: Icons.schedule_rounded,
                        label: deadlineLabel,
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.p14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 430;
                      final itemWidth = compact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - responsive.p10) / 2;

                      return Wrap(
                        spacing: responsive.p10,
                        runSpacing: responsive.p10,
                        children: [
                          _buildHeroMetricCard(
                            width: itemWidth,
                            icon: Icons.file_present_rounded,
                            title: 'Submission path',
                            value: _tabs.length == 1
                                ? _labelForTab(_tabs.first)
                                : 'Multiple options',
                          ),
                          _buildHeroMetricCard(
                            width: itemWidth,
                            icon: Icons.rule_folder_rounded,
                            title: 'Allowed files',
                            value: (widget.assignment.allowedFileTypes == null ||
                                    widget.assignment.allowedFileTypes!.isEmpty)
                                ? 'Open file policy'
                                : widget.assignment.allowedFileTypes!.join(', '),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStrip(BuildContext context, ResponsiveUtil responsive) {
    final cards = <({IconData icon, String title, String value, Color color})>[
      (
        icon: Icons.category_rounded,
        title: 'Mode',
        value: _labelForTab(_tabs.first),
        color: const Color(0xFF8B5CF6),
      ),
      (
        icon: Icons.file_upload_rounded,
        title: 'Formats',
        value: _tabs.length == 1 ? 'Single mode' : 'Mixed modes',
        color: const Color(0xFF0EA5E9),
      ),
      (
        icon: Icons.info_outline_rounded,
        title: 'Deadline',
        value: _isLateBlocked()
            ? 'Closed'
            : (_isLateAllowedWithWarning() ? 'Penalty applies' : 'On time'),
        color: _isLateBlocked()
            ? const Color(0xFFEF4444)
            : (_isLateAllowedWithWarning()
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF10B981)),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        final spacing = responsive.p10;
        final itemWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - (spacing * 2)) / 3;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((card) {
            return SizedBox(
              width: itemWidth,
              child: Container(
                padding: EdgeInsets.all(responsive.p14),
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFD9E2F0).withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: card.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(card.icon, color: card.color, size: 20),
                    ),
                    SizedBox(width: responsive.p10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.title,
                            style: TextStyle(
                              fontSize: responsive.fontSize12,
                              fontWeight: FontWeight.w700,
                              color: widget.isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: responsive.p2),
                          Text(
                            card.value,
                            style: TextStyle(
                              fontSize: responsive.fontSize13,
                              fontWeight: FontWeight.w800,
                              color: widget.isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }

  Widget _buildModeSelector(BuildContext context, ResponsiveUtil responsive) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E2F0).withValues(alpha: 0.72)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: widget.isDark
            ? Colors.grey.shade300
            : const Color(0xFF475569),
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(
          fontSize: responsive.fontSize13,
          fontWeight: FontWeight.w700,
        ),
        tabs: _tabs
            .map(
              (tab) => Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_iconForTab(tab), size: 16),
                    const SizedBox(width: 6),
                    Text(_labelForTab(tab)),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _buildCurrentTabSurface(BuildContext context, ResponsiveUtil responsive) {
    final body = _tabs.length == 1
        ? _buildTabContent(context, _tabs.first)
        : SizedBox(
            height: 340,
            child: TabBarView(
              controller: _tabController,
              children: _tabs
                  .map((tab) => _buildTabContent(context, tab))
                  .toList(growable: false),
            ),
          );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9E2F0).withValues(alpha: 0.72)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.08 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: body,
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    ResponsiveUtil responsive,
    AssignmentState state,
    bool lateBlocked,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.p16,
        responsive.p10,
        responsive.p16,
        responsive.p16,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD9E2F0).withValues(alpha: 0.7),
          ),
        ),
      ),
      child: Column(
        children: [
          if (_validationError != null)
            Padding(
              padding: EdgeInsets.only(bottom: responsive.p10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _validationError!,
                  style: TextStyle(
                    color: const Color(0xFFEF4444),
                    fontSize: responsive.fontSize12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          if (state.isSubmitting)
            Padding(
              padding: EdgeInsets.only(bottom: responsive.p10),
              child: LinearProgressIndicator(
                value: state.submitProgress > 0
                    ? state.submitProgress.clamp(0, 1)
                    : null,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: widget.isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade200,
                color: const Color(0xFF2563EB),
              ),
            ),
          Container(
            padding: EdgeInsets.all(responsive.p12),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD9E2F0).withValues(alpha: 0.72),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lateBlocked ? 'Submission closed' : 'Ready to submit',
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: responsive.p2),
                      Text(
                        state.isSubmitting
                            ? 'Sending your assignment to the course workspace...'
                            : 'Double-check your text, link, or file before you submit.',
                        style: TextStyle(
                          fontSize: responsive.fontSize12,
                          color: widget.isDark
                              ? Colors.grey.shade400
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: responsive.p12),
                SizedBox(
                  height: responsive.buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: lateBlocked || state.isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade500,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: responsive.p18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: state.isSubmitting
                        ? SizedBox(
                            width: responsive.p16,
                            height: responsive.p16,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      state.isSubmitting ? 'Submitting...' : 'Submit Assignment',
                      style: TextStyle(
                        fontSize: responsive.fontSize14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetricCard({
    required double width,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.74),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForTab(_SubmissionTab tab) {
    switch (tab) {
      case _SubmissionTab.text:
        return Icons.edit_note_rounded;
      case _SubmissionTab.link:
        return Icons.link_rounded;
      case _SubmissionTab.file:
        return Icons.attach_file_rounded;
    }
  }

  Widget _buildTabContent(BuildContext context, _SubmissionTab tab) {
    switch (tab) {
      case _SubmissionTab.text:
        return TextSubmissionTab(
          controller: _textController,
          isDark: widget.isDark,
        );
      case _SubmissionTab.link:
        return LinkSubmissionTab(
          controller: _linkController,
          isDark: widget.isDark,
        );
      case _SubmissionTab.file:
        return FileSubmissionTab(
          isDark: widget.isDark,
          localFile: _localFile,
          onPickLocal: _pickLocalFile,
          onClearSelection: () {
            setState(() {
              _localFile = null;
            });
          },
          notesController: _noteController,
        );
    }
  }

  Widget _buildLateBlockedBanner(BuildContext context) {
    final responsive = context.responsive;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.p16),
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
          SizedBox(width: responsive.p8),
          Expanded(
            child: Text(
              'Submission deadline has passed and late submissions are not accepted.',
              style: TextStyle(
                fontSize: responsive.fontSize12,
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLateWarningBanner(BuildContext context) {
    final responsive = context.responsive;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.p16),
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B)),
          SizedBox(width: responsive.p8),
          Expanded(
            child: Text(
              'Late submission is allowed. ${widget.assignment.latePenaltyPercent.toStringAsFixed(0)}% penalty may apply.',
              style: TextStyle(
                fontSize: responsive.fontSize12,
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_SubmissionTab> _resolveTabs(api.SubmissionType submissionType) {
    switch (submissionType) {
      case api.SubmissionType.text:
        return const <_SubmissionTab>[_SubmissionTab.text];
      case api.SubmissionType.link:
        return const <_SubmissionTab>[_SubmissionTab.link];
      case api.SubmissionType.file:
        return const <_SubmissionTab>[_SubmissionTab.file];
      case api.SubmissionType.multiple:
      case api.SubmissionType.unknown:
        return const <_SubmissionTab>[
          _SubmissionTab.text,
          _SubmissionTab.link,
          _SubmissionTab.file,
        ];
    }
  }

  String _labelForTab(_SubmissionTab tab) {
    switch (tab) {
      case _SubmissionTab.text:
        return 'Text';
      case _SubmissionTab.link:
        return 'Link';
      case _SubmissionTab.file:
        return 'File';
    }
  }

  bool _isLateBlocked() {
    return widget.assignment.dueDate.isBefore(DateTime.now()) &&
        !widget.assignment.lateSubmissionAllowed;
  }

  bool _isLateAllowedWithWarning() {
    return widget.assignment.dueDate.isBefore(DateTime.now()) &&
        widget.assignment.lateSubmissionAllowed;
  }

  Future<void> _pickLocalFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) {
      return;
    }

    final platformFile = result.files.first;
    final path = platformFile.path;
    if (path == null) {
      return;
    }

    final validationError = _validateFile(platformFile);
    if (validationError != null) {
      setState(() {
        _validationError = validationError;
      });
      return;
    }

    setState(() {
      _localFile = File(path);
      _validationError = null;
    });
  }

  String? _validateFile(PlatformFile platformFile) {
    final maxBytes = widget.assignment.maxFileSizeMb * 1024 * 1024;
    if (widget.assignment.maxFileSizeMb > 0 && platformFile.size > maxBytes) {
      return 'File exceeds ${widget.assignment.maxFileSizeMb}MB limit';
    }

    final allowed = widget.assignment.allowedFileTypes;
    if (allowed != null && allowed.isNotEmpty) {
      final extension = (platformFile.extension ?? '').toLowerCase();
      final normalizedAllowed = allowed
          .map((item) => item.replaceAll('.', '').toLowerCase())
          .toSet();
      if (!normalizedAllowed.contains(extension)) {
        return 'File type not allowed. Allowed: ${normalizedAllowed.join(', ')}';
      }
    }

    return null;
  }

  void _submit() {
    final activeTab = _tabs.length == 1
        ? _tabs.first
        : _tabs[_tabController.index];

    setState(() {
      _validationError = null;
    });

    final assignmentId = widget.assignment.assignmentId > 0
        ? widget.assignment.assignmentId
        : int.tryParse(widget.assignment.id) ?? 0;

    if (assignmentId <= 0) {
      setState(() {
        _validationError = 'Invalid assignment id';
      });
      return;
    }

    switch (activeTab) {
      case _SubmissionTab.text:
        final text = _textController.text.trim();
        if (text.isEmpty) {
          setState(() {
            _validationError = 'Please enter your submission text';
          });
          return;
        }
        _submitAttempted = true;
        context.read<AssignmentBloc>().add(
          SubmitTextAssignment(
            assignmentId: assignmentId,
            submissionText: text,
          ),
        );
        return;
      case _SubmissionTab.link:
        final link = _linkController.text.trim();
        final uri = Uri.tryParse(link);
        if (link.isEmpty || uri == null || !uri.hasScheme) {
          setState(() {
            _validationError = 'Please enter a valid URL';
          });
          return;
        }
        _submitAttempted = true;
        context.read<AssignmentBloc>().add(
          SubmitTextAssignment(
            assignmentId: assignmentId,
            submissionLink: link,
          ),
        );
        return;
      case _SubmissionTab.file:
        if (_localFile == null) {
          setState(() {
            _validationError = 'Please choose a file from your device';
          });
          return;
        }

        _submitAttempted = true;

        if (_localFile != null) {
          context.read<AssignmentBloc>().add(
            SubmitFileAssignment(
              assignmentId: assignmentId,
              file: _localFile!,
              submissionText: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
            ),
          );
        }
        return;
    }
  }
}

class TextSubmissionTab extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const TextSubmissionTab({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: Icons.edit_note_rounded,
          title: 'Text Submission',
          subtitle: 'Write a clear answer or paste your completed work.',
          isDark: isDark,
        ),
        SizedBox(height: responsive.p14),
        TextField(
          controller: controller,
          maxLines: 10,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Write your answer here...',
            filled: true,
            fillColor: isDark
                ? Colors.grey.shade800.withValues(alpha: 0.45)
                : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: const Color(0xFFD9E2F0).withValues(alpha: 0.7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: const Color(0xFFD9E2F0).withValues(alpha: 0.7),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class LinkSubmissionTab extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const LinkSubmissionTab({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: Icons.link_rounded,
          title: 'Link Submission',
          subtitle: 'Share a project link, document, or portfolio URL.',
          isDark: isDark,
        ),
        SizedBox(height: responsive.p14),
        TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'https://example.com/your-work',
            prefixIcon: const Icon(Icons.link_rounded),
            filled: true,
            fillColor: isDark
                ? Colors.grey.shade800.withValues(alpha: 0.45)
                : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: const Color(0xFFD9E2F0).withValues(alpha: 0.7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: const Color(0xFFD9E2F0).withValues(alpha: 0.7),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class FileSubmissionTab extends StatelessWidget {
  final bool isDark;
  final File? localFile;
  final VoidCallback onPickLocal;
  final VoidCallback onClearSelection;
  final TextEditingController notesController;

  const FileSubmissionTab({
    super.key,
    required this.isDark,
    required this.localFile,
    required this.onPickLocal,
    required this.onClearSelection,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            icon: Icons.attach_file_rounded,
            title: 'File Submission',
            subtitle: 'Upload the final file and include an optional note.',
            isDark: isDark,
          ),
          SizedBox(height: responsive.p12),
          GestureDetector(
            onTap: onPickLocal,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(responsive.p16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2563EB).withValues(alpha: 0.08),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      color: Color(0xFF2563EB),
                      size: 28,
                    ),
                  ),
                  SizedBox(height: responsive.p12),
                  Text(
                    'Choose File',
                    style: TextStyle(
                      fontSize: responsive.fontSize16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: responsive.p4),
                  Text(
                    'Browse your device and attach the work you want to submit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: responsive.fontSize12,
                      color: isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: responsive.p12),
          if (localFile != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(responsive.p14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey.shade800.withValues(alpha: 0.45)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.attach_file_rounded,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  SizedBox(width: responsive.p10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localFile!.path.split(Platform.pathSeparator).last,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: responsive.fontSize13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: responsive.p2),
                        Text(
                          'Ready to upload',
                          style: TextStyle(
                            fontSize: responsive.fontSize11,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClearSelection,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
          SizedBox(height: responsive.p12),
          TextField(
            controller: notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Optional note for instructor...',
              filled: true,
              fillColor: isDark
                  ? Colors.grey.shade800.withValues(alpha: 0.45)
                  : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: const Color(0xFFD9E2F0).withValues(alpha: 0.7),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: const Color(0xFFD9E2F0).withValues(alpha: 0.7),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
        ),
        SizedBox(width: responsive.p10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: responsive.p2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: responsive.fontSize12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
