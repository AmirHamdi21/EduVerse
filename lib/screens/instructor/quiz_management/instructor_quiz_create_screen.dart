import 'package:edu_verse/bloc/quiz/quiz_management_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:go_router/go_router.dart';

class InstructorQuizCreateScreen extends StatefulWidget {
  const InstructorQuizCreateScreen({super.key});
  @override
  State<InstructorQuizCreateScreen> createState() => _CreateState();
}

class _CreateState extends State<InstructorQuizCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0; // 0 = details, 1 = questions
  bool _saving = false;
  int? _createdQuizId;

  // Detail fields
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _instructions = TextEditingController();
  final _timeLimit = TextEditingController();
  final _maxAttempts = TextEditingController(text: '1');
  final _passingScore = TextEditingController(text: '50');
  final _weight = TextEditingController(text: '1');
  int? _courseId;
  QuizTypeEnum _quizType = QuizTypeEnum.graded;
  bool _randomize = false;
  bool _showCorrect = false;
  ShowAnswersAfterEnum _showAfter = ShowAnswersAfterEnum.never;
  DateTime? _availFrom;
  DateTime? _availUntil;

  // Questions
  final List<_QuestionDraft> _questions = [];

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _instructions.dispose();
    _timeLimit.dispose();
    _maxAttempts.dispose();
    _passingScore.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (_, ts) {
        final dk = ts.isDark;
        return Scaffold(
          backgroundColor: InstructorColors.background(dk),
          body: Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: dk
                      ? InstructorColors.darkHeaderGradient
                      : InstructorColors.headerGradient,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _header(dk),
                    Expanded(
                      child: _step == 0 ? _detailsForm(dk) : _questionsForm(dk),
                    ),
                    _bottomBar(dk),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(bool dk) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Quiz',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                _step == 0 ? 'Step 1: Quiz Details' : 'Step 2: Add Questions',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        // Step indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_step + 1}/2',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _detailsForm(bool dk) => Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _card(dk, 'Basic Info', [
          _field(
            dk,
            'Title *',
            _title,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          _field(dk, 'Description', _desc, lines: 3),
          const SizedBox(height: 14),
          _field(dk, 'Instructions', _instructions, lines: 2),
        ]),
        const SizedBox(height: 16),
        _card(dk, 'Settings', [
          _dropdownRow(
            dk,
            'Quiz Type',
            _quizType.name,
            ['practice', 'graded', 'survey'],
            (v) => setState(() => _quizType = QuizTypeEnum.fromJson(v)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _field(dk, 'Time Limit (min)', _timeLimit, num: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(dk, 'Max Attempts', _maxAttempts, num: true),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _field(
                  dk,
                  'Passing Score (%)',
                  _passingScore,
                  num: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _field(dk, 'Weight', _weight, num: true)),
            ],
          ),
          const SizedBox(height: 14),
          _toggleRow(
            dk,
            'Randomize Questions',
            _randomize,
            (v) => setState(() => _randomize = v),
          ),
          const SizedBox(height: 10),
          _toggleRow(
            dk,
            'Show Correct Answers',
            _showCorrect,
            (v) => setState(() => _showCorrect = v),
          ),
          if (_showCorrect) ...[
            const SizedBox(height: 10),
            _dropdownRow(
              dk,
              'Show Answers After',
              _showAfter.toJson(),
              ['never', 'submission', 'grading', 'due_date'],
              (v) =>
                  setState(() => _showAfter = ShowAnswersAfterEnum.fromJson(v)),
            ),
          ],
        ]),
        const SizedBox(height: 16),
        _card(dk, 'Availability', [
          _dateRow(
            dk,
            'Available From',
            _availFrom,
            (d) => setState(() => _availFrom = d),
          ),
          const SizedBox(height: 14),
          _dateRow(
            dk,
            'Available Until',
            _availUntil,
            (d) => setState(() => _availUntil = d),
          ),
        ]),
        const SizedBox(height: 80),
      ],
    ),
  );

  Widget _questionsForm(bool dk) {
    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline_rounded,
              size: 56,
              color: InstructorColors.textTertiaryColor(dk),
            ),
            const SizedBox(height: 16),
            Text(
              'No questions added yet',
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(dk),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _addQuestion(dk),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Question'),
              style: ElevatedButton.styleFrom(
                backgroundColor: InstructorColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      physics: const BouncingScrollPhysics(),
      itemCount: _questions.length + 1,
      itemBuilder: (_, i) {
        if (i == _questions.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: () => _addQuestion(dk),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Question'),
              style: OutlinedButton.styleFrom(
                foregroundColor: InstructorColors.primary,
                side: const BorderSide(color: InstructorColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          );
        }
        return _questionCard(dk, i);
      },
    );
  }

  Widget _questionCard(bool dk, int idx) {
    final q = _questions[idx];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(dk),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: InstructorColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${idx + 1}',
                  style: const TextStyle(
                    color: InstructorColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  q.questionText.isEmpty ? 'Untitled Question' : q.questionText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: InstructorColors.textPrimaryColor(dk),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: InstructorColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  q.type.toJson(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: InstructorColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: InstructorColors.textTertiaryColor(dk),
                ),
                onPressed: () => _editQuestion(dk, idx),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: InstructorColors.error,
                ),
                onPressed: () => setState(() => _questions.removeAt(idx)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${q.points} points',
            style: TextStyle(
              fontSize: 12,
              color: InstructorColors.textTertiaryColor(dk),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(bool dk) => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: BoxDecoration(
      color: InstructorColors.cardColor(dk),
      border: Border(
        top: BorderSide(
          color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
        ),
      ),
    ),
    child: Row(
      children: [
        if (_step > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _step = 0),
              style: OutlinedButton.styleFrom(
                foregroundColor: InstructorColors.primary,
                side: const BorderSide(color: InstructorColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_step > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saving
                ? null
                : (_step == 0 ? _goToQuestions : _saveQuiz),
            style: ElevatedButton.styleFrom(
              backgroundColor: InstructorColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(_step == 0 ? 'Next: Add Questions' : 'Save Quiz'),
          ),
        ),
      ],
    ),
  );

  // ── Helpers ──

  Widget _card(bool dk, String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: InstructorColors.cardColor(dk),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: InstructorColors.textPrimaryColor(dk),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );

  Widget _field(
    bool dk,
    String label,
    TextEditingController ctrl, {
    int lines = 1,
    bool num = false,
    String? Function(String?)? validator,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: InstructorColors.textSecondaryColor(dk),
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        maxLines: lines,
        validator: validator,
        keyboardType: num ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          color: InstructorColors.textPrimaryColor(dk),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: dk
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: InstructorColors.borderColor(dk)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: InstructorColors.primary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    ],
  );

  Widget _toggleRow(
    bool dk,
    String label,
    bool val,
    ValueChanged<bool> onChanged,
  ) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: InstructorColors.textPrimaryColor(dk),
          ),
        ),
      ),
      Switch.adaptive(
        value: val,
        onChanged: onChanged,
        activeColor: InstructorColors.primary,
      ),
    ],
  );

  Widget _dropdownRow(
    bool dk,
    String label,
    String val,
    List<String> items,
    ValueChanged<String> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: InstructorColors.textSecondaryColor(dk),
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: dk
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(val) ? val : items.first,
            isExpanded: true,
            dropdownColor: InstructorColors.cardColor(dk),
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(dk),
              fontSize: 14,
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e[0].toUpperCase() + e.substring(1).replaceAll('_', ' '),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    ],
  );

  Widget _dateRow(
    bool dk,
    String label,
    DateTime? date,
    ValueChanged<DateTime?> onChanged,
  ) => GestureDetector(
    onTap: () async {
      final d = await showDatePicker(
        context: context,
        initialDate: date ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (d != null && mounted) {
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(date ?? DateTime.now()),
        );
        onChanged(
          t != null ? DateTime(d.year, d.month, d.day, t.hour, t.minute) : d,
        );
      }
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: InstructorColors.textSecondaryColor(dk),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: dk
                ? Colors.white.withValues(alpha: 0.04)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: InstructorColors.textTertiaryColor(dk),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
                      : 'Select date & time',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null
                        ? InstructorColors.textPrimaryColor(dk)
                        : InstructorColors.textTertiaryColor(dk),
                  ),
                ),
              ),
              if (date != null)
                GestureDetector(
                  onTap: () => onChanged(null),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: InstructorColors.textTertiaryColor(dk),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  void _goToQuestions() {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _step = 1);
  }

  void _addQuestion(bool dk) {
    final q = _QuestionDraft();
    _showQuestionEditor(
      dk,
      q,
      (edited) => setState(() => _questions.add(edited)),
    );
  }

  void _editQuestion(bool dk, int idx) {
    _showQuestionEditor(
      dk,
      _questions[idx],
      (edited) => setState(() => _questions[idx] = edited),
    );
  }

  void _showQuestionEditor(
    bool dk,
    _QuestionDraft initial,
    ValueChanged<_QuestionDraft> onSave,
  ) {
    final txtCtrl = TextEditingController(text: initial.questionText);
    final expCtrl = TextEditingController(text: initial.explanation);
    final ptsCtrl = TextEditingController(text: initial.points.toString());
    var type = initial.type;
    var options = List<Map<String, dynamic>>.from(initial.options);
    var correctAnswer = initial.correctAnswer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(dk),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dk ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Question Editor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: InstructorColors.textPrimaryColor(dk),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        onSave(
                          _QuestionDraft(
                            questionText: txtCtrl.text,
                            type: type,
                            options: options,
                            correctAnswer: correctAnswer,
                            explanation: expCtrl.text,
                            points: double.tryParse(ptsCtrl.text) ?? 1,
                          ),
                        );
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: InstructorColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    _dropdownRow(
                      dk,
                      'Question Type',
                      type.toJson(),
                      [
                        'multiple_choice',
                        'true_false',
                        'short_answer',
                        'essay',
                        'matching',
                      ],
                      (v) => setBS(() => type = QuestionTypeEnum.fromJson(v)),
                    ),
                    const SizedBox(height: 14),
                    _field(dk, 'Question Text *', txtCtrl, lines: 3),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _field(dk, 'Points', ptsCtrl, num: true),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _field(dk, 'Explanation', expCtrl)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (type == QuestionTypeEnum.multipleChoice ||
                        type == QuestionTypeEnum.trueFalse) ...[
                      Text(
                        'Options',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: InstructorColors.textSecondaryColor(dk),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (type == QuestionTypeEnum.trueFalse) ...[
                        _optionTile(
                          dk,
                          'True',
                          correctAnswer == 'True',
                          () => setBS(() {
                            correctAnswer = 'True';
                            options = [
                              {'text': 'True'},
                              {'text': 'False'},
                            ];
                          }),
                        ),
                        _optionTile(
                          dk,
                          'False',
                          correctAnswer == 'False',
                          () => setBS(() {
                            correctAnswer = 'False';
                            options = [
                              {'text': 'True'},
                              {'text': 'False'},
                            ];
                          }),
                        ),
                      ] else ...[
                        ...List.generate(options.length, (i) {
                          final oc = TextEditingController(
                            text: options[i]['text']?.toString() ?? '',
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Radio<int>(
                                  value: i,
                                  groupValue: options.indexWhere(
                                    (o) => o['text'] == correctAnswer,
                                  ),
                                  activeColor: InstructorColors.primary,
                                  onChanged: (v) => setBS(
                                    () => correctAnswer = options[v!]['text'],
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: oc,
                                    onChanged: (v) =>
                                        setBS(() => options[i] = {'text': v}),
                                    style: TextStyle(
                                      color: InstructorColors.textPrimaryColor(
                                        dk,
                                      ),
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Option ${i + 1}',
                                      hintStyle: TextStyle(
                                        color:
                                            InstructorColors.textTertiaryColor(
                                              dk,
                                            ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: InstructorColors.borderColor(
                                            dk,
                                          ),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: InstructorColors.error,
                                  ),
                                  onPressed: () =>
                                      setBS(() => options.removeAt(i)),
                                ),
                              ],
                            ),
                          );
                        }),
                        TextButton.icon(
                          onPressed: () =>
                              setBS(() => options.add({'text': ''})),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add Option'),
                          style: TextButton.styleFrom(
                            foregroundColor: InstructorColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionTile(
    bool dk,
    String label,
    bool selected,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? InstructorColors.primary.withValues(alpha: 0.1)
            : InstructorColors.surfaceColor(dk),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? InstructorColors.primary
              : InstructorColors.borderColor(dk).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 20,
            color: selected
                ? InstructorColors.primary
                : InstructorColors.textTertiaryColor(dk),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(dk),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _saveQuiz() async {
    setState(() => _saving = true);
    final cubit = context.read<QuizManagementCubit>();
    final data = <String, dynamic>{
      'title': _title.text.trim(),
      if (_desc.text.trim().isNotEmpty) 'description': _desc.text.trim(),
      if (_instructions.text.trim().isNotEmpty)
        'instructions': _instructions.text.trim(),
      'quizType': _quizType.toJson(),
      if (_timeLimit.text.isNotEmpty)
        'timeLimit': int.tryParse(_timeLimit.text) ?? 0,
      'maxAttempts': int.tryParse(_maxAttempts.text) ?? 1,
      'passingScore': double.tryParse(_passingScore.text) ?? 50,
      'weight': double.tryParse(_weight.text) ?? 1,
      'randomizeQuestions': _randomize,
      'showCorrectAnswers': _showCorrect,
      'showAnswersAfter': _showAfter.toJson(),
      if (_availFrom != null) 'availableFrom': _availFrom!.toIso8601String(),
      if (_availUntil != null) 'availableUntil': _availUntil!.toIso8601String(),
      if (_courseId != null) 'courseId': _courseId,
    };

    final ok = await cubit.createQuiz(data);
    if (!ok || !mounted) {
      setState(() => _saving = false);
      return;
    }

    // Add questions if any
    if (_questions.isNotEmpty) {
      final quizzes = cubit.state;
      if (quizzes is QuizMgmtLoaded && quizzes.quizzes.isNotEmpty) {
        final newQuiz = quizzes.quizzes.first;
        _createdQuizId = newQuiz.id;
        for (var i = 0; i < _questions.length; i++) {
          final q = _questions[i];
          await cubit.addQuestion(newQuiz.id, {
            'questionType': q.type.toJson(),
            'questionText': q.questionText,
            'options': q.options,
            if (q.correctAnswer != null) 'correctAnswer': q.correctAnswer,
            if (q.explanation.isNotEmpty) 'explanation': q.explanation,
            'points': q.points,
            'orderIndex': i,
          });
        }
      }
    }
    if (mounted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quiz created successfully!'),
          backgroundColor: InstructorColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      context.pop();
    }
  }
}

class _QuestionDraft {
  String questionText;
  QuestionTypeEnum type;
  List<Map<String, dynamic>> options;
  dynamic correctAnswer;
  String explanation;
  double points;

  _QuestionDraft({
    this.questionText = '',
    this.type = QuestionTypeEnum.multipleChoice,
    this.options = const [],
    this.correctAnswer,
    this.explanation = '',
    this.points = 1.0,
  });
}
