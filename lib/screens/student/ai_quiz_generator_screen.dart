import 'package:edu_verse/screens/student/quiz_questions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/flashcard_model.dart';
import 'package:edu_verse/models/quiz_models.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import '../../widgets/student/ai_quiz/ai_quiz_barrel.dart';

class AiQuizGeneratorScreen extends StatefulWidget {
  const AiQuizGeneratorScreen({super.key});

  @override
  State<AiQuizGeneratorScreen> createState() => _AiQuizGeneratorScreenState();
}

class _AiQuizGeneratorScreenState extends State<AiQuizGeneratorScreen>
    with TickerProviderStateMixin {
  late List<Course> courses;
  late Course selectedCourse;
  late QuizType selectedQuizType;
  late DifficultyLevel selectedDifficultyLevel;
  late int numberOfQuestions;
  late bool includeWeakTopics;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCourses();
    selectedQuizType = QuizType.mcq;
    selectedDifficultyLevel = DifficultyLevel.easy;
    numberOfQuestions = 10;
    includeWeakTopics = false;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeCourses() {
    courses = [
      Course(id: '1', name: 'Introduction to AI', icon: '🤖'),
      Course(id: '2', name: 'Data Structures', icon: '📊'),
      Course(id: '3', name: 'Algorithms', icon: '⚙️'),
      Course(id: '4', name: 'Machine Learning', icon: '🧠'),
      Course(id: '5', name: 'Web Development', icon: '🌐'),
      Course(id: '6', name: 'Database Design', icon: '💾'),
    ];
    selectedCourse = courses[0];
  }

  void _generateQuiz() {
    final newQuizSession = _createQuizSession();
    if (!mounted) return;

    context.push('/quiz-questions', extra: newQuizSession);
  }

  QuizSession _createQuizSession() {
    final questions = _generateMockQuestions(numberOfQuestions);
    return QuizSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      courseId: selectedCourse.id,
      courseName: selectedCourse.name,
      quizType: selectedQuizType,
      difficultyLevel: selectedDifficultyLevel,
      questions: questions,
      includeWeakTopics: includeWeakTopics,
    );
  }

  List<QuizQuestion> _generateMockQuestions(int count) {
    final questions = <QuizQuestion>[];

    for (int i = 0; i < count; i++) {
      switch (selectedQuizType) {
        case QuizType.mcq:
          questions.add(
            QuizQuestion(
              id: '$i',
              question: 'Question ${i + 1}: What is the correct answer?',
              options: [
                QuizOption(
                  id: '1',
                  text: 'Option A: This is the correct answer',
                  isCorrect: true,
                ),
                QuizOption(
                  id: '2',
                  text: 'Option B: This is incorrect',
                  isCorrect: false,
                ),
                QuizOption(
                  id: '3',
                  text: 'Option C: This is also incorrect',
                  isCorrect: false,
                ),
                QuizOption(
                  id: '4',
                  text: 'Option D: Another incorrect option',
                  isCorrect: false,
                ),
              ],
              type: QuizType.mcq,
              correctAnswer: '1',
            ),
          );
          break;
        case QuizType.trueFalse:
          questions.add(
            QuizQuestion(
              id: '$i',
              question: 'Question ${i + 1}: Is this statement true?',
              options: [
                QuizOption(id: '1', text: 'True', isCorrect: i % 2 == 0),
                QuizOption(id: '2', text: 'False', isCorrect: i % 2 != 0),
              ],
              type: QuizType.trueFalse,
              correctAnswer: i % 2 == 0 ? '1' : '2',
            ),
          );
          break;
        case QuizType.shortAnswer:
          questions.add(
            QuizQuestion(
              id: '$i',
              question: 'Question ${i + 1}: Write your answer here.',
              options: [],
              type: QuizType.shortAnswer,
              correctAnswer: 'sample answer',
            ),
          );
          break;
      }
    }
    return questions;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final bgColor = isDark
            ? const Color(0xFF1A1A2E)
            : const Color(0xFFF5F7FA);

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              // Hero gradient header
              Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Color(0xFF1E293B), Color(0xFF0F172A)]
                        : [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Main content
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // Header section
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: EdgeInsets.all(responsive.p20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back button and AI icon
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      onPressed: () =>
                                          safeBack(context, '/dashboard'),
                                      icon: Icon(
                                        iosBackIcon(context),
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: responsive.p24),
                              // Title
                              Text(
                                AppLocalizations.of(context).aiQuizGenerator,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: responsive.p12),
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).createPersonalizedQuizzes,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content card with rounded top corners
                    SliverToBoxAdapter(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(responsive.p20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Course selector card
                                  _buildModernCourseSelector(
                                    isDark,
                                    responsive,
                                  ),
                                  SizedBox(height: responsive.p20),
                                  // Quiz settings
                                  _buildQuizSettings(isDark, responsive),
                                  SizedBox(height: responsive.p24),
                                  // Generate button
                                  _buildGenerateButton(responsive),
                                  SizedBox(height: responsive.p32),
                                ],
                              ),
                            ),
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
      },
    );
  }

  Widget _buildModernCourseSelector(bool isDark, ResponsiveUtil responsive) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showModernCoursePicker(isDark),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      selectedCourse.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Course',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF667085),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedCourse.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF101828),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.white54 : const Color(0xFF667085),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModernCoursePicker(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choose a Course',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF101828),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  final isSelected = course.id == selectedCourse.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() => selectedCourse = course);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF155DFC).withOpacity(0.1)
                                : (isDark
                                      ? const Color(0xFF2D2D44)
                                      : const Color(0xFFF5F7FA)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF155DFC)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF2B7FFF),
                                            Color(0xFF155DFC),
                                          ],
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : const Color(0xFFE8F1FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    course.icon,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  course.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF101828),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF155DFC),
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSettings(bool isDark, ResponsiveUtil responsive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 20),
          _buildQuizTypeSection(isDark),
          const SizedBox(height: 20),
          _buildDifficultySection(isDark),
          const SizedBox(height: 20),
          _buildQuestionCountSection(isDark),
          const SizedBox(height: 20),
          _buildWeakTopicsSection(isDark),
        ],
      ),
    );
  }

  Widget _buildQuizTypeSection(bool isDark) {
    final types = [
      {'type': QuizType.mcq, 'label': 'MCQ', 'icon': Icons.checklist_outlined},
      {
        'type': QuizType.trueFalse,
        'label': 'True/False',
        'icon': Icons.quiz_outlined,
      },
      {
        'type': QuizType.shortAnswer,
        'label': 'Short',
        'icon': Icons.edit_note_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF667085),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: types.map((item) {
            final isSelected = selectedQuizType == item['type'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(
                    () => selectedQuizType = item['type'] as QuizType,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF5F7FA)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark
                                  ? Colors.white10
                                  : const Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.white54
                                    : const Color(0xFF667085)),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white54
                                      : const Color(0xFF667085)),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultySection(bool isDark) {
    final levels = [
      {
        'level': DifficultyLevel.easy,
        'label': '😊 Easy',
        'color': const Color(0xFF10B981),
      },
      {
        'level': DifficultyLevel.medium,
        'label': '😐 Medium',
        'color': const Color(0xFFF59E0B),
      },
      {
        'level': DifficultyLevel.hard,
        'label': '😤 Hard',
        'color': const Color(0xFFEF4444),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty Level',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF667085),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: levels.map((item) {
            final isSelected = selectedDifficultyLevel == item['level'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(
                    () => selectedDifficultyLevel =
                        item['level'] as DifficultyLevel,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (item['color'] as Color).withOpacity(0.15)
                          : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF5F7FA)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? (item['color'] as Color)
                            : (isDark
                                  ? Colors.white10
                                  : const Color(0xFFE5E7EB)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? (item['color'] as Color)
                            : (isDark
                                  ? Colors.white54
                                  : const Color(0xFF667085)),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuestionCountSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Number of Questions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF667085),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$numberOfQuestions',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF155DFC),
            inactiveTrackColor: const Color(0xFF155DFC).withOpacity(0.2),
            thumbColor: const Color(0xFF155DFC),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: numberOfQuestions.toDouble(),
            min: 5,
            max: 50,
            divisions: 9,
            onChanged: (value) =>
                setState(() => numberOfQuestions = value.toInt()),
          ),
        ),
      ],
    );
  }

  Widget _buildWeakTopicsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF155DFC).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF155DFC).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => includeWeakTopics = !includeWeakTopics),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: includeWeakTopics
                    ? const Color(0xFF155DFC)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF155DFC), width: 2),
              ),
              child: includeWeakTopics
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus on Weak Topics',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Include more questions from your weak areas',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : const Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(ResponsiveUtil responsive) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF155DFC).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _generateQuiz,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).generateQuiz,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
