import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';

class TAAIAssistantScreen extends StatefulWidget {
  const TAAIAssistantScreen({super.key});

  @override
  State<TAAIAssistantScreen> createState() => _TAAIAssistantScreenState();
}

class _TAAIAssistantScreenState extends State<TAAIAssistantScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _animationController;

  String _selectedMode = 'general';
  String _selectedCourse = 'All Courses';
  bool _isTyping = false;
  bool _isRecording = false;

  final List<Map<String, dynamic>> _messages = [];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'id': 'grade_assist',
      'icon': Icons.grading,
      'label': 'Grade Assistance',
      'prompt': 'Help me grade this student submission',
    },
    {
      'id': 'feedback',
      'icon': Icons.rate_review,
      'label': 'Generate Feedback',
      'prompt': 'Generate constructive feedback for student work',
    },
    {
      'id': 'rubric',
      'icon': Icons.checklist,
      'label': 'Create Rubric',
      'prompt': 'Create a grading rubric for this assignment',
    },
    {
      'id': 'explain',
      'icon': Icons.lightbulb,
      'label': 'Explain Concept',
      'prompt': 'Explain this concept in simple terms',
    },
    {
      'id': 'quiz',
      'icon': Icons.quiz,
      'label': 'Generate Quiz',
      'prompt': 'Generate quiz questions for this topic',
    },
    {
      'id': 'lab_prep',
      'icon': Icons.science,
      'label': 'Lab Preparation',
      'prompt': 'Help me prepare for the upcoming lab session',
    },
  ];

  final List<Map<String, dynamic>> _modes = [
    {'id': 'general', 'icon': Icons.assistant, 'label': 'General Help'},
    {'id': 'grading', 'icon': Icons.grading, 'label': 'Grading Mode'},
    {'id': 'teaching', 'icon': Icons.school, 'label': 'Teaching Mode'},
    {'id': 'analysis', 'icon': Icons.analytics, 'label': 'Analysis Mode'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add({
      'id': 'welcome',
      'content':
          "Hello! I'm your TA AI Assistant. I can help you with:\n\n"
          "📝 **Grading assistance** - Evaluate submissions and provide feedback\n"
          "📊 **Performance analysis** - Understand student trends\n"
          "🔬 **Lab preparation** - Plan and organize lab sessions\n"
          "💡 **Teaching tips** - Get suggestions for explaining concepts\n\n"
          "How can I assist you today?",
      'isUser': false,
      'timestamp': DateTime.now(),
      'suggestions': [
        'Grade submissions',
        'Analyze performance',
        'Prepare for lab',
      ],
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == AppThemeMode.dark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: const TADrawer(currentRoute: '/ta/ai-assistant'),
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(isDark, l10n),
                _buildModeSelector(isDark, l10n),
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState(isDark, l10n)
                      : _buildMessageList(isDark, l10n),
                ),
                if (_messages.isNotEmpty &&
                    _messages.last['suggestions'] != null)
                  _buildSuggestions(
                    isDark,
                    _messages.last['suggestions'] as List<String>,
                  ),
                _buildQuickActionsBar(isDark, l10n),
                _buildInputBar(isDark, l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: TAColors.textPrimaryColor(isDark)),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TAColors.primary,
                  TAColors.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.taAIAssistant,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: TAColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Online',
                      style: TextStyle(color: TAColors.success, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: TAColors.textSecondaryColor(isDark),
            ),
            onPressed: () => _clearChat(l10n),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: TAColors.textSecondaryColor(isDark),
            ),
            color: TAColors.cardColor(isDark),
            onSelected: (value) => _handleMenuAction(value, isDark, l10n),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    const Icon(Icons.download, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.exportChat),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.aiSettings),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.chatHistory),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _modes.map((mode) {
            final isSelected = _selectedMode == mode['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                showCheckmark: false,
                avatar: Icon(
                  mode['icon'] as IconData,
                  size: 18,
                  color: isSelected ? Colors.white : TAColors.primary,
                ),
                label: Text(mode['label'] as String),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : TAColors.textPrimaryColor(isDark),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                backgroundColor: TAColors.cardColor(isDark),
                selectedColor: TAColors.primary,
                side: BorderSide(
                  color: isSelected
                      ? TAColors.primary
                      : TAColors.borderColor(isDark),
                ),
                onSelected: (selected) {
                  setState(() => _selectedMode = mode['id'] as String);
                  _handleModeChange(mode['id'] as String);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: TAColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              size: 48,
              color: TAColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.startConversation,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about grading, teaching, or lab assistance',
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(bool isDark, AppLocalizations l10n) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == _messages.length) {
          return _buildTypingIndicator(isDark);
        }
        return _buildMessageBubble(isDark, l10n, _messages[index]);
      },
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TAColors.borderColor(isDark)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
            const SizedBox(width: 8),
            Text(
              'AI is thinking...',
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: TAColors.primary.withValues(alpha: 0.3 + (0.7 * value)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(
    bool isDark,
    AppLocalizations l10n,
    Map<String, dynamic> message,
  ) {
    final isUser = message['isUser'] as bool;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? TAColors.primary : TAColors.cardColor(isDark),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: TAColors.borderColor(isDark)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormattedText(
                    message['content'] as String,
                    isUser ? Colors.white : TAColors.textPrimaryColor(isDark),
                  ),
                  if (message['attachments'] != null) ...[
                    const SizedBox(height: 8),
                    _buildAttachments(isDark, message['attachments'] as List),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message['timestamp'] as DateTime),
                  style: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontSize: 10,
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(width: 8),
                  _buildMessageActions(isDark, l10n, message),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedText(String text, Color color) {
    // Simple markdown-like formatting
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('**') && line.endsWith('**')) {
          return Text(
            line.replaceAll('**', ''),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          );
        } else if (line.startsWith('📝') ||
            line.startsWith('📊') ||
            line.startsWith('🔬') ||
            line.startsWith('💡') ||
            line.startsWith('✅') ||
            line.startsWith('⚠️')) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(line, style: TextStyle(color: color)),
          );
        }
        return Text(line, style: TextStyle(color: color));
      }).toList(),
    );
  }

  Widget _buildAttachments(bool isDark, List attachments) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: attachments.map((attachment) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: TAColors.scaffoldColor(isDark),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.attach_file, size: 16),
              const SizedBox(width: 6),
              Text(
                attachment['name'] as String,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageActions(
    bool isDark,
    AppLocalizations l10n,
    Map<String, dynamic> message,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _copyToClipboard(message['content'] as String, l10n),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.copy,
              size: 14,
              color: TAColors.textTertiaryColor(isDark),
            ),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => _regenerateResponse(message),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.refresh,
              size: 14,
              color: TAColors.textTertiaryColor(isDark),
            ),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => _showExportOptions(isDark, l10n, message),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.download,
              size: 14,
              color: TAColors.textTertiaryColor(isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions(bool isDark, List<String> suggestions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions.map((suggestion) {
          return ActionChip(
            label: Text(suggestion),
            labelStyle: TextStyle(color: TAColors.primary, fontSize: 12),
            backgroundColor: TAColors.primaryLight,
            side: BorderSide(color: TAColors.primary.withValues(alpha: 0.3)),
            onPressed: () => _sendMessage(suggestion),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickActionsBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _quickActions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: Icon(
                  action['icon'] as IconData,
                  size: 16,
                  color: TAColors.primary,
                ),
                label: Text(action['label'] as String),
                labelStyle: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 12,
                ),
                backgroundColor: TAColors.cardColor(isDark),
                side: BorderSide(color: TAColors.borderColor(isDark)),
                onPressed: () => _sendMessage(action['prompt'] as String),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: TAColors.textSecondaryColor(isDark),
            ),
            onPressed: () => _showAttachmentOptions(isDark, l10n),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: TAColors.scaffoldColor(isDark),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: TAColors.borderColor(isDark)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: l10n.typeMessage,
                        hintStyle: TextStyle(
                          color: TAColors.textTertiaryColor(isDark),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _isRecording
                          ? TAColors.error
                          : TAColors.textSecondaryColor(isDark),
                    ),
                    onPressed: () => _toggleRecording(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: TAColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _handleSend() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      _sendMessage(content);
      _messageController.clear();
    }
  }

  void _sendMessage(String content) {
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'id': '${DateTime.now().millisecondsSinceEpoch}_ai',
            'content': _generateResponse(content),
            'isUser': false,
            'timestamp': DateTime.now(),
            'suggestions': _getSuggestions(content),
          });
        });
        _scrollToBottom();
      }
    });
  }

  String _generateResponse(String userMessage) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('grade') || lower.contains('submission')) {
      return "📝 **Grading Assistance**\n\n"
          "I can help you evaluate submissions efficiently. Here's what I recommend:\n\n"
          "✅ **Strengths observed:**\n"
          "• Good code structure and organization\n"
          "• Proper variable naming conventions\n"
          "• Algorithm correctly implements the solution\n\n"
          "⚠️ **Areas for improvement:**\n"
          "• Missing edge case handling\n"
          "• Could optimize time complexity\n"
          "• Documentation could be more detailed\n\n"
          "**Suggested grade: 85/100 (B+)**\n\n"
          "Would you like me to generate detailed feedback for the student?";
    }

    if (lower.contains('feedback')) {
      return "📣 **Student Feedback Generated**\n\n"
          "Here's constructive feedback for the submission:\n\n"
          "\"Great work on implementing the core algorithm! Your code is well-organized "
          "and follows good naming conventions. To improve further:\n\n"
          "1. Consider handling edge cases like empty inputs\n"
          "2. The nested loops could be optimized using a hash map\n"
          "3. Adding comments would help explain your approach\n\n"
          "Keep up the excellent work! You're making good progress.\"\n\n"
          "Would you like me to adjust the tone or add specific points?";
    }

    if (lower.contains('rubric')) {
      return "📋 **Grading Rubric Created**\n\n"
          "**Assignment: Lab Exercise**\n\n"
          "| Criteria | Points | Description |\n"
          "|----------|--------|-------------|\n"
          "| Correctness | 40 | Code produces correct output |\n"
          "| Code Quality | 20 | Clean, readable, well-organized |\n"
          "| Efficiency | 15 | Optimal time/space complexity |\n"
          "| Documentation | 15 | Comments and explanations |\n"
          "| Edge Cases | 10 | Handles special cases |\n\n"
          "**Total: 100 points**\n\n"
          "Would you like me to customize this rubric?";
    }

    if (lower.contains('quiz') || lower.contains('question')) {
      return "📝 **Generated Quiz Questions**\n\n"
          "**Topic: Data Structures - Arrays**\n\n"
          "1. What is the time complexity of accessing an element by index in an array?\n"
          "   a) O(n)  b) O(1)  c) O(log n)  d) O(n²)\n\n"
          "2. Which operation is most expensive for dynamic arrays?\n"
          "   a) Access  b) Search  c) Insert at end  d) Insert at beginning\n\n"
          "3. What is the space complexity of merging two sorted arrays?\n"
          "   a) O(1)  b) O(n)  c) O(n+m)  d) O(nm)\n\n"
          "Would you like more questions or different difficulty levels?";
    }

    if (lower.contains('lab') || lower.contains('prepare')) {
      return "🔬 **Lab Session Preparation**\n\n"
          "**Checklist for upcoming lab:**\n\n"
          "✅ **Before the lab:**\n"
          "• Review prerequisite concepts\n"
          "• Prepare starter code templates\n"
          "• Test all examples work correctly\n"
          "• Prepare common error examples\n\n"
          "📋 **During the lab:**\n"
          "• Take attendance at start\n"
          "• Give 5-min concept overview\n"
          "• Allow hands-on practice time\n"
          "• Walk around to assist students\n\n"
          "💡 **Tips:**\n"
          "• Identify struggling students early\n"
          "• Prepare extension exercises for fast finishers\n\n"
          "Want me to create specific exercises?";
    }

    if (lower.contains('explain') || lower.contains('concept')) {
      return "💡 **Concept Explanation**\n\n"
          "I'll help you explain concepts clearly to students.\n\n"
          "**Best Practices for Explaining:**\n\n"
          "1. **Start Simple**: Begin with a real-world analogy\n"
          "2. **Visual Aids**: Use diagrams or code visualization\n"
          "3. **Examples**: Show 2-3 concrete examples\n"
          "4. **Common Mistakes**: Address typical misconceptions\n"
          "5. **Practice**: Give small exercises to verify understanding\n\n"
          "What specific concept would you like help explaining?";
    }

    if (lower.contains('performance') || lower.contains('analysis')) {
      return "📊 **Performance Analysis**\n\n"
          "Based on the current data, here's the class analysis:\n\n"
          "**Overall Performance:**\n"
          "• Average Score: 78.5%\n"
          "• Highest: 98%\n"
          "• Lowest: 52%\n\n"
          "**Distribution:**\n"
          "• A (90-100): 15 students (25%)\n"
          "• B (80-89): 22 students (37%)\n"
          "• C (70-79): 14 students (23%)\n"
          "• Below 70: 9 students (15%)\n\n"
          "⚠️ **At-Risk Students:** 9 students need attention\n\n"
          "Would you like detailed recommendations?";
    }

    return "I understand you're asking about: \"$userMessage\"\n\n"
        "As your TA AI Assistant, I can help with:\n\n"
        "📝 **Grading** - Evaluate and provide feedback on submissions\n"
        "📊 **Analysis** - Understand student performance trends\n"
        "🔬 **Lab Prep** - Organize and plan lab sessions\n"
        "📋 **Rubrics** - Create grading criteria\n"
        "❓ **Quizzes** - Generate practice questions\n\n"
        "Could you be more specific about what you need help with?";
  }

  List<String> _getSuggestions(String userMessage) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('grade')) {
      return ['Generate feedback', 'Create rubric', 'Grade next submission'];
    }
    if (lower.contains('quiz')) {
      return ['More questions', 'Harder level', 'Different topic'];
    }
    if (lower.contains('lab')) {
      return ['Create exercises', 'Prepare checklist', 'Generate examples'];
    }
    return ['Grade submissions', 'Analyze performance', 'Prepare for lab'];
  }

  void _handleModeChange(String mode) {
    final modeMessages = {
      'general':
          'Switched to General Help mode. I can assist with any TA-related tasks.',
      'grading':
          'Grading Mode activated. I\'ll focus on helping you evaluate submissions and provide feedback.',
      'teaching':
          'Teaching Mode enabled. I\'ll help you explain concepts and prepare educational content.',
      'analysis':
          'Analysis Mode ready. I\'ll help you understand student performance and identify trends.',
    };

    setState(() {
      _messages.add({
        'id': '${DateTime.now().millisecondsSinceEpoch}_system',
        'content': modeMessages[mode] ?? 'Mode changed.',
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _clearChat(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDark = state.themeMode == AppThemeMode.dark;
          return AlertDialog(
            backgroundColor: TAColors.cardColor(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              l10n.clearChat,
              style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
            ),
            content: Text(
              'Are you sure you want to clear the conversation?',
              style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _messages.clear();
                    _addWelcomeMessage();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TAColors.error,
                ),
                child: Text(
                  l10n.clear,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleMenuAction(String action, bool isDark, AppLocalizations l10n) {
    switch (action) {
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportingChat),
            backgroundColor: TAColors.info,
          ),
        );
        break;
      case 'settings':
        _showAISettings(isDark, l10n);
        break;
      case 'history':
        _showChatHistory(isDark, l10n);
        break;
    }
  }

  void _showAISettings(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TAColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.aiSettings,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              isDark,
              'Response Length',
              'Detailed',
              Icons.text_fields,
            ),
            _buildSettingTile(
              isDark,
              'Tone',
              'Professional',
              Icons.record_voice_over,
            ),
            _buildSettingTile(
              isDark,
              'Auto-suggestions',
              'Enabled',
              Icons.lightbulb,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    bool isDark,
    String title,
    String value,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: TAColors.primary),
      title: Text(
        title,
        style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
      ),
      trailing: Text(
        value,
        style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
      ),
      onTap: () {},
    );
  }

  void _showChatHistory(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TAColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.chatHistory,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHistoryItem(
              isDark,
              'Grading Lab 3 submissions',
              'Today, 2:30 PM',
            ),
            _buildHistoryItem(isDark, 'Quiz generation for ML', 'Yesterday'),
            _buildHistoryItem(isDark, 'Performance analysis', 'Feb 8, 2026'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(bool isDark, String title, String time) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: TAColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.chat_bubble_outline,
          color: TAColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
      ),
      subtitle: Text(
        time,
        style: TextStyle(
          color: TAColors.textSecondaryColor(isDark),
          fontSize: 12,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }

  void _showAttachmentOptions(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TAColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.attachFile,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachOption(
                  isDark,
                  Icons.description,
                  'Document',
                  () => Navigator.pop(context),
                ),
                _buildAttachOption(
                  isDark,
                  Icons.image,
                  'Image',
                  () => Navigator.pop(context),
                ),
                _buildAttachOption(
                  isDark,
                  Icons.code,
                  'Code',
                  () => Navigator.pop(context),
                ),
                _buildAttachOption(
                  isDark,
                  Icons.folder,
                  'Files',
                  () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachOption(
    bool isDark,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TAColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: TAColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);

    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recording... Speak now'),
          backgroundColor: TAColors.info,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isRecording) {
          setState(() => _isRecording = false);
          _sendMessage('Help me grade the latest submissions');
        }
      });
    }
  }

  void _copyToClipboard(String content, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copiedToClipboard),
        backgroundColor: TAColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _regenerateResponse(Map<String, dynamic> message) {
    // Find the user message before this AI message
    final index = _messages.indexOf(message);
    if (index > 0) {
      final userMessage = _messages[index - 1];
      if (userMessage['isUser'] == true) {
        setState(() {
          _messages.removeAt(index);
          _isTyping = true;
        });

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _isTyping = false;
              _messages.add({
                'id': '${DateTime.now().millisecondsSinceEpoch}_ai',
                'content': _generateResponse(userMessage['content'] as String),
                'isUser': false,
                'timestamp': DateTime.now(),
                'suggestions': _getSuggestions(
                  userMessage['content'] as String,
                ),
              });
            });
            _scrollToBottom();
          }
        });
      }
    }
  }

  void _showExportOptions(
    bool isDark,
    AppLocalizations l10n,
    Map<String, dynamic> message,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TAColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Export Response',
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.copy, color: TAColors.primary),
              title: Text(
                'Copy to Clipboard',
                style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
              ),
              onTap: () {
                Navigator.pop(context);
                _copyToClipboard(message['content'] as String, l10n);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf,
                color: TAColors.primary,
              ),
              title: Text(
                'Export as PDF',
                style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet, color: TAColors.primary),
              title: Text(
                'Export as Text',
                style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
