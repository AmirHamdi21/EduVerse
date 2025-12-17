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
import '../../widgets/student/ai_quiz/ai_quiz_barrel.dart';

class AiQuizGeneratorScreen extends StatefulWidget {
  const AiQuizGeneratorScreen({super.key});

  @override
  State<AiQuizGeneratorScreen> createState() => _AiQuizGeneratorScreenState();
}

class _AiQuizGeneratorScreenState extends State<AiQuizGeneratorScreen> {
  late List<Course> courses;
  late Course selectedCourse;
  late QuizType selectedQuizType;
  late DifficultyLevel selectedDifficultyLevel;
  late int numberOfQuestions;
  late bool includeWeakTopics;

  @override
  void initState() {
    super.initState();
    _initializeCourses();
    selectedQuizType = QuizType.mcq;
    selectedDifficultyLevel = DifficultyLevel.easy;
    numberOfQuestions = 10;
    includeWeakTopics = false;
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
            : const Color(0xFFFAFAFA);
        final cardColor = isDark ? const Color(0xFF252D48) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF101828);
        final secondaryTextColor = isDark
            ? const Color(0xFFB0B3C1)
            : const Color(0xFF6A7282);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: QuizGeneratorHeader(
                    isDark: isDark,
                    onBackPressed: () => Navigator.pop(context),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: responsive.p24)),
                // Main Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Selector
                        CourseSelector(
                          courses: courses,
                          selectedCourse: selectedCourse,
                          isDark: isDark,
                          onCourseSelected: (course) {
                            setState(() {
                              selectedCourse = course;
                            });
                          },
                        ),
                        SizedBox(height: responsive.p24),
                        // Quiz Settings Card
                        QuizSettingsCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          selectedQuizType: selectedQuizType,
                          onQuizTypeChanged: (type) {
                            setState(() {
                              selectedQuizType = type;
                            });
                          },
                          selectedDifficultyLevel: selectedDifficultyLevel,
                          onDifficultyLevelChanged: (level) {
                            setState(() {
                              selectedDifficultyLevel = level;
                            });
                          },
                          numberOfQuestions: numberOfQuestions,
                          onNumberOfQuestionsChanged: (value) {
                            setState(() {
                              numberOfQuestions = value.toInt();
                            });
                          },
                          includeWeakTopics: includeWeakTopics,
                          onIncludeWeakTopicsChanged: (value) {
                            setState(() {
                              includeWeakTopics = value;
                            });
                          },
                        ),
                        SizedBox(height: responsive.p24),
                        // Generate Button
                        GenerateQuizButton(
                          isDark: isDark,
                          onPressed: _generateQuiz,
                        ),
                        SizedBox(height: responsive.p32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
