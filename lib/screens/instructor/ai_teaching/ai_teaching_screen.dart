import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../models/instructor/ai_teaching_model.dart';
import '../../../widgets/instructor/ai_teaching/ai_teaching_barrel.dart';

/// AI Teaching Assistant Screen
class AITeachingScreen extends StatefulWidget {
  const AITeachingScreen({super.key});

  @override
  State<AITeachingScreen> createState() => _AITeachingScreenState();
}

class _AITeachingScreenState extends State<AITeachingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AIChatMessage> _messages = [];
  AIMode _selectedMode = AIMode.createContent;
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<QuickAction> get _quickActions => [
    QuickAction(
      id: 'mcq',
      label: 'Generate 10 MCQs',
      icon: Icons.quiz_rounded,
      prompt: 'Generate 10 multiple choice questions for the selected topic',
    ),
    QuickAction(
      id: 'summarize',
      label: 'Summarize Lecture',
      icon: Icons.summarize_rounded,
      prompt: 'Summarize the key points from my lecture',
    ),
    QuickAction(
      id: 'lesson_plan',
      label: 'Create Lesson Plan',
      icon: Icons.calendar_today_rounded,
      prompt: 'Create a detailed lesson plan',
    ),
    QuickAction(
      id: 'rubric',
      label: 'Generate Rubric',
      icon: Icons.grading_rounded,
      prompt: 'Generate an assessment rubric',
    ),
    QuickAction(
      id: 'feedback',
      label: 'Write Feedback',
      icon: Icons.rate_review_rounded,
      prompt: 'Help me write constructive feedback for a student',
    ),
  ];

  List<String> get _suggestedPrompts => [
    'Create a pop quiz on the last chapter',
    'Analyze my students\' performance trends',
    'Generate discussion questions',
    'Create study materials for exam prep',
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        AIChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    _simulateAIResponse(text);
  }

  void _simulateAIResponse(String userMessage) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      // Generate response based on mode and message
      final response = _generateAIResponse(userMessage);

      setState(() {
        _messages.add(
          AIChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: response,
            isUser: false,
            timestamp: DateTime.now(),
            status: MessageStatus.sent,
          ),
        );
        _isLoading = false;
      });

      _scrollToBottom();
    });
  }

  String _generateAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('mcq') || lowerMessage.contains('quiz')) {
      return '''Here are 10 MCQs for your topic:

1. What is the primary function of mitochondria?
   a) Protein synthesis
   b) Energy production ✓
   c) Cell division
   d) Waste removal

2. Which organelle is responsible for photosynthesis?
   a) Mitochondria
   b) Ribosome
   c) Chloroplast ✓
   d) Nucleus

3. The cell membrane is primarily composed of:
   a) Proteins only
   b) Carbohydrates only
   c) Phospholipid bilayer ✓
   d) Nucleic acids

Would you like me to generate more questions or adjust the difficulty level?''';
    }

    if (lowerMessage.contains('summarize') ||
        lowerMessage.contains('summary')) {
      return '''📝 **Lecture Summary**

**Key Points:**
• The lecture covered the fundamental concepts of cellular biology
• Main focus areas included cell structure, organelles, and their functions
• Students learned about the differences between prokaryotic and eukaryotic cells

**Main Takeaways:**
1. Cells are the basic unit of life
2. Different organelles perform specialized functions
3. Cell membrane regulates what enters and exits the cell

**Topics for Review:**
- Mitochondria and energy production
- Nucleus and genetic material
- Cell membrane structure

Would you like me to create study questions based on this summary?''';
    }

    if (lowerMessage.contains('lesson') || lowerMessage.contains('plan')) {
      return '''📅 **Lesson Plan: Introduction to Cell Biology**

**Duration:** 50 minutes

**Learning Objectives:**
1. Students will identify main cell organelles
2. Students will explain the function of each organelle
3. Students will differentiate between plant and animal cells

**Materials Needed:**
- Microscopes
- Prepared cell slides
- Cell diagram handouts

**Lesson Structure:**

**Opening (10 min):**
- Quick review of previous lesson
- Present today's learning objectives

**Main Activity (30 min):**
- Interactive presentation on organelles
- Microscope lab activity
- Group discussion

**Closing (10 min):**
- Summary and Q&A
- Assign homework

Would you like me to add more details to any section?''';
    }

    return '''I understand you're asking about: "$userMessage"

Based on your request, here are some suggestions:

1. **Content Creation:** I can help you create quizzes, assignments, or study materials on this topic.

2. **Analysis:** I can analyze student performance data related to this subject.

3. **Enhancement:** I can help improve existing teaching materials.

What specific assistance would you like me to provide?''';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleQuickAction(QuickAction action) {
    _messageController.text = action.prompt;
    _sendMessage();
  }

  void _handleSuggestedPrompt(String prompt) {
    _messageController.text = prompt;
    _sendMessage();
  }

  void _showModesSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AIModesBottomSheet(
        selectedMode: _selectedMode,
        onModeSelected: (mode) {
          setState(() => _selectedMode = mode);
        },
        isDark: isDark,
      ),
    );
  }

  void _handleRegenerate(AIChatMessage message) {
    // Find the user message before this AI message
    final index = _messages.indexOf(message);
    if (index > 0) {
      final previousUserMessage = _messages
          .sublist(0, index)
          .lastWhere((m) => m.isUser, orElse: () => message);
      if (previousUserMessage.isUser) {
        setState(() {
          _messages.remove(message);
          _isLoading = true;
        });
        _simulateAIResponse(previousUserMessage.content);
      }
    }
  }

  void _handleCopy(AIChatMessage message) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleExport(AIChatMessage message) {
    // Show export options
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExportOptionsSheet(
        message: message,
        isDark: context.read<ThemeBloc>().state.themeMode == AppThemeMode.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == AppThemeMode.dark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: isDark
              ? AITeachingColors.darkBackground
              : AITeachingColors.background,
          appBar: _buildAppBar(isDark, l10n),
          body: SafeArea(
            child: Column(
              children: [
                // Mode selector
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: AIModeSelector(
                    selectedMode: _selectedMode,
                    onTap: () => _showModesSheet(isDark),
                    isDark: isDark,
                  ),
                ),
                // Chat area
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildChatList(isDark),
                ),
                // Quick actions
                if (_messages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: AIQuickActions(
                      actions: _quickActions,
                      onActionTap: _handleQuickAction,
                      isDark: isDark,
                    ),
                  ),
                // Message input
                AIMessageInput(
                  controller: _messageController,
                  onSend: _sendMessage,
                  onAttachment: _showAttachmentOptions,
                  onVoice: _startVoiceInput,
                  isDark: isDark,
                  isLoading: _isLoading,
                  hintText: l10n.aiAskAnything,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: isDark ? AITeachingColors.darkCard : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AITeachingColors.textPrimaryColor(isDark),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AITeachingColors.aiGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aiTeachingAssistant,
                style: TextStyle(
                  color: AITeachingColors.textPrimaryColor(isDark),
                  fontSize: ResponsiveUtil(context).isMobile ? 14 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.aiOnlineReady,
                style: TextStyle(
                  color: AITeachingColors.success,
                  fontSize: ResponsiveUtil(context).isMobile ? 12 : 16,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.history_rounded,
            color: AITeachingColors.textSecondaryColor(isDark),
          ),
          onPressed: _showChatHistory,
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: AITeachingColors.textSecondaryColor(isDark),
          ),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AIEmptyState(
            isDark: isDark,
            onGetStarted: () {
              // Focus on input
            },
          ),
          const SizedBox(height: 16),
          // Suggested prompts
          AISuggestedPrompts(
            prompts: _suggestedPrompts,
            onPromptTap: _handleSuggestedPrompt,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          // Quick actions
          AIQuickActions(
            actions: _quickActions,
            onActionTap: _handleQuickAction,
            isDark: isDark,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChatList(bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return AITypingIndicator(isDark: isDark);
        }

        final message = _messages[index];
        return ChatMessageBubble(
          message: message,
          isDark: isDark,
          onRegenerate: message.isUser
              ? null
              : () => _handleRegenerate(message),
          onMakeEasier: message.isUser
              ? null
              : () => _makeEasierOrHarder(message, true),
          onMakeHarder: message.isUser
              ? null
              : () => _makeEasierOrHarder(message, false),
          onCopy: message.isUser ? null : () => _handleCopy(message),
          onExport: message.isUser ? null : () => _handleExport(message),
        );
      },
    );
  }

  void _makeEasierOrHarder(AIChatMessage message, bool easier) {
    final action = easier ? 'easier' : 'harder';
    setState(() {
      _messages.add(
        AIChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Make this $action',
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          AIChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content:
                'Here\'s an ${easier ? "simplified" : "advanced"} version of the content:\n\n${message.content}\n\n[Content has been adjusted to be ${easier ? "more accessible" : "more challenging"}]',
            isUser: false,
            timestamp: DateTime.now(),
            status: MessageStatus.sent,
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDark = state.themeMode == AppThemeMode.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AITeachingColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AITeachingColors.borderColor(isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Attach File',
                      style: TextStyle(
                        color: AITeachingColors.textPrimaryColor(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildAttachmentOption(
                    icon: Icons.description_outlined,
                    label: 'Document',
                    color: Colors.blue,
                    isDark: isDark,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildAttachmentOption(
                    icon: Icons.image_outlined,
                    label: 'Image',
                    color: Colors.green,
                    isDark: isDark,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildAttachmentOption(
                    icon: Icons.table_chart_outlined,
                    label: 'Spreadsheet',
                    color: Colors.orange,
                    isDark: isDark,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: AITeachingColors.textPrimaryColor(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _startVoiceInput() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Voice input coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showChatHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chat history coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDark = state.themeMode == AppThemeMode.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AITeachingColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AITeachingColors.borderColor(isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: AITeachingColors.textSecondaryColor(isDark),
                    ),
                    title: Text(
                      'Clear Chat',
                      style: TextStyle(
                        color: AITeachingColors.textPrimaryColor(isDark),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _clearChat();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings_outlined,
                      color: AITeachingColors.textSecondaryColor(isDark),
                    ),
                    title: Text(
                      'AI Settings',
                      style: TextStyle(
                        color: AITeachingColors.textPrimaryColor(isDark),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.help_outline_rounded,
                      color: AITeachingColors.textSecondaryColor(isDark),
                    ),
                    title: Text(
                      'Help',
                      style: TextStyle(
                        color: AITeachingColors.textPrimaryColor(isDark),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDark = state.themeMode == AppThemeMode.dark;
          return AlertDialog(
            backgroundColor: isDark ? AITeachingColors.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Clear Chat?',
              style: TextStyle(
                color: AITeachingColors.textPrimaryColor(isDark),
              ),
            ),
            content: Text(
              'This will delete all messages in this conversation. This action cannot be undone.',
              style: TextStyle(
                color: AITeachingColors.textSecondaryColor(isDark),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AITeachingColors.textSecondaryColor(isDark),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _messages.clear();
                  });
                },
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: AITeachingColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Export options bottom sheet
class _ExportOptionsSheet extends StatelessWidget {
  final AIChatMessage message;
  final bool isDark;

  const _ExportOptionsSheet({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AITeachingColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AITeachingColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Export Content',
                style: TextStyle(
                  color: AITeachingColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildExportOption(
              context: context,
              icon: Icons.description_outlined,
              label: 'Export as PDF',
              color: Colors.red,
            ),
            _buildExportOption(
              context: context,
              icon: Icons.article_outlined,
              label: 'Export as Word',
              color: Colors.blue,
            ),
            _buildExportOption(
              context: context,
              icon: Icons.text_snippet_outlined,
              label: 'Export as Text',
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: AITeachingColors.textPrimaryColor(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label coming soon'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
