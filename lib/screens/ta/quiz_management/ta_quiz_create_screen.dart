import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_state.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'package:go_router/go_router.dart';

/// TA Quiz Create — identical capabilities to Instructor, using TAColors.
class TAQuizCreateScreen extends StatefulWidget {
  const TAQuizCreateScreen({super.key});
  @override
  State<TAQuizCreateScreen> createState() => _CreateState();
}

class _CreateState extends State<TAQuizCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;
  bool _saving = false;
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _instructions = TextEditingController();
  final _timeLimit = TextEditingController();
  final _maxAttempts = TextEditingController(text: '1');
  final _passingScore = TextEditingController(text: '50');
  final _weight = TextEditingController(text: '1');
  QuizTypeEnum _quizType = QuizTypeEnum.graded;
  bool _randomize = false;
  bool _showCorrect = false;
  ShowAnswersAfterEnum _showAfter = ShowAnswersAfterEnum.never;
  DateTime? _availFrom;
  DateTime? _availUntil;
  final List<_QDraft> _questions = [];

  @override
  void dispose() { _title.dispose(); _desc.dispose(); _instructions.dispose(); _timeLimit.dispose(); _maxAttempts.dispose(); _passingScore.dispose(); _weight.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (_, ts) {
      final dk = ts.isDark;
      return Scaffold(backgroundColor: TAColors.background(dk), body: Stack(children: [
        Container(height: 200, decoration: BoxDecoration(gradient: dk ? TAColors.darkHeaderGradient : TAColors.headerGradient)),
        SafeArea(child: Column(children: [_header(dk), Expanded(child: _step == 0 ? _detailsForm(dk) : _questionsForm(dk)), _bottomBar(dk)]))]));
    });
  }

  Widget _header(bool dk) => Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), child: Row(children: [
    Container(decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18))),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Create Quiz', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
      Text(_step == 0 ? 'Step 1: Quiz Details' : 'Step 2: Add Questions', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)))])),
    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
      child: Text('${_step + 1}/2', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)))]));

  Widget _detailsForm(bool dk) => Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(), children: [
    _card(dk, 'Basic Info', [_field(dk, 'Title *', _title, v: (s) => s == null || s.isEmpty ? 'Required' : null), const SizedBox(height: 14), _field(dk, 'Description', _desc, lines: 3), const SizedBox(height: 14), _field(dk, 'Instructions', _instructions, lines: 2)]),
    const SizedBox(height: 16),
    _card(dk, 'Settings', [
      _dd(dk, 'Quiz Type', _quizType.name, ['practice','graded','survey'], (v) => setState(() => _quizType = QuizTypeEnum.fromJson(v))),
      const SizedBox(height: 14),
      Row(children: [Expanded(child: _field(dk, 'Time Limit (min)', _timeLimit, num: true)), const SizedBox(width: 12), Expanded(child: _field(dk, 'Max Attempts', _maxAttempts, num: true))]),
      const SizedBox(height: 14),
      Row(children: [Expanded(child: _field(dk, 'Passing Score (%)', _passingScore, num: true)), const SizedBox(width: 12), Expanded(child: _field(dk, 'Weight', _weight, num: true))]),
      const SizedBox(height: 14),
      _toggle(dk, 'Randomize Questions', _randomize, (v) => setState(() => _randomize = v)),
      const SizedBox(height: 10),
      _toggle(dk, 'Show Correct Answers', _showCorrect, (v) => setState(() => _showCorrect = v)),
      if (_showCorrect) ...[const SizedBox(height: 10), _dd(dk, 'Show After', _showAfter.toJson(), ['never','submission','grading','due_date'], (v) => setState(() => _showAfter = ShowAnswersAfterEnum.fromJson(v)))]]),
    const SizedBox(height: 16),
    _card(dk, 'Availability', [_dateR(dk, 'Available From', _availFrom, (d) => setState(() => _availFrom = d)), const SizedBox(height: 14), _dateR(dk, 'Available Until', _availUntil, (d) => setState(() => _availUntil = d))]),
    const SizedBox(height: 80)]));

  Widget _questionsForm(bool dk) {
    if (_questions.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.help_outline_rounded, size: 56, color: TAColors.textTertiaryColor(dk)), const SizedBox(height: 16),
      Text('No questions added', style: TextStyle(color: TAColors.textSecondaryColor(dk), fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: () => _addQ(dk), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Add Question'),
        style: ElevatedButton.styleFrom(backgroundColor: TAColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))]));
    return ListView.builder(padding: const EdgeInsets.fromLTRB(20, 20, 20, 80), physics: const BouncingScrollPhysics(), itemCount: _questions.length + 1,
      itemBuilder: (_, i) { if (i == _questions.length) return Padding(padding: const EdgeInsets.only(top: 12),
        child: OutlinedButton.icon(onPressed: () => _addQ(dk), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Add Question'),
          style: OutlinedButton.styleFrom(foregroundColor: TAColors.primary, side: const BorderSide(color: TAColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14))));
      return _qCard(dk, i); });
  }

  Widget _qCard(bool dk, int idx) { final q = _questions[idx]; return Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: TAColors.cardColor(dk), borderRadius: BorderRadius.circular(16), border: Border.all(color: TAColors.borderColor(dk).withValues(alpha: 0.5))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [
      Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(color: TAColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Text('${idx+1}', style: const TextStyle(color: TAColors.primary, fontWeight: FontWeight.w700, fontSize: 13))),
      const SizedBox(width: 10),
      Expanded(child: Text(q.text.isEmpty ? 'Untitled' : q.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, color: TAColors.textPrimaryColor(dk)))),
      IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 18, color: TAColors.error), onPressed: () => setState(() => _questions.removeAt(idx)))]),
      const SizedBox(height: 4), Text('${q.pts} points • ${q.type.toJson()}', style: TextStyle(fontSize: 12, color: TAColors.textTertiaryColor(dk)))])); }

  Widget _bottomBar(bool dk) => Container(padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: BoxDecoration(color: TAColors.cardColor(dk), border: Border(top: BorderSide(color: TAColors.borderColor(dk).withValues(alpha: 0.5)))),
    child: Row(children: [
      if (_step > 0) Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 0),
        style: OutlinedButton.styleFrom(foregroundColor: TAColors.primary, side: const BorderSide(color: TAColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
        child: const Text('Back'))),
      if (_step > 0) const SizedBox(width: 12),
      Expanded(child: ElevatedButton(onPressed: _saving ? null : (_step == 0 ? _goQ : _save),
        style: ElevatedButton.styleFrom(backgroundColor: TAColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
        child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_step == 0 ? 'Next: Add Questions' : 'Save Quiz')))]));

  Widget _card(bool dk, String t, List<Widget> ch) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: TAColors.cardColor(dk), borderRadius: BorderRadius.circular(18), border: Border.all(color: TAColors.borderColor(dk).withValues(alpha: 0.5))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: TAColors.textPrimaryColor(dk))), const SizedBox(height: 16), ...ch]));

  Widget _field(bool dk, String l, TextEditingController c, {int lines = 1, bool num = false, String? Function(String?)? v}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: TAColors.textSecondaryColor(dk))), const SizedBox(height: 6),
    TextFormField(controller: c, maxLines: lines, validator: v, keyboardType: num ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: TAColors.textPrimaryColor(dk), fontSize: 14),
      decoration: InputDecoration(filled: true, fillColor: dk ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: TAColors.borderColor(dk))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: TAColors.borderColor(dk).withValues(alpha: 0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TAColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)))]);

  Widget _toggle(bool dk, String l, bool val, ValueChanged<bool> cb) => Row(children: [Expanded(child: Text(l, style: TextStyle(fontSize: 14, color: TAColors.textPrimaryColor(dk)))), Switch.adaptive(value: val, onChanged: cb, activeColor: TAColors.primary)]);

  Widget _dd(bool dk, String l, String val, List<String> items, ValueChanged<String> cb) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: TAColors.textSecondaryColor(dk))), const SizedBox(height: 6),
    Container(padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: dk ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: TAColors.borderColor(dk).withValues(alpha: 0.5))),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: items.contains(val) ? val : items.first, isExpanded: true, dropdownColor: TAColors.cardColor(dk),
        style: TextStyle(color: TAColors.textPrimaryColor(dk), fontSize: 14),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e[0].toUpperCase() + e.substring(1).replaceAll('_', ' ')))).toList(), onChanged: (v) { if (v != null) cb(v); })))]);

  Widget _dateR(bool dk, String l, DateTime? d, ValueChanged<DateTime?> cb) => GestureDetector(
    onTap: () async { final dt = await showDatePicker(context: context, initialDate: d ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
      if (dt != null && mounted) { final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(d ?? DateTime.now())); cb(t != null ? DateTime(dt.year, dt.month, dt.day, t.hour, t.minute) : dt); } },
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: TAColors.textSecondaryColor(dk))), const SizedBox(height: 6),
      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: dk ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: TAColors.borderColor(dk).withValues(alpha: 0.5))),
        child: Row(children: [Icon(Icons.calendar_today_outlined, size: 16, color: TAColors.textTertiaryColor(dk)), const SizedBox(width: 10),
          Expanded(child: Text(d != null ? '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}' : 'Select date & time',
            style: TextStyle(fontSize: 14, color: d != null ? TAColors.textPrimaryColor(dk) : TAColors.textTertiaryColor(dk)))),
          if (d != null) GestureDetector(onTap: () => cb(null), child: Icon(Icons.close_rounded, size: 16, color: TAColors.textTertiaryColor(dk)))]))]));

  void _goQ() { if (_formKey.currentState?.validate() != true) return; setState(() => _step = 1); }

  void _addQ(bool dk) {
    final tc = TextEditingController(); final pc = TextEditingController(text: '1');
    var type = QuestionTypeEnum.multipleChoice;
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setBS) => Container(height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(color: TAColors.cardColor(dk), borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: Column(children: [const SizedBox(height: 12), Container(width: 40, height: 4, decoration: BoxDecoration(color: dk ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.all(20), child: Row(children: [Text('Add Question', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: TAColors.textPrimaryColor(dk))), const Spacer(),
            ElevatedButton(onPressed: () { setState(() => _questions.add(_QDraft(text: tc.text, type: type, pts: double.tryParse(pc.text) ?? 1))); Navigator.pop(ctx); },
              style: ElevatedButton.styleFrom(backgroundColor: TAColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Save'))])),
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), children: [
            _dd(dk, 'Type', type.toJson(), ['multiple_choice','true_false','short_answer','essay'], (v) => setBS(() => type = QuestionTypeEnum.fromJson(v))),
            const SizedBox(height: 14), _field(dk, 'Question Text', tc, lines: 3), const SizedBox(height: 14), _field(dk, 'Points', pc, num: true)]))]))));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final cubit = context.read<QuizManagementCubit>();
    final data = <String, dynamic>{'title': _title.text.trim(),
      if (_desc.text.trim().isNotEmpty) 'description': _desc.text.trim(),
      if (_instructions.text.trim().isNotEmpty) 'instructions': _instructions.text.trim(),
      'quizType': _quizType.toJson(),
      if (_timeLimit.text.isNotEmpty) 'timeLimit': int.tryParse(_timeLimit.text),
      'maxAttempts': int.tryParse(_maxAttempts.text) ?? 1, 'passingScore': double.tryParse(_passingScore.text) ?? 50,
      'weight': double.tryParse(_weight.text) ?? 1, 'randomizeQuestions': _randomize, 'showCorrectAnswers': _showCorrect,
      'showAnswersAfter': _showAfter.toJson(),
      if (_availFrom != null) 'availableFrom': _availFrom!.toIso8601String(), if (_availUntil != null) 'availableUntil': _availUntil!.toIso8601String()};
    final ok = await cubit.createQuiz(data);
    if (!ok || !mounted) { setState(() => _saving = false); return; }
    if (_questions.isNotEmpty) {
      final s = cubit.state;
      if (s is QuizMgmtLoaded && s.quizzes.isNotEmpty) {
        final nq = s.quizzes.first;
        for (var i = 0; i < _questions.length; i++) {
          final q = _questions[i];
          await cubit.addQuestion(nq.id, {'questionType': q.type.toJson(), 'questionText': q.text, 'points': q.pts, 'orderIndex': i});
        }
      }
    }
    if (mounted) { HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Quiz created!'), backgroundColor: TAColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
      context.pop(); }
  }
}

class _QDraft { String text; QuestionTypeEnum type; double pts; _QDraft({this.text = '', this.type = QuestionTypeEnum.multipleChoice, this.pts = 1}); }
