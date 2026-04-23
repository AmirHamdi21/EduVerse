import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:go_router/go_router.dart';

class InstructorQuizEditScreen extends StatefulWidget {
  final QuizModel quiz;
  const InstructorQuizEditScreen({super.key, required this.quiz});
  @override
  State<InstructorQuizEditScreen> createState() => _EditState();
}

class _EditState extends State<InstructorQuizEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _instructions;
  late final TextEditingController _timeLimit;
  late final TextEditingController _maxAttempts;
  late final TextEditingController _passingScore;
  late final TextEditingController _weight;
  late QuizTypeEnum _quizType;
  late bool _randomize;
  late bool _showCorrect;
  late ShowAnswersAfterEnum _showAfter;
  DateTime? _availFrom;
  DateTime? _availUntil;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _title.dispose(); _desc.dispose(); _instructions.dispose();
    _timeLimit.dispose(); _maxAttempts.dispose(); _passingScore.dispose(); _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (_, ts) {
      final dk = ts.isDark;
      return Scaffold(
        backgroundColor: InstructorColors.background(dk),
        body: Stack(children: [
          Container(height: 180, decoration: BoxDecoration(gradient: dk ? InstructorColors.darkHeaderGradient : InstructorColors.headerGradient)),
          SafeArea(child: Column(children: [
            _header(dk),
            Expanded(child: _form(dk)),
            _bottom(dk),
          ])),
        ]),
      );
    });
  }

  Widget _header(bool dk) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    child: Row(children: [
      Container(decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
        child: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Edit Quiz', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(widget.quiz.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
      ])),
    ]),
  );

  Widget _form(bool dk) => Form(key: _formKey, child: ListView(
    padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(), children: [
      _section(dk, 'Basic Info', [
        _field(dk, 'Title *', _title, v: (s) => s == null || s.isEmpty ? 'Required' : null),
        const SizedBox(height: 14),
        _field(dk, 'Description', _desc, lines: 3),
        const SizedBox(height: 14),
        _field(dk, 'Instructions', _instructions, lines: 2),
      ]),
      const SizedBox(height: 16),
      _section(dk, 'Settings', [
        _dropdown(dk, 'Quiz Type', _quizType.name, ['practice','graded','survey'], (v) => setState(() => _quizType = QuizTypeEnum.fromJson(v))),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _field(dk, 'Time Limit (min)', _timeLimit, isNum: true)),
          const SizedBox(width: 12),
          Expanded(child: _field(dk, 'Max Attempts', _maxAttempts, isNum: true)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _field(dk, 'Passing Score (%)', _passingScore, isNum: true)),
          const SizedBox(width: 12),
          Expanded(child: _field(dk, 'Weight', _weight, isNum: true)),
        ]),
        const SizedBox(height: 14),
        _toggle(dk, 'Randomize Questions', _randomize, (v) => setState(() => _randomize = v)),
        const SizedBox(height: 10),
        _toggle(dk, 'Show Correct Answers', _showCorrect, (v) => setState(() => _showCorrect = v)),
        if (_showCorrect) ...[const SizedBox(height: 10),
          _dropdown(dk, 'Show After', _showAfter.toJson(), ['never','submission','grading','due_date'], (v) => setState(() => _showAfter = ShowAnswersAfterEnum.fromJson(v)))],
      ]),
      const SizedBox(height: 16),
      _section(dk, 'Availability', [
        _dateField(dk, 'Available From', _availFrom, (d) => setState(() => _availFrom = d)),
        const SizedBox(height: 14),
        _dateField(dk, 'Available Until', _availUntil, (d) => setState(() => _availUntil = d)),
      ]),
      const SizedBox(height: 80),
    ],
  ));

  Widget _bottom(bool dk) => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: BoxDecoration(color: InstructorColors.cardColor(dk), border: Border(top: BorderSide(color: InstructorColors.borderColor(dk).withValues(alpha: 0.5)))),
    child: ElevatedButton(
      onPressed: _saving ? null : _save,
      style: ElevatedButton.styleFrom(backgroundColor: InstructorColors.primary, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14), minimumSize: const Size(double.infinity, 48)),
      child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700))),
  );

  Widget _section(bool dk, String t, List<Widget> ch) => Container(
    padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: InstructorColors.cardColor(dk), borderRadius: BorderRadius.circular(18), border: Border.all(color: InstructorColors.borderColor(dk).withValues(alpha: 0.5))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: InstructorColors.textPrimaryColor(dk))), const SizedBox(height: 16), ...ch]),
  );

  Widget _field(bool dk, String l, TextEditingController c, {int lines = 1, bool isNum = false, String? Function(String?)? v}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: InstructorColors.textSecondaryColor(dk))), const SizedBox(height: 6),
    TextFormField(controller: c, maxLines: lines, validator: v, keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: InstructorColors.textPrimaryColor(dk), fontSize: 14),
      decoration: InputDecoration(filled: true, fillColor: dk ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: InstructorColors.borderColor(dk))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: InstructorColors.borderColor(dk).withValues(alpha: 0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: InstructorColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
  ]);

  Widget _toggle(bool dk, String l, bool val, ValueChanged<bool> cb) => Row(children: [
    Expanded(child: Text(l, style: TextStyle(fontSize: 14, color: InstructorColors.textPrimaryColor(dk)))),
    Switch.adaptive(value: val, onChanged: cb, activeColor: InstructorColors.primary),
  ]);

  Widget _dropdown(bool dk, String l, String val, List<String> items, ValueChanged<String> cb) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: InstructorColors.textSecondaryColor(dk))), const SizedBox(height: 6),
    Container(padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: dk ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: InstructorColors.borderColor(dk).withValues(alpha: 0.5))),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: items.contains(val) ? val : items.first, isExpanded: true, dropdownColor: InstructorColors.cardColor(dk),
        style: TextStyle(color: InstructorColors.textPrimaryColor(dk), fontSize: 14),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e[0].toUpperCase() + e.substring(1).replaceAll('_', ' ')))).toList(),
        onChanged: (v) { if (v != null) cb(v); }))),
  ]);

  Widget _dateField(bool dk, String l, DateTime? d, ValueChanged<DateTime?> cb) => GestureDetector(
    onTap: () async {
      final dt = await showDatePicker(context: context, initialDate: d ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
      if (dt != null && mounted) { final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(d ?? DateTime.now())); cb(t != null ? DateTime(dt.year, dt.month, dt.day, t.hour, t.minute) : dt); }
    },
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: InstructorColors.textSecondaryColor(dk))), const SizedBox(height: 6),
      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: dk ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: InstructorColors.borderColor(dk).withValues(alpha: 0.5))),
        child: Row(children: [Icon(Icons.calendar_today_outlined, size: 16, color: InstructorColors.textTertiaryColor(dk)), const SizedBox(width: 10),
          Expanded(child: Text(d != null ? '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}' : 'Select date & time',
            style: TextStyle(fontSize: 14, color: d != null ? InstructorColors.textPrimaryColor(dk) : InstructorColors.textTertiaryColor(dk)))),
          if (d != null) GestureDetector(onTap: () => cb(null), child: Icon(Icons.close_rounded, size: 16, color: InstructorColors.textTertiaryColor(dk)))])),
    ]),
  );

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    final data = <String, dynamic>{
      'title': _title.text.trim(),
      'description': _desc.text.trim(),
      'instructions': _instructions.text.trim(),
      'quizType': _quizType.toJson(),
      if (_timeLimit.text.isNotEmpty) 'timeLimit': int.tryParse(_timeLimit.text),
      'maxAttempts': int.tryParse(_maxAttempts.text) ?? 1,
      'passingScore': double.tryParse(_passingScore.text) ?? 50,
      'weight': double.tryParse(_weight.text) ?? 1,
      'randomizeQuestions': _randomize,
      'showCorrectAnswers': _showCorrect,
      'showAnswersAfter': _showAfter.toJson(),
      if (_availFrom != null) 'availableFrom': _availFrom!.toIso8601String(),
      if (_availUntil != null) 'availableUntil': _availUntil!.toIso8601String(),
    };
    final ok = await context.read<QuizManagementCubit>().updateQuiz(widget.quiz.id, data);
    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Quiz updated!'), backgroundColor: InstructorColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
        context.pop();
      }
    }
  }
}
