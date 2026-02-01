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

    _pageAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut));

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
        final bgColor = isDark
            ? const Color(0xFF1A1A2E)
            : const Color(0xFFF8F9FA);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Stack(
              children: [
                // Main scrollable content
                CustomScrollView(
                  slivers: [
                    // Hero Header with gradient
                    SliverToBoxAdapter(child: _buildHeroHeader(isDark)),
                    const SliverToBoxAdapter(child: SizedBox(height: 46)),
                    // Main content card with overlap
                    SliverToBoxAdapter(
                      child: Transform.translate(
                        offset: const Offset(0, -30),
                        child: Column(
                          children: [
                            // Stats cards row
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: _buildStatsRow(isDark),
                            ),
                            const SizedBox(height: 24),

                            // Course selector
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: _buildModernCourseSelector(isDark),
                            ),
                            const SizedBox(height: 24),

                            // Flashcard
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: FadeTransition(
                                opacity: _pageAnimation,
                                child: FlipCard(
                                  card: cards[_currentCardIndex],
                                  isDark: isDark,
                                  onFlip: () {},
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Progress indicator
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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
                            const SizedBox(height: 24),

                            // Action buttons
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: _buildModernActionButtons(isDark),
                            ),
                            const SizedBox(height: 24),

                            // Generate new set panel
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader(bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF2B7FFF), const Color(0xFF1E5FCC)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and regenerate button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _shuffleDeck,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shuffle,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Shuffle',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Arimo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Title and icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.style_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Flashcards',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Arimo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review key concepts smartly',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    final knownCount = cards.where((c) => c.isMarkedAsKnown).length;
    final reviewCount = cards.where((c) => c.isMarkedForReview).length;
    final progress = cards.isNotEmpty ? (knownCount / cards.length) : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            isDark,
            'Progress',
            '${(progress * 100).toInt()}%',
            Icons.trending_up,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark,
            'Known',
            '$knownCount',
            Icons.check_circle_outline,
            const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark,
            'Review',
            '$reviewCount',
            Icons.refresh,
            const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    bool isDark,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101828),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arimo',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCourseSelector(bool isDark) {
    return GestureDetector(
      onTap: () => _showCourseBottomSheet(isDark),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D44) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2B7FFF), Color(0xFF1E5FCC)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Course',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Arimo',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedCourse.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF101828),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D44) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF4D4D64)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Course',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF101828),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arimo',
              ),
            ),
            const SizedBox(height: 20),
            ...courses.map(
              (course) => GestureDetector(
                onTap: () {
                  _changeCourse(course);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedCourse.id == course.id
                        ? const Color(0xFF2B7FFF).withOpacity(0.1)
                        : (isDark
                              ? const Color(0xFF1A1A2E)
                              : const Color(0xFFF8F9FA)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedCourse.id == course.id
                          ? const Color(0xFF2B7FFF)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedCourse.id == course.id
                              ? const Color(0xFF2B7FFF)
                              : (isDark
                                    ? const Color(0xFF2D2D44)
                                    : Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.book,
                          color: selectedCourse.id == course.id
                              ? Colors.white
                              : const Color(0xFF6B7280),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          course.name,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF101828),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Arimo',
                          ),
                        ),
                      ),
                      if (selectedCourse.id == course.id)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF2B7FFF),
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildModernActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            isDark: isDark,
            label: 'Known',
            icon: Icons.check_circle,
            color: const Color(0xFF10B981),
            onTap: _markAsKnown,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            isDark: isDark,
            label: 'Review',
            icon: Icons.refresh,
            color: const Color(0xFFF59E0B),
            onTap: _reviewLater,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required bool isDark,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arimo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
