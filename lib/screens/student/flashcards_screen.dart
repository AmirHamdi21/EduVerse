import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../models/flashcard_model.dart';
import '../../widgets/student/flashcards/flashcards_barrel.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with TickerProviderStateMixin {
  late List<Flashcard> cards;
  late List<Course> courses;
  late Course selectedCourse;
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;

  int _currentCardIndex = 0;
  bool _includeWeakTopics = false;

  @override
  void initState() {
    super.initState();
    _initializeCourses();
    _initializeCards();

    _pageController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pageAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.forward();
    });
  }

  void _initializeCourses() {
    courses = [
      Course(id: '1', name: 'Data Structures', icon: '📊'),
      Course(id: '2', name: 'Algorithms', icon: '⚙️'),
      Course(id: '3', name: 'Machine Learning', icon: '🤖'),
      Course(id: '4', name: 'Web Development', icon: '🌐'),
      Course(id: '5', name: 'Database Design', icon: '💾'),
    ];
    selectedCourse = courses[0];
  }

  void _initializeCards() {
    cards = [
      Flashcard(
        id: '1',
        question: 'What is a Linked List?',
        answer:
            'A linear data structure where elements are stored in nodes. Each node contains a data field and a reference (link) to the next node in the sequence.',
        topic: 'Data Structures',
      ),
      Flashcard(
        id: '2',
        question: 'What is the time complexity of binary search?',
        answer:
            'The time complexity of binary search is O(log n), where n is the number of elements in the sorted array. This is achieved by repeatedly dividing the search interval in half.',
        topic: 'Data Structures',
      ),
      Flashcard(
        id: '3',
        question: 'Explain the difference between stack and queue.',
        answer:
            'A stack follows LIFO (Last In First Out) principle where the last element added is the first to be removed. A queue follows FIFO (First In First Out) principle where the first element added is the first to be removed.',
        topic: 'Data Structures',
      ),
      Flashcard(
        id: '4',
        question: 'What is a hash table?',
        answer:
            'A hash table is a data structure that implements an associative array - a structure that maps keys to values. It uses a hash function to compute an index into an array of buckets or slots, from which the desired value can be found.',
        topic: 'Data Structures',
      ),
      Flashcard(
        id: '5',
        question: 'What is a tree in data structures?',
        answer:
            'A tree is a hierarchical data structure consisting of nodes connected by edges. It has a root node and child nodes, with no cycles. Common types include binary trees, binary search trees, and AVL trees.',
        topic: 'Data Structures',
      ),
    ];
  }

  void _nextCard() {
    if (_currentCardIndex < cards.length - 1) {
      _pageController.reset();
      setState(() {
        _currentCardIndex++;
      });
      _pageController.forward();
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      _pageController.reset();
      setState(() {
        _currentCardIndex--;
      });
      _pageController.forward();
    }
  }

  void _shuffleDeck() {
    setState(() {
      cards.shuffle();
      _currentCardIndex = 0;
    });
    _pageController.reset();
    _pageController.forward();
  }

  void _markAsKnown() {
    cards[_currentCardIndex].isMarkedAsKnown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card marked as known!'),
        duration: Duration(milliseconds: 1500),
      ),
    );
    _nextCard();
  }

  void _reviewLater() {
    cards[_currentCardIndex].isMarkedForReview = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card marked for review!'),
        duration: Duration(milliseconds: 1500),
      ),
    );
    _nextCard();
  }

  void _generateNewSet() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating new flashcards for ${selectedCourse.name}...',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _changeCourse(Course newCourse) {
    setState(() {
      selectedCourse = newCourse;
      _currentCardIndex = 0;
    });
    _pageController.reset();
    _pageController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFAFAFA);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FlashcardsHeader(
                      isDark: isDark,
                      onBackPressed: () => Navigator.pop(context),
                      onRegeneratePressed: _generateNewSet,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                // Course selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CourseSelector(
                      courses: courses,
                      selectedCourse: selectedCourse,
                      onCourseChanged: _changeCourse,
                      isDark: isDark,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 32)),
                // Flashcard
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FadeTransition(
                      opacity: _pageAnimation,
                      child: FlipCard(
                        card: cards[_currentCardIndex],
                        isDark: isDark,
                        onFlip: () {},
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 20)),
                // Progress indicator
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CardProgressIndicator(
                      currentIndex: _currentCardIndex,
                      totalCards: cards.length,
                      isDark: isDark,
                      onPrevious: _previousCard,
                      onNext: _nextCard,
                      canGoPrevious: _currentCardIndex > 0,
                      canGoNext: _currentCardIndex < cards.length - 1,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                // Action buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CardActionButtons(
                      isDark: isDark,
                      onMarkAsKnown: _markAsKnown,
                      onReviewLater: _reviewLater,
                      onShuffleDeck: _shuffleDeck,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 32)),
                // Generate new set panel
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GenerateNewSetPanel(
                      isDark: isDark,
                      includeWeakTopics: _includeWeakTopics,
                      onIncludeWeakTopicsChanged: (value) {
                        setState(() {
                          _includeWeakTopics = value;
                        });
                      },
                      onGeneratePressed: _generateNewSet,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }
}
