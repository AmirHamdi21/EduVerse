import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/bloc/ta/ta_courses_cubit.dart';
import 'package:edu_verse/bloc/ta/ta_courses_state.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/services/api/quiz_api_service.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'package:go_router/go_router.dart';

class TAQuizEditScreen extends StatefulWidget {
  final QuizModel quiz;
  const TAQuizEditScreen({super.key, required this.quiz});
  @override
  State<TAQuizEditScreen> createState() => _EditState();
}

class _QuestionDraft {
  String? existingId;
  String questionText;
  QuestionTypeEnum type;
  List<Map<String, dynamic>> options;
  dynamic correctAnswer;
  String? explanation;
  double points;
  String? provenance;
  List<Map<String, String>> matchingPairs;
  _QuestionDraft({this.existingId, this.questionText = '', this.type = QuestionTypeEnum.multipleChoice, List<Map<String, dynamic>>? options, this.correctAnswer, this.explanation, this.points = 10.0, this.provenance, List<Map<String, String>>? matchingPairs})
      : options = options ?? [{'text': ''}, {'text': ''}, {'text': ''}, {'text': ''}],
        matchingPairs = matchingPairs ?? [];
}

class _EditState extends State<TAQuizEditScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabCtrl;
  bool _saving = false;
  bool _loadingQuestions = true;

  // Settings
  late final TextEditingController _title, _desc, _instructions, _timeLimit, _maxAttempts, _passingScore, _weight;
  late QuizTypeEnum _quizType;
  late bool _randomize, _showCorrect;
  late ShowAnswersAfterEnum _showAfter;
  DateTime? _availFrom, _availUntil;
  int? _courseId;

  // Questions
  final List<_QuestionDraft> _questions = [];
  final Set<String> _originalQuestionIds = {};
  final List<String> _deletedQuestionIds = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final q = widget.quiz;
    _title = TextEditingController(text: q.title);
    _desc = TextEditingController(text: q.description ?? '');
    _instructions = TextEditingController(text: q.instructions ?? '');
    _timeLimit = TextEditingController(text: q.timeLimitMinutes?.toString() ?? '');
    _maxAttempts = TextEditingController(text: q.maxAttempts.toString());
    _passingScore = TextEditingController(text: q.passingScore.toString());
    _weight = TextEditingController(text: q.weight.toString());
    _quizType = q.quizType;
    _randomize = q.randomizeQuestions;
    _showCorrect = q.showCorrectAnswers;
    _showAfter = q.showAnswersAfter;
    _availFrom = q.availableFrom;
    _availUntil = q.availableUntil;
    _courseId = q.courseId;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final svc = context.read<QuizManagementCubit>();
      final result = await svc.getQuizQuestions(widget.quiz.id);
      if (result != null && result.isNotEmpty) {
        for (final q in result) {
          _originalQuestionIds.add(q.id.toString());
          _questions.add(_QuestionDraft(
            existingId: q.id.toString(),
            questionText: q.questionText,
            type: q.questionType,
            options: List<Map<String, dynamic>>.from(q.options),
            correctAnswer: q.correctAnswer,
            explanation: q.explanation,
            points: q.points,
          ));
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingQuestions = false);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _title.dispose(); _desc.dispose(); _instructions.dispose();
    _timeLimit.dispose(); _maxAttempts.dispose(); _passingScore.dispose(); _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (_, ts) {
      final dk = ts.isDark;
      return Scaffold(
        backgroundColor: TAColors.background(dk),
        body: Stack(children: [
          Container(height: 180, decoration: BoxDecoration(gradient: dk ? TAColors.darkHeaderGradient : TAColors.headerGradient)),
          SafeArea(child: Column(children: [
            // Header
            Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Row(children: [
              _headerBtn(() => context.pop()),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Edit Quiz', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(widget.quiz.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
              ])),
            ])),
            const SizedBox(height: 12),
            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: TabBar(controller: _tabCtrl, indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                labelColor: Colors.white, unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                dividerHeight: 0,
                tabs: [const Tab(text: 'Settings'), Tab(text: 'Questions (${_questions.length})')]),
            ),
            const SizedBox(height: 8),
            // Body
            Expanded(child: TabBarView(controller: _tabCtrl, children: [
              _buildSettingsTab(dk),
              _buildQuestionsTab(dk),
            ])),
            // Save button
            _buildSaveBar(dk),
          ])),
        ]),
      );
    });
  }

  Widget _headerBtn(VoidCallback onTap) => Container(
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
    child: IconButton(onPressed: onTap, icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18)));

  // ── Settings Tab ──────────────────────────────────────────────────────────
  Widget _buildSettingsTab(bool dk) => Form(key: _formKey, child: ListView(
    padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(), children: [
      _sec(dk, 'Basic Info', [
        _f(dk, 'Title *', _title, v: (s) => s == null || s.isEmpty ? 'Required' : null),
        const SizedBox(height: 14), _f(dk, 'Description', _desc, lines: 3),
        const SizedBox(height: 14), _f(dk, 'Instructions', _instructions, lines: 2),
        const SizedBox(height: 14), _buildCourseSelector(dk),
      ]),
      const SizedBox(height: 16),
      _sec(dk, 'Settings', [
        _dd(dk, 'Quiz Type', _quizType.name, ['practice', 'graded'], (v) => setState(() => _quizType = QuizTypeEnum.fromJson(v))),
        const SizedBox(height: 14),
        Row(children: [Expanded(child: _f(dk, 'Time Limit (min)', _timeLimit, num: true)), const SizedBox(width: 12), Expanded(child: _f(dk, 'Max Attempts', _maxAttempts, num: true))]),
        const SizedBox(height: 14),
        Row(children: [Expanded(child: _f(dk, 'Passing Score (%)', _passingScore, num: true)), const SizedBox(width: 12), Expanded(child: _f(dk, 'Weight', _weight, num: true))]),
        const SizedBox(height: 14),
        _tgl(dk, 'Randomize Questions', _randomize, (v) => setState(() => _randomize = v)),
        const SizedBox(height: 10),
        _tgl(dk, 'Show Correct Answers', _showCorrect, (v) => setState(() => _showCorrect = v)),
        if (_showCorrect) ...[const SizedBox(height: 10),
          _dd(dk, 'Show After', _showAfter.toJson(), ['immediate', 'after_due', 'never'], (v) => setState(() => _showAfter = ShowAnswersAfterEnum.fromJson(v)))],
      ]),
      const SizedBox(height: 16),
      _sec(dk, 'Availability', [
        _dr(dk, 'From', _availFrom, (d) => setState(() => _availFrom = d)),
        const SizedBox(height: 14),
        _dr(dk, 'Until', _availUntil, (d) => setState(() => _availUntil = d)),
      ]),
      const SizedBox(height: 80),
    ]));

  // ── Questions Tab ─────────────────────────────────────────────────────────
  Widget _buildQuestionsTab(bool dk) {
    if (_loadingQuestions) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(), children: [
      ..._questions.asMap().entries.map((e) => _buildQuestionCard(dk, e.key, e.value)),
      const SizedBox(height: 12),
      // Add question button
      Material(color: Colors.transparent, child: InkWell(
        onTap: () => setState(() => _questions.add(_QuestionDraft(provenance: 'manual'))),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TAColors.primary.withValues(alpha: 0.4), style: BorderStyle.solid, width: 1.5)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add_rounded, color: TAColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('Add Question', style: TextStyle(color: TAColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
          ]),
        ),
      )),
      const SizedBox(height: 80),
    ]);
  }

  Widget _buildQuestionCard(bool dk, int idx, _QuestionDraft q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dk ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dk ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: TAColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('${idx + 1}', style: TextStyle(color: TAColors.primary, fontWeight: FontWeight.w700, fontSize: 12)))),
          const SizedBox(width: 10),
          Expanded(child: Text('Question ${idx + 1}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: dk ? Colors.white : const Color(0xFF1E293B)))),
          if (q.provenance == 'ai') Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: const Text('AI', style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 10, fontWeight: FontWeight.w700))),
          const SizedBox(width: 4),
          IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)), onPressed: () => _removeQuestion(idx)),
        ]),
        const SizedBox(height: 12),
        // Type dropdown
        _dd(dk, 'Type', q.type.toJson(), ['mcq', 'true_false', 'short_answer', 'essay'], (v) => setState(() => q.type = QuestionTypeEnum.fromJson(v))),
        const SizedBox(height: 12),
        // Question text
        TextFormField(initialValue: q.questionText, onChanged: (v) => q.questionText = v,
          maxLines: 2, style: TextStyle(color: dk ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
          decoration: _inputDeco(dk, 'Question text *')),
        const SizedBox(height: 12),
        // Points
        Row(children: [
          Expanded(child: TextFormField(initialValue: q.points.toString(), keyboardType: TextInputType.number,
            onChanged: (v) => q.points = double.tryParse(v) ?? 10, style: TextStyle(color: dk ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
            decoration: _inputDeco(dk, 'Points'))),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(initialValue: q.explanation ?? '', onChanged: (v) => q.explanation = v,
            style: TextStyle(color: dk ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
            decoration: _inputDeco(dk, 'Explanation'))),
        ]),
        // MCQ/TF options
        if (q.type == QuestionTypeEnum.multipleChoice || q.type == QuestionTypeEnum.trueFalse) ...[
          const SizedBox(height: 12),
          ...q.options.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Radio<int>(value: e.key, groupValue: int.tryParse(q.correctAnswer?.toString() ?? '0') ?? 0,
                onChanged: (v) => setState(() => q.correctAnswer = v.toString()), activeColor: TAColors.primary),
              Expanded(child: TextFormField(initialValue: e.value['text']?.toString() ?? '',
                onChanged: (v) => q.options[e.key] = {'text': v},
                style: TextStyle(color: dk ? Colors.white : const Color(0xFF1E293B), fontSize: 13),
                decoration: _inputDeco(dk, 'Option ${String.fromCharCode(65 + e.key)}'))),
              if (q.options.length > 2 && q.type == QuestionTypeEnum.multipleChoice)
                IconButton(icon: Icon(Icons.close, size: 16, color: dk ? Colors.white38 : Colors.black26),
                  onPressed: () => setState(() => q.options.removeAt(e.key))),
            ]),
          )),
          if (q.type == QuestionTypeEnum.multipleChoice)
            TextButton.icon(onPressed: () => setState(() => q.options.add({'text': ''})),
              icon: const Icon(Icons.add, size: 16), label: const Text('Add Option', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: TAColors.primary)),
        ],
        // Short answer correct answer
        if (q.type == QuestionTypeEnum.shortAnswer) ...[
          const SizedBox(height: 12),
          TextFormField(initialValue: q.correctAnswer?.toString() ?? '', onChanged: (v) => q.correctAnswer = v,
            style: TextStyle(color: dk ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
            decoration: _inputDeco(dk, 'Correct Answer')),
        ],
        // Matching pairs editor
        if (q.type == QuestionTypeEnum.matching) ...[
          const SizedBox(height: 12),
          Text('Matching Pairs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: dk ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
          const SizedBox(height: 8),
          ...q.matchingPairs.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: TextFormField(initialValue: e.value['left'] ?? '', onChanged: (v) => setState(() => q.matchingPairs[e.key] = {'left': v, 'right': q.matchingPairs[e.key]['right'] ?? ''}),
                style: TextStyle(color: dk ? Colors.white : const Color(0xFF1E293B), fontSize: 13), decoration: _inputDeco(dk, 'Left ${e.key + 1}'))),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 16, color: dk ? Colors.white38 : Colors.black26),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(initialValue: e.value['right'] ?? '', onChanged: (v) => setState(() => q.matchingPairs[e.key] = {'left': q.matchingPairs[e.key]['left'] ?? '', 'right': v}),
                style: TextStyle(color: dk ? Colors.white : const Color(0xFF1E293B), fontSize: 13), decoration: _inputDeco(dk, 'Right ${e.key + 1}'))),
              IconButton(icon: Icon(Icons.close, size: 16, color: dk ? Colors.white38 : Colors.black26),
                onPressed: () => setState(() => q.matchingPairs.removeAt(e.key))),
            ]),
          )),
          TextButton.icon(onPressed: () => setState(() => q.matchingPairs.add({'left': '', 'right': ''})),
            icon: const Icon(Icons.add, size: 16), label: const Text('Add Pair', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: TAColors.primary)),
        ],
      ]),
    );
  }

  void _removeQuestion(int idx) {
    final q = _questions[idx];
    if (q.existingId != null && _originalQuestionIds.contains(q.existingId)) {
      _deletedQuestionIds.add(q.existingId!);
    }
    setState(() => _questions.removeAt(idx));
  }

  // ── Save bar ──────────────────────────────────────────────────────────────
  Widget _buildSaveBar(bool dk) => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: BoxDecoration(color: dk ? const Color(0xFF1E293B) : Colors.white,
      border: Border(top: BorderSide(color: dk ? Colors.white12 : const Color(0xFFE2E8F0)))),
    child: ElevatedButton(onPressed: _saving ? null : _save,
      style: ElevatedButton.styleFrom(backgroundColor: TAColors.primary, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14), minimumSize: const Size(double.infinity, 48)),
      child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700))),
  );

  // ── Save logic (mirrors web QuizEdit.tsx handleSave) ──────────────────────
  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) {
      _tabCtrl.animateTo(0);
      return;
    }
    setState(() => _saving = true);
    final cubit = context.read<QuizManagementCubit>();

    // 1) Update quiz settings
    final data = <String, dynamic>{
      'title': _title.text.trim(), 'description': _desc.text.trim(), 'instructions': _instructions.text.trim(),
      'quizType': _quizType.toJson(),
      if (_courseId != null) 'courseId': _courseId,
      if (_timeLimit.text.isNotEmpty) 'timeLimitMinutes': int.tryParse(_timeLimit.text) ?? 0,
      'maxAttempts': int.tryParse(_maxAttempts.text) ?? 1,
      'passingScore': (double.tryParse(_passingScore.text) ?? 50).toString(),
      'weight': (double.tryParse(_weight.text) ?? 1).toString(),
      'randomizeQuestions': _randomize ? 1 : 0, 'showCorrectAnswers': _showCorrect ? 1 : 0,
      'showAnswersAfter': _showAfter.toJson(),
      if (_availFrom != null) 'availableFrom': _availFrom!.toIso8601String(),
      if (_availUntil != null) 'availableUntil': _availUntil!.toIso8601String(),
    };
    final ok = await cubit.updateQuiz(widget.quiz.id, data);
    if (!ok) { if (mounted) setState(() => _saving = false); return; }

    // 2) Delete removed questions
    for (final qId in _deletedQuestionIds) {
      await cubit.deleteQuestion(widget.quiz.id, int.tryParse(qId) ?? 0);
    }

    // 3) Update or create questions
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final payload = <String, dynamic>{
        'questionText': q.questionText, 'questionType': q.type.toJson(),
        'points': q.points.toString(), 'orderIndex': i,
        if (q.explanation != null && q.explanation!.isNotEmpty) 'explanation': q.explanation,
      };
      if (q.type == QuestionTypeEnum.multipleChoice) {
        payload['options'] = q.options.map((o) => o['text']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
        payload['correctAnswer'] = q.correctAnswer?.toString() ?? '0';
      } else if (q.type == QuestionTypeEnum.trueFalse) {
        payload['options'] = ['True', 'False'];
        payload['correctAnswer'] = q.correctAnswer?.toString() ?? '0';
      } else if (q.type == QuestionTypeEnum.shortAnswer) {
        payload['correctAnswer'] = q.correctAnswer?.toString() ?? '';
      } else if (q.type == QuestionTypeEnum.matching) {
        payload['matchingPairs'] = q.matchingPairs;
        payload['correctAnswer'] = null;
      }

      if (q.existingId != null && _originalQuestionIds.contains(q.existingId)) {
        await cubit.updateQuestion(widget.quiz.id, int.tryParse(q.existingId!) ?? 0, payload);
      } else {
        await cubit.addQuestion(widget.quiz.id, payload);
      }
    }

    if (mounted) {
      setState(() => _saving = false);
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Quiz updated!'),
        backgroundColor: TAColors.success, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
      context.pop();
    }
  }

  // ── Course Selector ────────────────────────────────────────────────────────
  Widget _buildCourseSelector(bool dk) {
    final cubit = context.read<TACoursesCubit>();
    final coursesStatus = cubit.state.coursesStatus;
    if (coursesStatus is! TASubTabLoaded<List<TeachingCourseModel>>) {
      return const SizedBox.shrink();
    }
    final courses = coursesStatus.data;
    final items = courses.map((c) => DropdownMenuItem<int>(
      value: c.courseId,
      child: Text(c.course.name, overflow: TextOverflow.ellipsis),
    )).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Course', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: dk ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
      const SizedBox(height: 6),
      Container(padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: dk ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dk ? Colors.white12 : const Color(0xFFE2E8F0))),
        child: DropdownButtonHideUnderline(child: DropdownButton<int>(
          value: items.any((i) => i.value == _courseId) ? _courseId : null,
          hint: Text('Select course', style: TextStyle(color: dk ? const Color(0xFF64748B) : const Color(0xFF94A3B8), fontSize: 14)),
          isExpanded: true, dropdownColor: dk ? const Color(0xFF1E293B) : Colors.white,
          style: TextStyle(color: dk ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
          items: items,
          onChanged: (v) => setState(() => _courseId = v),
        ))),
    ]);
  }

  // ── Shared widgets ────────────────────────────────────────────────────────
  InputDecoration _inputDeco(bool dk, String label) => InputDecoration(
    labelText: label, labelStyle: TextStyle(fontSize: 13, color: dk ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
    filled: true, fillColor: dk ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: dk ? Colors.white12 : const Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: dk ? Colors.white12 : const Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: TAColors.primary, width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12));

  Widget _sec(bool dk, String t, List<Widget> ch) => Container(padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: dk ? Colors.white.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(18),
      border: Border.all(color: dk ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: dk ? Colors.white : const Color(0xFF1E293B))),
      const SizedBox(height: 16), ...ch]));

  Widget _f(bool dk, String l, TextEditingController c, {int lines = 1, bool num = false, String? Function(String?)? v}) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: dk ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
      const SizedBox(height: 6),
      TextFormField(controller: c, maxLines: lines, validator: v, keyboardType: num ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: dk ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
        decoration: _inputDeco(dk, l))]);

  Widget _tgl(bool dk, String l, bool val, ValueChanged<bool> cb) => Row(children: [
    Expanded(child: Text(l, style: TextStyle(fontSize: 14, color: dk ? Colors.white : const Color(0xFF1E293B)))),
    Switch.adaptive(value: val, onChanged: cb, activeColor: TAColors.primary)]);

  Widget _dd(bool dk, String l, String val, List<String> items, ValueChanged<String> cb) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: dk ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
      const SizedBox(height: 6),
      Container(padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: dk ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dk ? Colors.white12 : const Color(0xFFE2E8F0))),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: items.contains(val) ? val : items.first, isExpanded: true,
          dropdownColor: dk ? const Color(0xFF1E293B) : Colors.white,
          style: TextStyle(color: dk ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e[0].toUpperCase() + e.substring(1).replaceAll('_', ' ')))).toList(),
          onChanged: (v) { if (v != null) cb(v); })))]);

  Widget _dr(bool dk, String l, DateTime? d, ValueChanged<DateTime?> cb) => GestureDetector(
    onTap: () async {
      final dt = await showDatePicker(context: context, initialDate: d ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
      if (dt != null && mounted) {
        final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(d ?? DateTime.now()));
        cb(t != null ? DateTime(dt.year, dt.month, dt.day, t.hour, t.minute) : dt);
      }
    },
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: dk ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
      const SizedBox(height: 6),
      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: dk ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dk ? Colors.white12 : const Color(0xFFE2E8F0))),
        child: Row(children: [
          Icon(Icons.calendar_today_outlined, size: 16, color: dk ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Expanded(child: Text(d != null ? '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}' : 'Select date',
            style: TextStyle(fontSize: 14, color: d != null ? (dk ? Colors.white : const Color(0xFF1E293B)) : const Color(0xFF94A3B8)))),
          if (d != null) GestureDetector(onTap: () => cb(null), child: Icon(Icons.close_rounded, size: 16, color: dk ? Colors.white38 : Colors.black26)),
        ]))]),
  );
}

